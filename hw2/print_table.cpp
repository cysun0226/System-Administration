#include<iostream>
#include <iomanip>
#include <string>
#include <fstream>
#include <vector>
using namespace std;
#define SIZE 100

std::string weekdays[] = { "Mon", "Tue", "Wed", "Thu", "Fri" };
std::string time_code[] = { "A", "B", "C", "D", "E", "F", "G", "H","I", "J", "K" };
std::string timetable[11][5];
char line[SIZE];

void print_bar() {
  for (int i = 0; i < 94; i++) {
    cout << '-';
  }
  cout << endl;
}

void print_dbar() {
  for (int i = 0; i < 94; i++) {
    cout << '=';
  }
  cout << endl;
}

int time_to_int(char t){
  return t - 65;
}

int day_to_int(string d){
  if (d == "Mon")
    return 0;
  if (d == "Tue")
    return 1;
  if (d == "Wed")
    return 2;
  if (d == "Thu")
    return 3;
  if (d == "Fri")
    return 4;
  return -1;
}

void print_table() {
   // title
   print_bar();
   cout << "   ";
   for (int i = 0; i < 5; i++) {
     cout << "| ";
     cout << weekdays[i];
     cout << "             ";
     if (i == 4)
       cout << "|" << endl;
   }
   print_dbar();

   for (int t = 0; t < 11; t++) {
     // time_row
     cout << " " << time_code[t] << " ";
     for (int w = 0; w < 5; w++) {
       cout << "|" << "x.";
       for (int i = 0; i < 15; i++) {
         cout << " ";
       }
     }
     cout << "|" << endl;
     // grid
     for (int g = 0; g < 3; g++) {
       cout << "   ";
       for (int w = 0; w < 5; w++) {
         cout << "|" << ".";
         for (int i = 0; i < 16; i++) {
           cout << " ";
         }
       }
       cout << "|" << endl;
     }
     print_bar();
   }
}

void fill_timetable(string c) {
  cout << c << endl;
}

int main(int argc, char const *argv[]) {
  std::vector<string> classes;
  fstream fin;
  fin.open(argv[1],ios::in);
  while(fin.getline(line,sizeof(line),'\n')){
      fill_timetable(line);
  }
  // print_table();


  return 0;
}
