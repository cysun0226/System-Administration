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
  added_id=''
  while read a; do
    echo $a
    x_time=$(echo $a | cut -d'#' -f2 | cut -d'?' -f1)
    time_cnt=$(echo $x_time | grep -o '-' | wc -l)
    time=''
    for t in $(seq $time_cnt); do
      time="$time$(echo $x_time | cut -d',' -f$t | cut -d'-' -f1)"
    done
    total_time="$total_time$time"
  done < ./data/cur_class.txt
}

check_conflict()
{
  # $1 = total_time
  Mon_t=''
  Tue_t=''
  Wed_t=''
  Thu_t=''
  Fri_t=''
  Sat_t=''
  Sun_t=''

  for i in $(seq ${#total_time}); do
    c=$(echo "$total_time" | cut -c $i-$i)
    case $c in
      1) wd='Mon_t'
         echo $Mon_t | grep -o $c
      ;;
      2) wd='Tue_t'
      ;;
      3) wd='Wed_t'
      ;;
      4) wd='Thu_t'
      ;;
      5) wd='Fri_t'
      ;;
      6) wd='Sat_t'
      ;;
      7) wd='Sun_t'
      ;;
      *) tmp=$(eval echo "\$$wd")
         eval $wd="$tmp$c"
      ;;
    esac
  done

  echo "$Mon_t"
}

# main
# generate_list_item ./data/classes.txt
# eval dialog --buildlist '"Add a class"' 30 100 20 "$(generate_list_item ./data/classes.txt)"
total_time=''
conflict=0
find_total_time
echo "$total_time"
check_conflict
# add_class
