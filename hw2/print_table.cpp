#include<iostream>
#include <iomanip>
#include <string>
#include <fstream>
#include <vector>
using namespace std;
#define SIZE 100

std::string weekdays[] = { "Mon", "Tue", "Wed", "Thu", "Fri" };
std::string time_code[] = { "A", "B", "C", "D", "E", "F", "G", "H","I", "J", "K" };
std::string timetable[11][5][4];
std::string roomtable[11][5][4];
char line[SIZE];
bool show_classroom = false;


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
       cout << "| " << timetable[t][w][0] << " ";
     }
     cout << "|" << endl;
     // grid
     for (int g = 1; g < 4; g++) {
       cout << "   ";
       for (int w = 0; w < 5; w++) {
         cout << "| " << timetable[t][w][g] << " ";
       }
       cout << "|" << endl;
     }
     print_bar();
   }
}

void fill_timetable(int row, int col, string class_name) {
  // cout << "class_name = " << class_name << endl;
  // cout << "class_name.length() = " << class_name.length() << endl;
  for (int i = 0; i <= class_name.length()/15; i++) {
    string grid_row;
    if (class_name.length()>(i+1)*15) {
      // cout << "range = " << i*13 << ", " << (i+1)*13-1 << endl;
      grid_row = class_name.substr(i*15, 15);
      // cout << grid_row.length() << endl;
    }
    else{
      grid_row = class_name.substr(i*15, class_name.length()-i*15);
      for (int s = 0; s < (i+1)*15-class_name.length(); s++)
        grid_row += " ";
    }

    timetable[row][col][i] = grid_row;
    // cout << "timetable[" << row << "][" << col << "][" << i << "] = " << endl;
    // cout << grid_row << endl;
  }
}


void parse_time(string c) {
  int pos = c.find('-');
  string classroom = c.substr(pos+1, c.length());
  // classroom
  int sec_pos = classroom.find('-');
  classroom = classroom.substr(0, sec_pos-1);
  // time

  string class_time = c.substr(0, pos);
  c = c.substr(pos+1, c.length()-1);
  pos = c.find('-');
  string class_name = c.substr(pos+2, c.length()-1);

  int row, col;
  for (int i = 0; i < class_time.length(); i++) {
    // weekday
    if (class_time[i] >= '1' && class_time[i] <= '5') {
      col = class_time[i] - '1';
    }
    // time
    if (class_time[i] >= 'A' && class_time[i] <= 'K') {
      row = class_time[i] - 'A';
      if (show_classroom)
        fill_timetable(row, col, classroom);
      else
        fill_timetable(row, col, class_name);
    }
  }
}

void init_table() {
  for (int r = 0; r < 11; r++) {
    for (int c = 0; c < 5; c++) {
      for (int i = 0; i < 4; i++) {
        timetable[r][c][i] = "               ";
      }
    }
  }
}

int main(int argc, char const *argv[]) {
  std::vector<string> classes;
  fstream fin;
  fin.open(argv[1],ios::in);
  show_classroom = (argc > 2)? true : false;
  init_table();
  while(fin.getline(line,sizeof(line),'\n')){
      parse_time(line);
  }
  print_table();
  return 0;
}
