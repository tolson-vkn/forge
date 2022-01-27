#!/bin/bash

# Kind of janky but given ticket's for machines with no instance id. Would be nice to
# also search for that, but at this point maybe should write an executable.

if [[ -z "$1" ]]; then
    echo -e "\e[33mYou must supply a private DNS like [ip-10-20-1-5.ec2.internal]\e[0m"
    exit 1
else
    echo "Searching for private DNS: $1"
fi

accounts=(
    'account'
    'someaccount'
    'anotheraccount'
)

file=$(mktemp)

for account in "${accounts[@]}"; do
    aws-vault exec $account -- aws ec2 describe-instances \
        --filters "[{
        \"Name\": \"network-interface.private-dns-name\", 
        \"Values\": [\"$1\"]
    }]" > $file

    if [[ "$(jq -r '.Reservations | length' $file)" -eq "1" ]]; then
        echo -e "\e[32mEC2 instances located.\e[0m"

        echo -e "Instance ID:\t$(jq -r '.Reservations[0].Instances[0].InstanceId' $file)"
        echo -e "Account ID:\t$(jq -r '.Reservations[0].OwnerId' $file)"

        break
    elif [[ "$(jq -r '.Reservations | length' $file)" -eq "0" ]]; then
        echo -e "\e[33mEC2 instance not found in account $account...\e[0m"
    else
        echo -e "\e[31mMore than one instance returned with DNS record. Go look at [$file]\e[0m"
        exit 1
    fi
done

rm $file
