#!/bin/sh

get_2d_value()
{
  current_value=$1$2$3
  eval printf '%s' \$$current_value
}

get_3d_value()
{
  id=$1$2$3$4
  eval value="\$$id"
  printf '%s' "$value"

}

print_bar()
{
  for i in $(seq $1); do
    printf '-'
  done
  printf '\n'
}

print_dbar()
{
  for i in $(seq $1); do
    printf '='
  done
  printf '\n'
}

get_space()
{
  for i in $(seq $1); do
    printf '#'
  done
}

get_time()
{
  case $1 in
    A) echo 1 ;;
    B) echo 2 ;;
    C) echo 3 ;;
    D) echo 4 ;;
    E) echo 5 ;;
    F) echo 6 ;;
    G) echo 7 ;;
    H) echo 8 ;;
    I) echo 9 ;;
    J) echo 10 ;;
    K) echo 11 ;;
  esac
}

print_table()
{
  print_bar $(expr $grid_width \* 5 + 24)
  printf '   '
  for d in $weekday; do
    printf '| '
    printf '%s' $d
    get_space $(expr $grid_width - 1)
    if [ "$d" = 'Fri' ] ; then
      printf '|\n'
    fi
  done
  print_dbar $(expr $grid_width \* 5 + 24)

  t_idx=0
  for t in $time_code; do
    t_idx=$(expr $t_idx + 1)
    # time row
    printf ' %s' $t
    for w in $(seq 5); do
      printf ' | '
      get_3d_value timetable "_$t_idx" "_$w" _1
    done
    printf ' |\n'

    # grid
    for g in 2 3 4; do
      printf '  '
      for w in 1 2 3 4 5; do
        printf ' | '
        get_3d_value timetable "_$t_idx" "_$w" "_$g"
      done
      printf ' |\n'
    done
    print_bar $(expr $grid_width \* 5 + 24)
  done
}

fill_timetable()
{
  # $1 row / $2 col / $3 name
  lc=$(expr ${#3} / $grid_width + 1)

  for i in $(seq $lc); do
    grid_row=''
    # i*GRID_LEN
    igl=$(expr $i \* $grid_width - $grid_width + 1 )
    # (i+1)*GRID_LEN
    ipl=$(expr $i \* $grid_width )
    if [ ${#3} -gt $ipl ];
    then
      grid_row=$(echo "$3" | cut -c $igl-$(expr $igl + $grid_width))
    else
      grid_row=$(echo "$3" | cut -c $igl-$(expr ${#3} + 1 ))
      grid_row="$grid_row$(echo '###############' | cut -c 1-$(expr $ipl - ${#3} + 1))" # fill the row
    fi
    eval "timetable_${row}_${col}_${i}=\"$grid_row\""
    # echo "$grid_row"
  done
  # echo $(expr length "$1")

}

parse_class()
{
  q_pos=$(echo "$1" | awk -F? '{print length($1)+1}')
  q_pos=$(expr $q_pos + 1)
  name=$(echo "$1" | cut -c $q_pos-${#1})
  q_pos=$(expr $q_pos - 2)
  time=$(echo "$1" | cut -c 1-$q_pos)

  # classroom
  d_pos=$(echo $time | awk -F- '{print length($1)+1}')
  d_pos=$(expr $d_pos + 1)
  room=$(echo "$time" | cut -c $d_pos-${#time})
  d_pos=$(expr $d_pos - 2)
  time=$(echo "$time" | cut -c 1-$d_pos)

  # echo "$name"
  # echo "$time"
  # echo "$room"

  for i in $(seq ${#time}); do
    c=$(echo "$time" | cut -c $i-$i)
    # echo $c
    # weekday
    if_w=$(echo "$c" | grep '[1-7]')
    if [ "$if_w" != "" ]; then
      col=$c
    fi
    # time
    if echo "$c" | grep -q '[A-K]'; then
      row=$(get_time $c)
      if_w=$(echo "$col" | grep '[1-5]')
      if [ "$if_w" != "" ]; then
        fill_timetable $row $col "$name"
      fi
    fi

  done



}

# declare
weekday='Mon Tue Wed Thu Fri'
ex_weekday='Mon Tue Wed Thu Fri Sat Sun'
time_code='A B C D E F G H I J K'
ex_time_code='M N A B C D X E F G H Y I J K L'
grid_width=14

# declare array
for r in $(seq 11); do
  for c in $(seq 5); do
    for l in $(seq 4); do
      eval "timetable_${r}_${c}_${l}='###############'"
    done
  done
done

# main =====

while read p; do
  echo "$1"
  parse_class "$p"
done < $1

print_table
