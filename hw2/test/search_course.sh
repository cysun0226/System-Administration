#!/bin/sh

search_courses()
{
  target=$1
  while read p; do
    # echo "$p"
    if [ "$(echo "$p" | grep "$target")" != "" ]; then
      time=$(echo $p | cut -d'#' -f2 | cut -d'?' -f1)
      name=$(echo $p | cut -d'?' -f2)
      printf '%s - %s\n' "$time" "$name"
    fi
  done < ../2-2/data/classes.txt
}

## main
> ./data/input.txt
dialog --title "Search courses" --inputbox "Target substring:" 20 100 2>./data/input.txt
ipt=$(cat ./data/input.txt)
dialog --title "Courses contain [$ipt]" --msgbox "$(search_courses $ipt)" 50 140
