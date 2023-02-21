#!/bin/bash


cd `du -smx /usr/local/* | sort -nr|head -n1|awk '{print$2}'`

find * -mtime +30 -name "*.log" -exec rm -rf {} \;
find * -mtime +30 -name "*.hprof" -exec rm -rf {} \;
