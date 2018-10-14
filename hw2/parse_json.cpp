# include <iostream>
#include<iostream>
#include<fstream>
#include<string>
#include<vector>


#define SIZE 1000
// { and } => 'START_OBJECT' and 'END_OBJECT'
#define START_OBJ '{'
#define END_OBJ '}'
// [ and ] => 'START_ARRAY' and 'END_ARRAY'
#define START_ARRAY '['
#define END_ARRAY ']'

char line[SIZE];

using namespace std;

void get_value(string str, std::size_t pos) {
  int semi_colon_count = 0;
  while (str[pos] != 0) {
    pos++;
    if (str[pos] == '"'){
      semi_colon_count++;
      if (semi_colon_count == 2)
        continue;
      if (semi_colon_count == 3){
        cout << endl;
        break;
      }
    }
    if (semi_colon_count == 2)
      cout << str[pos];
  }
}

void parse_json(string str){
  string token[] = { "cos_id", "cos_time", "cos_ename"};

  // course id
  for (int i = 0; i < 3; i++) {
    std::size_t pos = str.find(token[i]);
    if(pos < str.length()) {
      get_value(str, pos);
    }
  }
}

int main() {
  fstream fin;
    fin.open("timetable.json",ios::in);
    while(fin.getline(line,sizeof(line),'\n')){
        parse_json(line);
    }
  return 0;
}
