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