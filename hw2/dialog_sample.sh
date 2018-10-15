#!/bin/sh

# msgbox
dialog --title TESTING --msgbox "this is a test" 10 20
# yes no
dialog --title "yes/no" --no-shadow --yesno "Exit?" 10 30
# inputbox
dialog --title "Input your name" --inputbox "Please input your name:" 10 30 2 > ./tmp/input.txt
# textbox
dialog --title "README" --textbox ../README.MD  17 40
# menu
dialog --title "Pick a choice" --menu "Choose one" 12 35 5 \
1 "say hello to everyone" 2 "thanks for your support" 3 "exit"
# checklist
dialog --backtitle "Checklist" --checklist "Test" 20 50 10 \
Memory Memory_Size 1 Dsik Disk_Size 2
# extra buttons
dialog --title "YES/NO BOX" --backtitle "BACKGROUND TITLE" \
           --help-button --extra-button --extra-label "EXTRA" \
           --ok-label "Agree" --yesno "QUERY TEXT" 0 0
# radio list
dialog --backtitle "Test" --radiolist "Select option:" 15 35 3 \
 1 "Test 1" off \
 2 "Test 2" on \
 3 "Test 3" off
# build list
dialog --buildlist "Select a directory" 20 50 5 \
  f0 "Directory Zero" off \
  f1 "Directory One" off \
  f2 "Directory Two" off \
  f3 "Directory Three" off
