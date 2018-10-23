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
update=1
total_time=''

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
clean_use_table()
{
  for d in 1 2 3 4 5 6 7; do
    for t in M N A B C D X E F G H Y I J K L; do
      eval "used_${d}_${t}=0"
    done
  done
}

get_2d_arr()
{
  id=$1$2$3
  eval value="\$$id"
  printf '%s' "$value"
}

get_total_time()
{
  total_time=''
  while read a; do
    x_time=$(echo $a | cut -d'#' -f2 | cut -d'?' -f1)
    time_cnt=$(echo $x_time | grep -o '-' | wc -l)
    time=''
    for t in $(seq $time_cnt); do
      time="$time$(echo $x_time | cut -d',' -f$t | cut -d'-' -f1)"
    done
    total_time="$total_time$time"
  done < $1
  echo "$total_time"
}

check_conflict()
{
  for i in $(seq ${#1}); do
    c=$(echo "$1" | cut -c $i-$i)
    if_w=$(echo "$c" | grep '[1-7]')
    # weekday
    if [ "$if_w" != "" ];
    then
      day=$c
    else
      # time
      t=$c
      if_use=$(get_2d_arr used "_$day" "_$t")
      if [ "$if_use" != "0" ]; then
        time_conflict=1
      fi
      eval "used_${day}_$t=1"
    fi
  done
}

search_courses()
{
  target=$1
  while read p; do
    if [ "$(echo "$p" | grep "$target")" != "" ]; then
      time=$(echo $p | cut -d'#' -f2 | cut -d'?' -f1)
      name=$(echo $p | cut -d'?' -f2)
      printf '%s - %s\n' "$time" "$name"
    fi
  done < ./data/classes.txt
}

get_free_time_courses()
{
  while read a; do
    x_time=$(echo $a | cut -d'#' -f2 | cut -d'?' -f1)
    time_cnt=$(echo $x_time | grep -o '-' | wc -l)
    time=''
    for t in $(seq $time_cnt); do
      time="$time$(echo $x_time | cut -d',' -f$t | cut -d'-' -f1)"
    done

    time_seq=$(echo "$time" | fold -w1 | paste -sd' ' -)
    available=1
    for c in $time_seq; do
      if_w=$(echo "$c" | grep '[1-7]')
      # weekday
      if [ "$if_w" != "" ];
      then
        day=$c
      else
        # time
        t=$c
        if_use=$(get_2d_arr used "_$day" "_$t")
        if [ "$if_use" != "0" ]; then
          available=0
        fi
      fi
    done
    if [ "$available" = "1" ]; then
      id=$(echo $a | cut -d'#' -f1)
      time=$(echo $a | cut -d'#' -f2 | cut -d'?' -f1)
      name=$(echo $a | cut -d'?' -f2)
      printf '[%s] %s - %s\n' "$id" "$time" "$name"
    fi
  done < $1
}

handle_option()
{
  update=0
  ipt=$1
  case $ipt in
    op1) show_classroom=$(expr 1 - $show_classroom)
       if [ $show_classroom = 0 ];
       then
         opt1_str='Show Classroom'
       else
         opt1_str='Show Class Name'
       fi
       update=1
       ;;
    op2) show_extra=$(expr 1 - $show_extra)
       if [ $show_extra = 0 ];
       then
         opt2_str='Show Extra Column'
       else
         opt2_str='Hide Extra Column'
       fi
       update=1
       ;;
    op3) # search courses
        > ./data/input.txt
        dialog --title "Search courses" --inputbox "Target substring:" 20 100 2>./data/input.txt
        ipt=$(cat ./data/input.txt)
        dialog --title "Courses contain [$ipt]" --msgbox "$(search_courses $ipt)" 50 140
        rm ./data/input.txt
       ;;
    op4) # search free time courses
        clean_use_table
        check_conflict $(get_total_time ./data/cur_class.txt)
        time_conflict=0
        printf 'searching...'
        dialog --title "Time Available Courses" \
        --msgbox "$(get_free_time_courses ./data/classes.txt)" 50 140
      ;;
  esac
  printf "generate table..."
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
    update=0
    return
  fi
  cur_class=$(cat $USR_IPT | sed 's@\\@@g')
  eval 'for word in '$cur_class'; do echo $word; done' > ./data/temp.txt
  # check conflict
  clean_use_table
  check_conflict $(get_total_time ./data/temp.txt)
  # add_result=$(./print_table.sh ./data/temp.txt $show_classroom $show_extra 1)
  # if [ "$add_result" = "pass" ];
  if [ "$time_conflict" = "0" ];
  then
    dialog --title "Add Class" --yes-label 'YES' --no-label 'Cancel' --yesno \
    "Saving?" 20 10
    response=$?
    case $response in
      0) eval 'for word in '$cur_class'; do echo $word; done' > ./data/cur_class.txt
      ;;
      1)
      ;;
    esac
  else
    dialog --title "Warning" --msgbox "Time conflict!" 20 10
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
"Welcome to CRS.\n\nFind available courses data.\n\nPress [OK] to start CRS."\
 20 50

# Check if current_class exists
if [ ! -f "./data/cur_class.txt" ]; then
  > ./data/cur_class.txt
fi

 response=$?
 case $response in
   0) printf "generate table...";;
   1) exit 0;;
   255) exit 0;;
 esac

# display timetable
while [ $response != 2 ]; do
  if [ $update = 1 ]; then
    ./print_table.sh ./data/cur_class.txt $show_classroom $show_extra 0 | sed 's/#/\ /g' > ./data/table.txt
  fi
  timetable=$(cat ./data/table.txt)
  update=1
  # timetable=$(./print_table.sh ./data/cur_class.txt $show_classroom $show_extra 0 | sed 's/#/\ /g')
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
      opt=$(dialog --title "Option" --menu "" 24 70 6 \
      op1 "$opt1_str" op2 "$opt2_str" op3 "Search Courses"\
      op4 "Search Free Time Courses" --output-fd 1)
      handle_option $opt
      ;;
  esac
done
