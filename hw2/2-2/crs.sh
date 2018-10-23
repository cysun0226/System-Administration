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
      printf '%s#' "$v"
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
    x_time=$(echo $a | cut -d'#' -f2)
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

get_free_time_courses()
{
  > ./data/available.txt
  while read a; do
    x_time=$(echo $a | cut -d'#' -f2)
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
      printf '%s\n' "$a" >> $2
    fi
  done < $1
}

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
    op3) # search courses
        > ./data/input.txt
        dialog --title "Search courses" --inputbox "Target substring:" 20 100 2>./data/input.txt
        if [ "$?" = "1" ]; then
          rm ./data/input.txt
          update=0
          return
        fi
        ipt=$(cat ./data/input.txt)
        add_class s $ipt n
        rm ./data/input.txt
       ;;
    op4) # search free time courses
        clean_use_table
        check_conflict $(get_total_time ./data/cur_class.txt)
        time_conflict=0
        printf 'searching...'
        get_free_time_courses ./data/classes.txt ./data/available.txt
        add_class n n f
        rm ./data/available.txt
        # dialog --title "README" --textbox ./data/available.txt  50 100
        # dialog --title "Time Available Courses" \
        # --msgbox "$(get_free_time_courses ./data/classes.txt)" 50 140
      ;;
  esac
  printf "generate table..."
}

add_class()
{
  # $1 = basic
  # $2 = target
  # $3 = free time

  # create empty temp file
  time_conflict=0
  USR_IPT="./data/temp.txt"
  >$USR_IPT

  if [ "$1" = "all" ];
  then
    if [ "$(cat ./data/cur_class.txt)" != "" ]; then
      off_list_item=$(grep -v -f ./data/cur_class.txt ./data/classes.txt | awk -F# '{printf "%s?%s - %s?off\n",$0,$2,$3}' | sed 's/^/"/' | sed 's/$/"/' | sed 's/?/" "/g')
    else
      off_list_item=$(cat ./data/classes.txt | awk -F# '{printf "%s?%s - %s?off\n",$0,$2,$3}' | sed 's/^/"/' | sed 's/$/"/' | sed 's/?/" "/g')
    fi
    on_list_item=$(cat ./data/cur_class.txt | awk -F# '{printf "%s?%s - %s?on\n",$0,$2,$3}' | sed 's/^/"/' | sed 's/$/"/' | sed 's/?/" "/g')
    eval dialog --buildlist '"Add a class"' 30 110 20 $off_list_item $on_list_item 2>$USR_IPT
    response=$?
  else
    >./data/tmp2.txt
    if [ "$3" != "f" ]; then
      off_list_item=$(grep $2 ./data/classes.txt | awk -F# '{printf "%s?%s - %s?off\n",$0,$2,$3}' | sed 's/^/"/' | sed 's/$/"/' | sed 's/?/" "/g')
      eval dialog --buildlist '"Courses contain [$1]"' 30 110 20 $off_list_item 2>./data/tmp2.txt
      response=$?
    else
      off_list_item=$(cat ./data/available.txt | awk -F# '{printf "%s?%s - %s?off\n",$0,$2,$3}' | sed 's/^/"/' | sed 's/$/"/' | sed 's/?/" "/g')
      eval dialog --buildlist '"Course for free time"' 30 110 20 $off_list_item 2>./data/tmp2.txt
      response=$?
    fi
    echo "" >> ./data/tmp2.txt
    cat ./data/tmp2.txt | sed 's/" /\'$'\n/g' | tr -d '"' > $USR_IPT
    cat $USR_IPT > ./data/tmp2.txt
    cat ./data/tmp2.txt ./data/cur_class.txt | sed 's/^/"/' | sed 's/$/"/' > $USR_IPT
    rm ./data/tmp2.txt
  fi
  # cancel
  if [ "$response" = "1" ]; then
    rm ./data/temp.txt
    update=0
    return
  fi
  cur_class=$(cat $USR_IPT | sed 's@\\@@g')
  eval 'for word in '$cur_class'; do echo $word; done' > ./data/temp.txt
  # check conflict
  if [ "$cur_class" != "" ]; then
    clean_use_table
    check_conflict $(get_total_time ./data/temp.txt)
  fi
  # add_result=$(./print_table.sh ./data/temp.txt $show_classroom $show_extra 1)
  # if [ "$add_result" = "pass" ];
  if [ "$time_conflict" = "0" ];
  then
    dialog --title "Add Class" --yes-label 'YES' --no-label 'Cancel' --yesno \
    "\n\nSaving?" 10 30
    response=$?
    case $response in
      0) eval 'for word in '$cur_class'; do echo $word; done' > ./data/cur_class.txt
      ;;
      1) update=0
      ;;
    esac
  else
    dialog --title "Warning" --msgbox "\n\nTime conflict!" 10 30
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
dialog --title "CRS" --msgbox \
"\nWelcome to CRS.\n\nFind available courses data.\n\nPress to start CRS."\
 20 50

# Check if current_class exists
if [ ! -f "./data/cur_class.txt" ]; then
  > ./data/cur_class.txt
fi

 response=$?
 case $response in
   0) ;;
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
    0) add_class 'all' 'n' 'n'
      while [ $time_conflict = 1 ]; do
        add_class 'all' 'n' 'n'
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
