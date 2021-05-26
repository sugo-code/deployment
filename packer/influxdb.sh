#!/bin/bash

sudo wget https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.6.x86_64.rpm
sudo yum -y localinstall influxdb2-2.0.6.x86_64.rpm

sudo systemctl start influxdb
sudo systemctl enable influxdb

sudo rm influxdb2-2.0.6.x86_64.rpm
