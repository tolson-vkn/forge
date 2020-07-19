# NFS PVS

## Install NFS Server

Before you run the script it's for Ubuntu 20.04 so YMMV.

* Make sure you change the host IPs in the `/etc/exports`
* Consider the dirs created maybe you don't want it like this or need a remote dir

Run the `install-nfs.sh`

## Create the kubernetes manifests

* Make sure the server ips match the NFS host

Run the `generate.sh`

Apply `kubectl apply -f pvs.yaml`

