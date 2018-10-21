#!/bin/sh

get_2d_value()
{
  current_value=$1$2$3
  eval printf '%s' \$$current_value
}

get_3d_value()
{
  current_value=$1$2$3$4
  eval printf '%s' "\$$current_value"
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
  print_bar $(expr $grid_width \* 5 + 19)
  printf '   '
  for d in $weekday; do
    printf '| '
    printf '%s' $d
    get_space $(expr $grid_width - 2)
    if [ "$d" = 'Fri' ] ; then
      printf '|\n'
    fi
  done
  print_dbar $(expr $grid_width \* 5 + 19)

  t_idx=0
  for t in $time_code; do
    t_idx=$(expr $t_idx + 1)
    # time row
    printf ' %s ' $t
    for w in $(seq 5); do
      printf '| '
      get_3d_value timetable "_$t_idx" "_$w" _1
    done
    printf '|\n'

    # grid
    for g in 2 3 4; do
      printf '   '
      for w in 1 2 3 4 5; do
        printf '| '
        get_3d_value timetable "_$t_idx" "_$w" "_$g"
      done
      printf '|\n'
    done
    print_bar $(expr $grid_width \* 5 + 19)
  done
}

parse_class()
{
  q_pos=$(echo $1 | awk -F? '{print length($1)+1}')
  e_pos=$(echo -n $1 | wc -m)
  q_pos=$(expr $q_pos + 1)
  name=$(echo $1 | cut -c $q_pos-26)
  q_pos=$(expr $q_pos - 2)
  time=$(echo $1 | cut -c 1-$q_pos)

  echo $time
  echo $name
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
class_file='sample.txt'

parse_class '4CD-SC207?Calculus (I)'

# while read p; do
#   echo $p
# done < $class_file
