#!/bin/sh -x

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
  USR_IPT="./data/temp.txt"
  >$USR_IPT # create temp file
  eval dialog --buildlist '"Add a class"' 30 100 20 "$(generate_list_item ./data/classes.txt)" 2>$USR_IPT

  # cancel
  if [ "$?" = "1" ]; then
    echo "cancel"
    return
  fi

  cur_class=$(sed 's@\\@@g' <<< $USR_IPT)
  eval 'for word in '$cur_class'; do echo $word; done' > ./data/cur_class.txt
}

find_total_time()
{
  while read a; do
    echo $a
    x_time=$(echo $a | cut -d'#' -f2 | cut -d'?' -f1)
    time_cnt=$(echo $x_time | grep -o '-' | wc -l)
    time=''
    for t in $(seq $time_cnt); do
      time="$time$(echo $x_time | cut -d',' -f$t | cut -d'-' -f1)"
    done
    total_time="$total_time$time"
  done < $1
}

check_conflict()
{
  time_seq=$(echo "$total_time" | fold -w1 | paste -sd' ' -)
  for c in $time_seq; do
    if_w=$(echo "$c" | grep '[1-7]')
    # weekday
    if [ "$if_w" != "" ];
    then
      day=$c
    else
      # time
      t=$c
      if_use=$(get_2d_value used "_$day" "_$t")
      if [ "$if_use" != "0" ]; then
        conflict=1
      fi
      eval "used_${day}_$t=1"
    fi
  done
}

# init array
clean_usage()
{
  for d in 1 2 3 4 5 6 7; do
    for t in M N A B C D X E F G H Y I J K L; do
      eval "used_${d}_${t}=0"
    done
  done
}

get_2d_value()
{
  id=$1$2$3
  eval value="\$$id"
  printf '%s' "$value"
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
        if_use=$(get_2d_value used "_$day" "_$t")
        if [ "$if_use" != "0" ]; then
          available=0
        fi
      fi
    done
    if [ "$available" = "1" ]; then
      echo $a
    fi
  done < $1
}

# main
# generate_list_item ./data/classes.txt
# eval dialog --buildlist '"Add a class"' 30 100 20 "$(generate_list_item ./data/classes.txt)"
total_time=''
conflict=0
find_total_time ./data/cur_class.txt
echo "$total_time"
clean_usage
check_conflict
echo "\n\n ## free time \n\n"
get_free_time_courses ./data/classes.txt
# add_class
