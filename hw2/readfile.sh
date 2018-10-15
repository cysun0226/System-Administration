#!/bin/bash
filename='sample.txt'
# echo Start
# while read p; do
#     echo $p
# done < $filename

# while IFS=\= read -r var; do
#     vars+=($var)
# done < $filename

IFS=$'\n' read -d '' -r -a classes < $filename

for i in ${!classes[@]}
do
var+=${classes[$i]}
done

dialog --title "Classes" --textbox classes.txt 50 80

# var=$(df -hT | awk '{print lines[@]}')

# echo "${lines[1]}"


# filename="$1"
# while read -r line
# do
#     classes+=($line)
#     echo $line
# done < $filename

# echo ${classes[1]}

# dialog --title "YES/NO BOX" --backtitle "BACKGROUND TITLE" \
#            --help-button --extra-button --extra-label "EXTRA" \
#            --ok-label "Agree" --yesno ${vars[0]} 0 0
