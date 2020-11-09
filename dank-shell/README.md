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
