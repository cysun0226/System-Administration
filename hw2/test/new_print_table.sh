#!/bin/sh

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

  for t in $time_code; do
    # time row
    printf ' %s' $t
    for w in 1 2 3 4 5; do
      printf ' | '
      get_3d_value timetable "_$w" "_$t" _1
    done
    printf ' |\n'

    # grid
    for g in 2 3 4; do
      printf '  '
      for w in 1 2 3 4 5; do
        printf ' | '
        get_3d_value timetable "_$w" "_$t" "_$g"
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

  for t in $ex_time_code; do
    # time row
    printf ' %s' $t
    for w in $(seq 7); do
      printf ' | '
      get_3d_value timetable "_$w" "_$t" _1
    done
    printf ' |\n'

    # grid
    for g in 2 3 4; do
      printf '  '
      for w in 1 2 3 4 5 6 7; do
        printf ' | '
        get_3d_value timetable "_$w" "_$t" "_$g"
      done
      printf ' |\n'
    done
    print_bar $(expr $grid_width \* 7 + 32)
  done
}

fill_timetable()
{
  # $1 weekday / $2 time / $3 name
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

    eval "timetable_$1_$2_$i=\"$grid_row\""
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
    if [ "$if_w" != "" ];
    then
      day=$c
    else
      fill_timetable $day $c "$name"
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
  fill='###############'
  if [ "$show_extra" = "1" ]; then
    grid_width=11
    fill='############'
  fi

  for d in 1 2 3 4 5 6 7; do
    for t in M N A B C D X E F G H Y I J K L; do
      for l in 1 2 3 4; do
        eval "timetable_${d}_${t}_${l}=$fill"
      done
    done
  done
}

# main =====
# $1: cur_class.txt
# $2: show_classroom
# $3: show_extra

show_classroom="$2"
show_extra="$3"
init

while read p; do
  parse_class "$p"
done < $1

if [ "$show_extra" != "1" ];
then
  print_table
else
  print_extra_table
fi
