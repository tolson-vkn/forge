#!/bin/bash

# install packages/dependencies for compilation 
sudo yum -y install gcc make ncurses-devel

cd /tmp

# the latest version of ncdu is published here: http://dev.yorhel.nl/ncdu
# update the link below if necessary:
wget -nv http://dev.yorhel.nl/download/ncdu-1.10.tar.gz

tar xvzf ncdu-1.10.tar.gz

cd ncdu-1.10
 ./configure --prefix=/usr
make
sudo make install
