#!/bin/sh -x

generate_list_item()
{
  # added_class
  added_id=''
  while read a; do
    added_id="$added_id $(echo $a | cut -d'#' -f1)"
  done < ./data/cur_class.txt

  while read p; do
    id=$(echo $p | cut -d'#' -f1)
    time=$(echo $p | cut -d'#' -f2 | cut -d'?' -f1)
    name=$(echo $p | cut -d'?' -f2)

    on_off='off'

    for a in $added_id; do
      if [ "$id" = "$a" ]; then
        on_off='on'
        break
      fi
    done

    printf '"%s" ' "$p"
    printf '"%s - %s" ' "$time" "$name"
    printf '"%s" ' "$on_off"
  done < $1
}


# add_class()
# {
#   usr_input=$(eval dialog --buildlist '"Add a class"' 30 100 20 "$(generate_list_item ./data/n_class.txt)" --output-fd 1)
#   # cancel
#   if [ "$usr_input" = "" ]; then
#     return
#   fi
#   cur_class=$(sed 's@\\@@g' <<< $usr_input)
#   eval 'for word in '$cur_class'; do echo $word; done' > ./data/ncur_class.txt
# }


# main
# generate_list_item ./data/classes.txt
eval dialog --buildlist '"Add a class"' 30 100 20 "$(generate_list_item ./data/classes.txt)"
# add_class
