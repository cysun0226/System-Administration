#!/bin/sh

get_value()
{
  v=$(echo $1 | cut -d':' -f2 | sed 's/.$//')

  case $v in
    ''|*[!0-9]*) ;;
    *)
      # is number
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
      fi
    ;;
  esac

  if [ "$rdd" = "1" ]; then
    return
  fi

  printf '%s\n' "$v"

  # if [ -n "$v" ] && [ "$v" -eq "$v" ] 2>/dev/null; then
  #   echo number
  # else
  #   echo not a number
  # fi


  # if [ -n "$v" ] && [ "$v" -eq "$v" ] 2>/dev/null;
  # then
  #   # is number
  #   # check if redundant
  #   echo "number"
  #   rdd=0
  #   for i in $exist_id; do
  #     if [ "$v" = "$i" ]; then
  #       rdd=1
  #       break
  #     fi
  #   done
  #
  #   if [ "$rdd" = "0" ]; then
  #     exist_id="$exist_id $v"
  #   fi
  # fi
  #
  # if [ "$rdd" = "1" ];
  # then
  #   echo '[RDD]'
  #   return
  # fi




}

parse_json()
{
  # cos_id
  pos=$(echo "$1" | grep -b -o 'cos_id' | cut -d: -f1)
  if [ "$pos" != "" ]; then
    new_id=$(get_value "$1")
    # check if redundant
    rdd=0
    for i in $exist_id; do
      if [ "$new_id" = "$i" ]; then
        rdd=1
        break
      fi
    done
    if [ "$rdd" = "1" ];
    then
      echo '[RDD]'
      return
    else
      exist_id="$exist_id $p"
    fi
    printf '%s\n' "$new_id"
  fi

  if [ "$rdd" = "1" ]; then
    echo '[RDD]'
    return
  fi

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
exist_id=''

# insert new line into .json
cat "$1" | sed 's/'{'/{\'$'\n/g' | sed 's/'}'/}\'$'\n/g' | sed 's/','/,\'$'\n/g' | awk '/cos_id/{print $0} /cos_time/{print $0} /cos_ename/{print $0}' | sed 's/"//g' > "$prep_file"

while read p; do
  get_value "$p"
done < $prep_file
