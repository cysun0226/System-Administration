#!/bin/sh

get_value()
{
  s_pos=$(echo $1 | awk -F: '{print length($1)+1}')
  e_pos=${#1}
  s_pos=$(expr $s_pos + 2)
  e_pos=$(expr $e_pos - 2) # mac-6;bsd-2
  sc_cnt=0
  n=$(echo $1 | cut -c $s_pos-$e_pos)
  printf '%s' "$n"

  # while read -n1 c; do
  #   echo "$c"
  # done < <(echo -n "$1")
}

parse_json()
{
  # cos_time
  pos=$(echo "$1" | grep -b -o 'cos_time' | cut -d: -f1)
  if [ "$pos" != "" ]; then
    get_value "$1"
    printf '?'
  fi

  # cos_ename
  pos=$(echo "$1" | grep -b -o 'cos_ename' | cut -d: -f1)
  if [ "$pos" != "" ]; then
    get_value "$1"
    printf '\n'
  fi
}

# main ======
raw_file='raw_timetable.json'
prep_file='pre_classes.txt'

# insert new line into .json
cat "$raw_file" | sed 's/'{'/{\'$'\n/g' | sed 's/'}'/}\'$'\n/g' | sed 's/','/,\'$'\n/g'  > "$prep_file"

while read p; do
    # echo $p
    parse_json "$p"
done < $prep_file
