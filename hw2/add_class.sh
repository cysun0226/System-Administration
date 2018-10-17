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

# first="I love Suzy and Mary"
# second="Sara"
# first=${first/Suzy/$second}

eval 'for word in '$cur_class'; do echo $word; done' > ./data/cur_class.txt
timetable=$(./print_table.out ./data/cur_class.txt)
# ./print_table.out ./data/cur_class.txt > ./data/timetable.txt
# echo "$timetable"

dialog --no-collapse --title "Timetable" \
           --help-button --extra-button --extra-label "EXTRA" \
           --ok-label "Agree" --msgbox "$timetable" 50 100

# for c in $(seq 1 ${#cur_class})
# do
#   if [ "${cur_class:c-1:1}"!='C' ]; then
#     printf '%s' ${cur_class:c-1:1}
#   fi
# done
