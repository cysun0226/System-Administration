#!/bin/sh

##### initialize

# create ./data/
if [ ! -d "./data" ]; then
  mkdir data
fi

exist_id=''
cnt=0

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
  while read p; do
    get_json_value "$p"
  done < $1
}

download_data()
{
  raw_file='./data/raw_data.json'
  prep_file='pre_classes.txt'
  curl "$1" --data " $2" > $raw_file
  # insert new line into .json
  cat "$raw_file" | sed 's/'{'/{\'$'\n/g' | sed 's/'}'/}\'$'\n/g' | sed 's/'\",'/,\'$'\n/g' | awk '/cos_id/{print $0} /cos_time/{print $0} /cos_ename/{print $0}' | sed 's/"//g' > "$prep_file"
  parse_json "$prep_file" > ./data/classes.txt
}

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
     255) echo "[ESC] key pressed.";;
   esac
fi

# Data Exists
# dialog --title "CRS" --yes-label 'OK' --no-label 'Exit' --yesno \
# "Welcome to CRS.\n\nCurrent courses: \n * CS107-fall\n\nPress [OK] to start CRS."\
#  20 50
