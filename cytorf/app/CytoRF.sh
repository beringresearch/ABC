#!/bin/sh

/usr/local/bin/docker run --rm -d -v /Users/:/home/shiny -p 80:3838 beringresearch/cytorf

sleep 1

open CytoRF.app 

