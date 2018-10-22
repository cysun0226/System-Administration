#!/bin/sh -x

generate_list_item()
{
  while read p; do
    # id=$(echo $p | cut -d'#' -f1)
    time=$(echo $p | cut -d'#' -f2 | cut -d'?' -f1)
    name=$(echo $p | cut -d'?' -f2)

    printf '"%s" ' "$p"
    printf '"%s - %s" ' "$time" "$name"
    printf '"%s" ' "off"

  done < $1
}

add_class()
{
  usr_input=$(eval dialog --buildlist '"Add a class"' 30 100 20 "$(generate_list_item ./data/n_class.txt)" --output-fd 1)
  # cancel
  if [ "$usr_input" = "" ]; then
    return
  fi
  cur_class=$(sed 's@\\@@g' <<< $usr_input)
  eval 'for word in '$cur_class'; do echo $word; done'

}


# main
# generate_list_item ./data/n_class.txt
# eval dialog --buildlist '"Add a class"' 30 100 20 "$(generate_list_item ./data/n_class.txt)"
add_class
