# Dank Shell

Cool shell scripts and nixy things.

## Random

### Bell the terminal

```
printf '\a'
```

### Pipe and use file descriptor

```
tar xOf sampledata.tar.gz sampledata.json | python bulkload.py -f /dev/fd/0
```

### Pylint

```
find . -name "*.py" | xargs pylint | tee /dev/tty | sed -n "rated at (\d+.\d+)/10"
```

### Cert cause stupid

```
openssl x509 -in apiserver.crt -text -noout
```

### $PATH to lines

Or just basic `sed` of an envar.

```
$ sed 's/:/\n/g' <<< "$PATH"
/usr/local/bin
/usr/local/sbin
/usr/bin
/usr/sbin
/sbin
/bin
```

### Hostname without hostname

```
$ getent hosts google.com
```

### CPU Usage

Good for `motd`

```
#!/bin/sh
free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }'
df -h | awk '$NF=="/"{printf "Disk Usage: %d/%dGB (%s)\n", $3,$2,$5}'
top -bn1 | grep load | awk '{printf "CPU Load: %.2f\n", $(NF-2)}' 
```

### Random hex

```
LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c 40
```

### Print all executables in path

```
whence -pm '*' | grep python
```

### Do something on PID completion

Example; need to clone to hack with `testdisk`; `dd if=/dev/sdc of=/tmp/sdc.dd`, would run for 2-3 hours so, suspend when it's done and I'm asleep.

```
while true; do if [ ! $(pidof hwatch) ]; then break; fi; sleep 5; done; systemctl suspend
```

### Random chars

```
for x in {0..25}; do cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 6; echo; done
```

#### Random pets

Get: `https://lib.rs/crates/petname`

```
petname
```
