#!/bin/sh
/woapps/wotaskd.woa/wotaskd &
/woapps/JavaMonitor.woa/JavaMonitor -DWOPort=1086 &
httpd-foreground
