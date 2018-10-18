#!/bin/sh

##### initialize

# create ./data/
if [ ! -d "data" ]; then
  mkdir data
fi

# timetable.json

# classes.txt
#  - should record on/off

## ./data/cur_class.txt
#  - change after "Add_class", default empty.
if [ ! -f "./data/cur_class.txt" ]; then
   cat > cur_class.txt
fi
## display option
display_opt=0
hide_col=0
opt1_str='Show Classroom'
opt2_str='Hide Extra Column'

### functions ---------------
handle_option()
{
  opt=$1
  case $opt in
    0) display_opt=1-$display_opt
       if [ display_opt = 0 ];
       then
         opt1_str='Show Classroom'
       else
         opt1_str='Show Class Name'
       fi
       ;;
    1) echo "op2"
       break
       ;;
  esac
}

add_class()
{
  filename='classes.txt'
  IFS=$'\n' read -d '' -r -a class < $filename
  filename='./data/cur_class.txt'
  IFS=$'\n' read -d '' -r -a added_class < $filename
  for i in ${!class[@]}
  do
  status='off'
    for a in ${!added_class[@]}; do
      if [ "${class[$i]}" = "${added_class[$a]}" ]; then
        # echo "class[$i]=${class[$i]}"
        # echo "added_class[$i]=${class[$i]}"
        status='on'
      fi
    done
  class_items+=( "${class[$i]}" "${class[$i]}" "$status" )
  done
  # buildlist
  usr_input=$(dialog --buildlist "Add a class" 30 100 20 "${class_items[@]}" --output-fd 1)
  cur_class=$(sed 's@\\@@g' <<< $usr_input)
  eval 'for word in '$cur_class'; do echo $word; done' > ./data/cur_class.txt
}


### functions ---------------


### main --------------------

dialog --title "Check Courses Data" \
--defaultno --yesno \
"Welcome to CRS.\nCurrent courses: \n * CS107-fall\n\nDownload new courses?"\
 20 50

response=$?
case $response in
  0) echo "Please input curl URL:";;
  1) echo "Go on.";;
  255) echo "[ESC] key pressed.";;
esac

# display timetable
while [ $response != 2 ]; do
  timetable=$(./print_table.out ./data/cur_class.txt)
  dialog --no-collapse --title "Timetable" \
             --help-button --help-label "Exit" \
             --extra-button --extra-label "Option" \
             --ok-label "Add Class" --msgbox "$timetable" 50 100

  response=$?
  case $response in
    0) add_class
       ;;
    2) break
       ;;
    3) echo "Option"
       dialog --title "Option" --menu "Choose one" 12 35 5 \
       op1 "$opt1_str" op2 "$opt2_str"
       handle_option $?
       ;;
  esac
done
