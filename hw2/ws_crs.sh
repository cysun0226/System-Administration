
init()
{
  filename='classes.txt'
  IFS=$'\n' read -d '' -r -a class < $filename
}

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
