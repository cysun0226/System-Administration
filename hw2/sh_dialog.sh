#!/bin/sh -x

generate_list_item()
{
  filename='./data/cur_class.txt'
  while read p; do
    printf '"%s" ' "$p"
    printf '"%s" ' "$p"
    printf '"%s" ' "off"
  done < $filename
}

# main
eval dialog --buildlist '"Add a class"' 30 100 20 "$(generate_list_item)"
