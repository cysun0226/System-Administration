#!/bin/bash
filename='classes.txt'

if [ ! -d "data" ]; then
  mkdir data
fi

IFS=$'\n' read -d '' -r -a class < $filename

for i in ${!class[@]}
do
class_items+=( "${class[$i]}" "${class[$i]}" "off" )
done

usr_input=$(dialog --buildlist "Add a class" 30 100 20 "${class_items[@]}" --output-fd 1)

cur_class=$(sed 's@\\@@g' <<< $usr_input)

eval 'for word in '$cur_class'; do echo $word; done' > ./data/cur_class.txt
