#!/bin/sh

get_2d_value()
{
  current_value=$1$2$3
  eval echo \$$current_value
}

get_3d_value()
{
  current_value=$1$2$3$4
  eval echo "\$$current_value"
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
    if $d = 'Fri' ; then
      printf '|\n'
    fi
  done
  print_dbar $(expr $grid_width \* 5 + 19)

  # for t in $time_code; do
  #
  # done



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
      eval "timetable_${r}_${c}_${l}='#############.'"
    done
  done
done

# main =====
print_table
