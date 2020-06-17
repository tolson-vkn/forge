#!/bin/bash

# Ok this is a messed up script but I think it's cool because it does stuff with
# UI automation so it's worthy of the forge. Why?... I have a bank account for my
# Mortgage which is really archaic. No API. No automated QIF/CSV export, just a PDF
# with garbage formatting that's hard to parse. It's annoying to export my mortgage
# statements monthly so now just log into the bank account and run this script. 
# Sure I could make it open firefox and do that too but I wanted to put this in my
# Public space. This could easily be used as a xdotool reference which is why I put it
# here. 

usage() {
    cat << USAGE
Usage: $0 [flags]

  A script used to do X11 desktop automation to download bank statements.

  A little janky, once a month goto the bank site. Auth. Goto landing page.
  Run the script. Import CSV GNUcash or wherever.

Flags:

  -a, --account      Optional, the account to fetch. Default is Mortgage/Escrow

  -l, --last-month   Required, looks at the current month and looks back at the
                     first day and last day of previous month to pass to form.

  -m, --mouse-test   Optional, stops execution and just tests the mouse points.
                     Useful to correct for changes in display as these are px offest

  -h, --help         This :)

USAGE
    exit 1
}

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root xdotool is scary"
   exit 1
fi

# Useful date operations
# First Day, current month:
# date -d "-0 month -$(($(date +%d)-1)) days"

# First Day, last month:
# date -d "-1 month -$(($(date +%d)-1)) days"

# Last Day, current month:
# date -d "-$(date +%d) days +1 month"

# Last Day, last month:
# date -d "-$(date +%d) days -0 month"

# Last Day, month before last month:
# date -d "-$(date +%d) days -1 month"

# Monitor/element PX values
ACCOUNT_BTN="1210 510"
START_DATE_BTN="1250 560"
END_DATE_BTN="1250 615"
CSV_BTN="1080 850"
DOWNLOAD_TRANS_BTN="1080 950"
MOUSE_SAVE_BTN="775 615"

function mouse_test {
    # Just see if the cursor works, because this shit crazy.
    echo "ACCOUNT_BTN does it look good?"
    xdotool mousemove $ACCOUNT_BTN
    sleep 2
    echo "START_DATE_BTN does it look good?"
    xdotool mousemove $START_DATE_BTN
    sleep 2
    echo "END_DATE_BTN does it look good?"
    xdotool mousemove $END_DATE_BTN
    sleep 2
    echo "CSV_BTN does it look good?"
    xdotool mousemove $CSV_TRANS_BTN
    sleep 2
    echo "DOWNLOAD_TRANS_BTN does it look good?"
    xdotool mousemove $DOWNLOAD_TRANS_BTN
    sleep 2
}

function select_account {
    account_iter="$1"
    xdotool mousemove $ACCOUNT_BTN
    sleep 0.25
    #xdotool click --delay 5000 --repeat 100000 1
    xdotool click 1
    sleep 0.25
    # Selecting from dropdown need to know account in list.
    for i in $(seq 1 $account_iter); do
        xdotool key "Down"
    done
    xdotool key "Return"
}

function enter_date {
    coords_x="$1"
    coords_y="$2"
    date_val="$3"

    # GOTO Box identified by a global
    xdotool mousemove $coords_x $coords_y

    # Clear the box...
    # Click in -> Select All -> Delete
    xdotool click 1
    sleep 0.25
    xdotool key "alt+a"
    sleep 0.25
    xdotool key "Delete"
    sleep 0.25

    xdotool key type $date_val
    sleep 0.25
    # This will break the forms.
    # xdotool key "Return"
}

function csv_click {
    coords_x="$1"
    coords_y="$2"

    # Select CSV radial
    xdotool mousemove $coords_x $coords_y
    sleep 0.25
    xdotool click 1
    sleep 0.25
}

function dl_trans {
    coords_x="$1"
    coords_y="$2"

    # Start the download
    xdotool mousemove $coords_x $coords_y
    sleep 0.25 
    xdotool click 1
    sleep 0.25 
}

function dl_firefox {
    # Can't really know where firefox will put the
    # Window so do some selection magic and not rely
    # on a mouse.

    # Let it popup
    sleep 5
    id=$(xdotool search --name "Opening transactions")
    xdotool windowfocus $id

    # Move from Open with to Save File
    xdotool key "Down"
    # Tab over to OK
    xdotool key "Tab"
    xdotool key "Tab"
    xdotool key "Tab"
    xdotool key "Tab"
    xdotool key "Return"
}

function dl_reload {
    # Lazy just refresh the form I don't care...
    xdotool mousemove 900 285
    sleep 0.25 
    xdotool click 1
    sleep 0.25 

    xdotool mousemove 115 335
    sleep 0.25 
    xdotool click 1
    sleep 0.25 

    xdotool mousemove 115 450
    sleep 0.25 
    xdotool click 1
    sleep 0.25 
}

while [[ $# -gt 0 ]]; do 
    flag="$1"

    case $flag in
        -s)
        START="$2"
        shift; shift
        ;;
        -e)
        END="$2"
        shift; shift
        ;;
        -a|--account-iter)
        ACCOUNT_ITER="$2"
        shift; shift
        ;;
        -l|--last-month)
        LAST_MONTH=true
        shift;
        ;;
        -f|--from-date)
        echo "Not implemented..."
        exit 1
        ;;
        -m|--mouse-test)
        mouse_test
        exit 0
        ;;
        -h|--help)
        shift;
        usage
        ;;
        *)
        echo -e "Unknown flag/argument [$1] all options provided from flags\n" 
        usage
        break
        ;;
    esac
done

if [[ -z "$LAST_MONTH" ]]; then
    echo -e "Last month is the only supported operation. Must be set --last-month.\n"
else
    start_date=$(date -d "-1 month -$(($(date +%d)-1)) days" +"%m/%d/%Y")
    end_date=$(date -d "-$(date +%d) days -0 month" +"%m/%d/%Y")
fi

# I would rather do it here and alert than do it in opts. Whatever...
if [[ -z "$ACCOUNT_ITER" ]]; then
    echo -e "Using default account"
    # Default account
    ACCOUNT_ITER=1
fi

select_account $ACCOUNT_ITER
enter_date $START_DATE_BTN $start_date
enter_date $END_DATE_BTN $end_date
csv_click $CSV_BTN
dl_trans $DOWNLOAD_TRANS_BTN
dl_firefox
dl_reload
