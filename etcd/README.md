# README

Just some CLI things I forget sometimes.

### Show members

Assumes cert envar in use.

```
$ etcdctl --endpoints 10.5.1.2:2379,10.5.1.3:2379,10.5.1.4:2379 member list -w table
```

### Add member

Assumes cert envar in use. Assume I am `.2`

```
$ etcdctl --endpoints 10.5.1.2:2379,10.5.1.3:2379,10.5.1.4:2379 member add myhost2 --peer-urls "https://10.5.1.2:2380"
```

