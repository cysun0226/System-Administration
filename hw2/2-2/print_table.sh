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

get_ex_time()
{
  case $1 in
    M) echo 1 ;;
    N) echo 2 ;;
    A) echo 3 ;;
    B) echo 4 ;;
    C) echo 5 ;;
    D) echo 6 ;;
    X) echo 7 ;;
    E) echo 8 ;;
    F) echo 9 ;;
    G) echo 10 ;;
    H) echo 11 ;;
    Y) echo 12 ;;
    I) echo 13 ;;
    J) echo 14 ;;
    K) echo 15 ;;
    L) echo 16 ;;
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

print_extra_table()
{
  print_bar $(expr $grid_width \* 7 + 32)
  printf '   '
  for d in $ex_weekday; do
    printf '| '
    printf '%s' $d
    get_space $(expr $grid_width - 1)
    if [ "$d" = 'Sun' ] ; then
      printf '|\n'
    fi
  done
  print_dbar $(expr $grid_width \* 7 + 32)

  t_idx=0
  for t in $ex_time_code; do
    t_idx=$(expr $t_idx + 1)
    # time row
    printf ' %s' $t
    for w in $(seq 7); do
      printf ' | '
      get_3d_value ex_timetable "_$t_idx" "_$w" _1
    done
    printf ' |\n'

    # grid
    for g in 2 3 4; do
      printf '  '
      for w in 1 2 3 4 5 6 7; do
        printf ' | '
        get_3d_value ex_timetable "_$t_idx" "_$w" "_$g"
      done
      printf ' |\n'
    done
    print_bar $(expr $grid_width \* 7 + 32)
  done
}

fill_timetable()
{
  # $1 row / $2 col / $3 name
  # check_conflict
  if [ "$show_extra" != "1" ]
  then
    u=$(get_3d_value timetable "_$row" "_$col" "_1")
    if [ "$u" != "###############" ]; then
      conflict=1
    fi
  else
    u=$(get_3d_value ex_timetable "_$row" "_$col" "_1")
    if [ "$u" != "############" ]; then
      conflict=1
    fi
  fi

  if [ "$check_conflict" != "0" ]; then
    if [ "$show_extra" != "1" ]; then
      eval "timetable_${row}_${col}_1=0"
    else
      eval "ex_timetable_${row}_${col}_1=0"
    fi
    return
  fi

  # fill

  lc=$(expr ${#3} / $grid_width + 1)

  for i in $(seq $lc); do
    grid_row=''
    # i*GRID_LEN
    igl=$(expr $i \* $grid_width - $grid_width + $i )
    # (i+1)*GRID_LEN
    ipl=$(expr $i \* $grid_width )
    if [ ${#3} -gt $ipl ];
    then
      grid_row=$(echo "$3" | cut -c $igl-$(expr $igl + $grid_width))
    else
      grid_row=$(echo "$3" | cut -c $igl-$(expr ${#3} + 1 ))
    fi

    # fill the row
    if [ "$grid_row" = "" ]; then
      break;
    fi
    grid_row="$grid_row###############"
    grid_row=$(echo $grid_row | cut -c 1-$(expr $grid_width + 1))

    if [ "$show_extra" = "0" ];
    then
      eval "timetable_${row}_${col}_${i}=\"$grid_row\""
    else
      eval "ex_timetable_${row}_${col}_${i}=\"$grid_row\""
    fi
  done
}

parse_class()
{
  id=$(echo $1 | cut -d'#' -f1)
  x_time=$(echo $1 | cut -d'#' -f2 | cut -d'?' -f1)
  time_cnt=$(echo $x_time | grep -o '-' | wc -l)
  time=''
  for t in $(seq $time_cnt); do
    time="$time$(echo $x_time | cut -d',' -f$t | cut -d'-' -f1)"
    if [ "$t" = "1" ]; then
      room="$(echo $x_time | cut -d',' -f$t | cut -d'-' -f2)"
    else
      room="$room, $(echo $x_time | cut -d',' -f$t | cut -d'-' -f2)"
    fi
  done

  if [ "$show_classroom" = "0" ];
  then
    name=$(echo $1 | cut -d'?' -f2)
  else
    name="$room"
  fi

  for i in $(seq ${#time}); do
    c=$(echo "$time" | cut -c $i-$i)
    # weekday
    if_w=$(echo "$c" | grep '[1-7]')
    if [ "$if_w" != "" ]; then
      col=$c
    fi
    # time
    if echo "$c" | grep -q '[A-K]'; then
      if [ "$show_extra" != "1" ];
      then
        row=$(get_time $c)
      else
        row=$(get_ex_time $c)
      fi

      if [ "$show_extra" != "1" ]; then
        if_w=$(echo "$col" | grep '[1-5]')
      else
        if_w=$(echo "$col" | grep '[1-7]')
      fi

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
show_classroom=0
show_extra=0
conflict=0
check_conflict=0

# declare array
init()
{
  if [ "$show_extra" = "0" ];
  then
    for r in $(seq 11); do
      for c in $(seq 5); do
        for l in $(seq 4); do
          eval "timetable_${r}_${c}_${l}='###############'"
        done
      done
    done
  else
    grid_width=11
    for r in $(seq 16); do
      for c in $(seq 7); do
        for l in $(seq 4); do
          eval "ex_timetable_${r}_${c}_${l}='############'"
        done
      done
    done
  fi
}

# main =====
# $1: cur_class.txt
# $2: show_classroom
# $3: show_extra
# $4: check_conflict

show_classroom="$2"
show_extra="$3"
check_conflict="$4"
init

while read p; do
  parse_class "$p"
done < $1

if [ "$check_conflict" != "0" ];
then
  if [ "$conflict" != "0" ];
  then
    echo "conflict"
  else
    echo "pass"
  fi
else
  if [ "$show_extra" != "1" ];
  then
    print_table
  else
    print_extra_table
  fi
fi
