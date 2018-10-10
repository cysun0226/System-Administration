#!/bin/sh

ls -A -R -l | grep -v '^$'| grep -v '^total' | grep -v '^d' | sort -r -n -k5 | awk 'BEGIN {f_num=0; d_num=0; total=0;} /^\./{d_num=d_num+1} /^-/{f_num=f_num+1; total=total+$5} FNR<6{ print(FNR ":", $5, $9 ) } END{print ("Dir num:", d_num, "\nFile num:", f_num, "\nTotal:", total)}'
