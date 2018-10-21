
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
  while read p; do
    printf '"%s" ' "$p"
    t=$(echo "$p" | sed 's/?/\ -\ /g')
    printf '"%s" ' "$t"
    printf '"%s" ' "off"
  done < $1
}

add_class()
{
  usr_input=$(eval dialog --buildlist '"Add a class"' 30 100 20 "$(generate_list_item ./data/classes.txt)" --output-fd 1)
  # cancel
  if [ "$usr_input" = "" ]; then
    return
  fi
  cur_class=$(echo "$usr_input" | sed 's@\\@@g')
  eval 'for word in '$cur_class'; do echo $word; done' > ./data/cur_class.txt
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

timetable=$(./print_table.sh ./data/cur_class.txt | sed 's/#/\ /g')

dialog --no-collapse --title "Timetable" \
           --help-button --help-label "Exit" \
           --extra-button --extra-label "Option" \
           --ok-label "Add Class" --msgbox "$timetable" 50 130

response=$?
case $response in
  0) add_class
  #   while [ $time_conflict = 1 ]; do
  #     add_class
  #   done
    ;;
  2) break
    ;;
  3) echo "Option"
    opt=$(dialog --title "Option" --menu "Choose one" 12 35 5 \
    op1 "$opt1_str" op2 "$opt2_str" --output-fd 1)
    handle_option $opt
    ;;
esac
