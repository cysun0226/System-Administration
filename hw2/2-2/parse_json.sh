#!/bin/sh

get_value()
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

# main ======
raw_file='raw_timetable.json'
prep_file='pre_classes.txt'
exist_id=''
cnt=0

# insert new line into .json
cat "$1" | sed 's/'{'/{\'$'\n/g' | sed 's/'}'/}\'$'\n/g' | sed 's/'\",'/,\'$'\n/g' | awk '/cos_id/{print $0} /cos_time/{print $0} /cos_ename/{print $0}' | sed 's/"//g' > "$prep_file"

while read p; do
  get_value "$p"
done < $prep_file
