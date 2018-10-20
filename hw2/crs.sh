#!/bin/sh

##### initialize

# create ./data/
if [ ! -d "data" ]; then
  mkdir data
fi

# timetable.json

# classes.txt
# - generate from timetable.json

## ./data/cur_class.txt
#  - change after "Add_class", default empty.
if [ ! -f "./data/cur_class.txt" ]; then
   cat > cur_class.txt
fi
## display option
show_classroom=0
show_extra=0
time_conflict=0
opt1_str='Show Classroom'
opt2_str='Show Extra Column'

### functions ---------------
handle_option()
{
  ipt=$1
  case $ipt in
    op1) show_classroom=$(expr 1 - $show_classroom)
       if [ $show_classroom = 0 ];
       then
         opt1_str='Show Classroom'
       else
         opt1_str='Show Class Name'
       fi
       ;;
    op2) show_extra=$(expr 1 - $show_extra)
       if [ $show_extra = 0 ];
       then
         opt2_str='Show extra column'
       else
         opt2_str='Hide extra column'
       fi
       ;;
  esac
}

add_class()
{
  time_conflict=0
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
  usr_input=$(dialog --buildlist "Add a class" 30 100 20 \
  "${class_items[@]}" --output-fd 1)
  unset class_items
  if [ "$usr_input" = "" ]; then
    return
  fi
  cur_class=$(sed 's@\\@@g' <<< $usr_input)
  # eval 'for word in '$cur_class'; do echo $word; done' > ./data/cur_class.txt
  eval 'for word in '$cur_class'; do echo $word; done' > ./data/temp.txt
  add_result=$(./print_table.out ./data/temp.txt)
  if [ "$add_result" != "conflict" ];
  then
    eval 'for word in '$cur_class'; do echo $word; done' > ./data/cur_class.txt
  else
    dialog --title "Warning" --msgbox "Time conflict!" 10 20
    time_conflict=1
  fi
  rm ./data/temp.txt
}

init()
{
  filename='classes.txt'
  IFS=$'\n' read -d '' -r -a class < $filename
}


### functions ---------------


### main --------------------

dialog --title "Check Courses Data" \
--defaultno --yesno \
"Welcome to CRS.\n\nCurrent courses: \n * CS107-fall\n\nDownload new courses?"\
 20 50

response=$?
case $response in
  0) echo "Please input curl URL:";;
  1) echo "Go on.";;
  255) echo "[ESC] key pressed.";;
esac

init

# display timetable
while [ $response != 2 ]; do
  timetable=$(./print_table.out ./data/cur_class.txt $show_classroom $show_extra)
  # if [ $show_classroom = 0 ]
  #   then
  #     timetable=$(./print_table.out ./data/cur_class.txt)
  #   else
  #     timetable=$(./print_table.out ./data/cur_class.txt show_classroom)
  # fi
  dialog --no-collapse --title "Timetable" \
             --help-button --help-label "Exit" \
             --extra-button --extra-label "Option" \
             --ok-label "Add Class" --msgbox "$timetable" 50 130

  response=$?
  case $response in
    0) add_class
       while [ $time_conflict = 1 ]; do
         add_class
       done
       ;;
    2) break
       ;;
    3) echo "Option"
       opt=$(dialog --title "Option" --menu "Choose one" 12 35 5 \
       op1 "$opt1_str" op2 "$opt2_str" --output-fd 1)
       handle_option $opt
       ;;
  esac
done
