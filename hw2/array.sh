#!/bin/sh
# ARRAY.sh: example usage of arrays in Bourne Shell

array_traverse()
{
    for i in $(seq 1 $2)
    do
    current_value=$1$i
    echo $(eval echo \$$current_value)
    done
    return 1
}

get_array_value()
{
  current_value=$1$2
  echo $(eval echo \$$current_value)
}

get_2d_value()
{
  current_value=$1$2$3
  echo $(eval echo \$$current_value)
}

get_3d_value()
{
  current_value=$1$2$3$4
  eval echo "\$$current_value"
  # echo $(eval echo \$$current_value)
}

# ARRAY_1=one
# ARRAY_2=two
# ARRAY_3=333

for i in $(seq 10); do
  eval "ARRAY_$i=$i"
done

# declare weekdays
weekday='Mon Tue Wed Thu Fri Sat Sun'
time_code='A B C D E F G H I J K'
ex_time_code='M N A B C D X E F G H Y I J K L'
# for d in $weekday; do
#   echo $d
# done


# declare array
for (( i = 0; i < 7; i++ )); do
  eval "wd_$i=$i"
done

for (( r = 0; r < 11; r++ )); do
  for (( c = 0; c < 5; c++ )); do
    for (( l = 0; l < 4; l++ )); do
      eval "timetable_${r}_${c}_${l}='#############.'"
    done
  done
done



ARRAY_3_1=zzz
# timetable_0_2_3=yeah

# get_2d_value timetable _4 _1 _2
get_3d_value timetable_ 0 _2 _3
# get_3d_value timetable_ 0 _2 _3

# get_array_value ARRAY_ 3



# array_traverse ARRAY_ 3
