#!/bin/bash

sudo rm /var/run/tpm/tpmd_socket:0
sudo kill -9 $(ps -e | grep tcsd | awk '{print $1}')

sudo tpmd -df clear &

sleep 3

sudo tcsd -ef &
