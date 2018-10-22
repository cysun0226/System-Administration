#!/bin/sh

##### initialize

# create ./data/
if [ ! -d "data" ]; then
  mkdir data
fi

# variables
show_classroom=0
show_extra=0
time_conflict=0
opt1_str='Show Classroom'
opt2_str='Show Extra Column'
exist_id=''

##### download_data
get_json_value()
{
  v=$(echo $1 | cut -d':' -f2 | sed 's/.$//')

  cnt=$(expr $cnt + 1 )
  case $cnt in
    1) #id
        # check if redundant
        rdd=0
          for i in $exist_id; do
            if [ "$v" = "$i" ]; then
              rdd=1
              break
            fi
          done
        if [ "$rdd" = "0" ]; then
           exist_id="$exist_id $v"
           printf '%s#' "$v"
        fi
    ;;
    2) # time
      if [ "$rdd" = "1" ]; then
        return
      fi
      printf '%s?' "$v"
    ;;
    3) #name
      cnt=0
      if [ "$rdd" = "1" ]; then
        return
      fi
      printf '%s\n' "$v"
    ;;
  esac
}

parse_json()
{
  cnt=0
  while read p; do
    get_json_value "$p"
  done < $1
}

download_data()
{
  raw_file='./data/raw_data.json'
  prep_file='./data/pre_classes.txt'
  curl "$1" --data " $2" > $raw_file
  # insert new line into .json
  cat "$raw_file" | sed 's/'{'/{\'$'\n/g' | sed 's/'}'/}\'$'\n/g' | sed 's/'\",'/,\'$'\n/g' | awk '/cos_id/{print $0} /cos_time/{print $0} /cos_ename/{print $0}' | sed 's/"//g' > "$prep_file"
  parse_json "$prep_file" > ./data/classes.txt
  rm $raw_file
  rm $prep_file
}

##### CRS function
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

# check if courses data exists
if [ ! -f "./data/classes.txt" ]; then
  dialog --title "CRS" \
  --defaultno --yesno \
  "Welcome to CRS.\n\nNo available courses data.\n\nDownload default courses?\
  \n\n * [YES] Download default courses (CS107-fall)\n\n * [NO]  Download from input URL"\
   20 50

   response=$?
   case $response in
     0) dialog --title "Download Courses Data" --msgbox "Download CS107-fall." 10 30
        download_data 'https://timetable.nctu.edu.tw/?r=main/get_cos_list' \
        'm_acy=107&m_sem=1&m_degree=3&m_dep_id=17&m_group=**&m_grade=**&m_class=**&m_option=**&m_crs name=**&m_teaname=**&m_cos_id=**&m_cos_code=**&m_crstime=**&m_crsoutline=**&m_costype=**'
        dialog --title "Download Courses Data" --msgbox "Finish Downloading." 10 30
     ;;
     1) dialog --title "Download Courses Data" --inputbox "Please input URL:" 20 100 2>./data/input.txt
        url=$(cat ./data/input.txt)
        dialog --title "Download Courses Data" --inputbox "Please input data format:" 20 100 2>./data/input.txt
        data_format=$(cat ./data/input.txt)
        download_data "$url" "$data_format"
     ;;
     255) exit 0;;
   esac
fi

# Data Exists
dialog --title "CRS" --yes-label 'OK' --no-label 'Exit' --yesno \
"Welcome to CRS.\n\nCurrent courses: \n * CS107-fall\n\nPress [OK] to start CRS."\
 20 50

# Check if current_class exists
if [ ! -f "./data/cur_class.txt" ]; then
  > ./data/cur_class.txt
fi

 response=$?
 case $response in
   0) echo "generate table...";;
   1) exit 0;;
   255) exit 0;;
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
    2) exit 0
      ;;
    3) echo "Option"
      opt=$(dialog --title "Option" --menu "Choose one" 12 35 5 \
      op1 "$opt1_str" op2 "$opt2_str" --output-fd 1)
      handle_option $opt
      ;;
  esac
done
