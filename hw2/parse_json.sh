#!/bin/sh

get_value()
{
  # semi_colon_count = 0;
  sc_cnt=0

  # while read -n1 c; do
  #   echo "$c"
  # done < <(echo -n "$1")
}

# parse_json()
# {
#   token=("cos_time" "cos_ename")
#   for t in "${token[@]}"
#   do
#     pos=$(echo $1 | grep -b -o "$t" | cut -d: -f1)
#     if [ "$pos" != "" ]; then
#       echo $pos
#     fi
#   done
# }

# main
raw_file='raw_timetable.json'
prep_file='pre_classes.txt'
# echo $raw_data

# parse_json '"cos_ename":"Calculus(I)",'
# get_value '"cos_ename":"Calculus(I)",'

token=("cos_time" "cos_ename")

while read -n1 c; do
  pre_process+="$c"
  if [ "$c" = '{' ] || [ "$c" = '}' ] || [ "$c" = ',' ];
  then
    pre_process+='\n'
  fi
done < $raw_file

echo "$pre_process" > "$prep_file"
