#!/bin/bash

# Fetch
sudo apt-get install nfs-kernel-server

# Configure 
sudo mkdir /nfs
sudo chown -R nobody:nogroup /nfs
sudo chmod 777 /nfs
sudo cat > /etc/exports << EOF
# /etc/exports: the access control list for filesystems which may be exported
#               to NFS clients.  See exports(5).
#
# Example for NFSv2 and NFSv3:
# /srv/homes       hostname1(rw,sync,no_subtree_check) hostname2(ro,sync,no_subtree_check)
#
# Example for NFSv4:
# /srv/nfs4        gss/krb5i(rw,sync,fsid=0,crossmnt,no_subtree_check)
# /srv/nfs4/homes  gss/krb5i(rw,sync,no_subtree_check)
#

/nfs  10.5.1.206/24(rw,sync,no_subtree_check)
/nfs  10.5.1.207/24(rw,sync,no_subtree_check)
EOF

# Create kube vols
for x in {0..10}; do 
    mkdir /nfs/disk-$(printf "%02d" $x); 
done
sudo chown -R nobody:nogroup /nfs
sudo chmod -R 777 /nfs

