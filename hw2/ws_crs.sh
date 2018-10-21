
# variables
show_classroom=0
show_extra=0
time_conflict=0
opt1_str='Show Classroom'
opt2_str='Show Extra Column'

init()
{
  filename='classes.txt'
  IFS=$'\n' read -d '' -r -a class < $filename
}

add_class()
{
  echo "add_class"
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

 init

timetable=$(./print_table.sh ./sample_sh.txt | sed 's/#/\ /g')

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
    # handle_option $opt
    ;;
esac
