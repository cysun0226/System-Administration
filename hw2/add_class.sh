#!/bin/bash
filename='classes.txt'

IFS=$'\n' read -d '' -r -a class < $filename

for i in ${!class[@]}
do
# var+="c$i"
# var+=${class[$i]}
# var+='off'
class_items+=( "$i" "${class[$i]}" "off" )

done

dialog --buildlist "Add a class" 30 100 20 "${class_items[@]}"


# for i in ${!var[@]}
# do
# echo ${var[$i]}
# printf "\n"
# done
