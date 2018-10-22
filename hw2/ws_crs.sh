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
   > cur_class.txt
fi

# variables
show_classroom=0
show_extra=0
time_conflict=0
opt1_str='Show Classroom'
opt2_str='Show Extra Column'

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
         opt2_str='Show Extra Column'
       else
         opt2_str='Hide Extra Column'
       fi
       ;;
  esac
}

generate_list_item()
{
  # added_class
  added_id=''
  while read a; do
    added_id="$added_id $(echo $a | cut -d'#' -f1)"
  done < ./data/cur_class.txt

  while read p; do
    id=$(echo $p | cut -d'#' -f1)
    time=$(echo $p | cut -d'#' -f2 | cut -d'?' -f1)
    name=$(echo $p | cut -d'?' -f2)

    on_off='off'

    for a in $added_id; do
      if [ "$id" = "$a" ]; then
        on_off='on'
        break
      fi
    done

    printf '"%s" ' "$p"
    printf '"%s - %s" ' "$time" "$name"
    printf '"%s" ' "$on_off"
  done < $1
}

add_class()
{
  # create empty temp file
  time_conflict=0
  USR_IPT="./data/temp.txt"
  >$USR_IPT

  eval dialog --buildlist '"Add a class"' 30 110 20 "$(generate_list_item ./data/classes.txt)" 2>$USR_IPT
  # cancel
  if [ "$?" = "1" ]; then
    rm ./data/temp.txt
    return
  fi
  cur_class=$(cat $USR_IPT | sed 's@\\@@g')
  eval 'for word in '$cur_class'; do echo $word; done' > ./data/temp.txt
  add_result=$(./print_table.sh ./data/temp.txt $show_classroom $show_extra 1)
  if [ "$add_result" = "pass" ];
  then
    eval 'for word in '$cur_class'; do echo $word; done' > ./data/cur_class.txt
  else
    dialog --title "Warning" --msgbox "Time conflict!" 10 20
    time_conflict=1
  fi
  rm ./data/temp.txt
}



### main ----------------------

dialog --title "Check Courses Data" \
--defaultno --yesno \
"Welcome to CRS.\n\nCurrent courses: \n * CS107-fall\n\nDownload new courses?"\
 20 50

 response=$?
 case $response in
   0) echo "Please input curl URL:";;
   1) echo "generate table...";;
   255) echo "[ESC] key pressed.";;
 esac

# display timetable
while [ $response != 2 ]; do
  timetable=$(./print_table.sh ./data/cur_class.txt $show_classroom $show_extra 0 | sed 's/#/\ /g')

  dialog --no-collapse --title "Timetable" \
             --help-button --help-label "Exit" \
             --extra-button --extra-label "Option" \
             --ok-label "Add Class" --msgbox "$timetable" 50 140

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
