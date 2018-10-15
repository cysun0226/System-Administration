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
#define CLASSES_FILE "classes.txt"

char line[SIZE];
std::fstream f_out;

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
        f_out << "  ";
        //cout << endl;
        break;
      }
    }
    if (semi_colon_count == 2)
      f_out << str[pos];
      //cout << str[pos];
  }
}

void parse_json(string str){
  string token[] = { /*"cos_id",*/ "cos_time", "cos_ename"};
  for (int i = 0; i < 2; i++) {
    std::size_t pos = str.find(token[i]);
    if(pos < str.length()) {
      get_value(str, pos);
      if(i == 1)
        f_out << endl;
    }
  }
}

int main(int argc, char *argv[]) {
  fstream fin;
	f_out.open(argv[2], ios::out);
	if(!f_out)
		cout<<"Fail to open file: "<<CLASSES_FILE<<endl;

    fin.open(argv[1],ios::in);
    while(fin.getline(line,sizeof(line),'\n')){
        parse_json(line);
    }

  f_out.close();
  return 0;
}
