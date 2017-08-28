#!/bin/sh

/usr/local/bin/docker run -d -v /Users/:/home/shiny -p 80:3838 cytorf
sleep 1
open CytoRF.app 

