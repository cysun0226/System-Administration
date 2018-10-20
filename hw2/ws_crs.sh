
init()
{
  filename='classes.txt'
  IFS=$'\n' read -d '' -r -a class < $filename
}

show_classroom=0
show_extra=0
time_conflict=0
opt1_str='Show Classroom'
opt2_str='Show Extra Column'

### main ----------------------

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

timetable=$(./print_table.out ./data/cur_class.txt $show_classroom $show_extra)

dialog --no-collapse --title "Timetable" \
           --help-button --help-label "Exit" \
           --extra-button --extra-label "Option" \
           --ok-label "Add Class" --msgbox "$timetable" 50 130
