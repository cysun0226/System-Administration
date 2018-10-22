#include<iostream>
#include <iomanip>
#include <string>
#include <fstream>
#include <vector>
#include <map>
#include <iterator>
using namespace std;
#define SIZE 100

std::string weekdays[] = { "Mon", "Tue", "Wed", "Thu", "Fri" };
std::string ex_weekdays[] = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" };
std::string time_code[] = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K" };
char ex_time_code[] = { 'M', 'N', 'A', 'B', 'C', 'D', 'X', 'E', 'F', 'G', 'H', 'Y', 'I', 'J', 'K', 'L' };
map<char, int> ex_time_map;
std::string timetable[11][5][4];
bool timetable_used[11][5];
std::string roomtable[11][5][4];
std::string ex_timetable[16][7][4];
bool ex_timetable_used[16][7];
std::string ex_roomtable[16][7][4];
char line[SIZE];
bool show_classroom = false;
bool show_extra = false;
bool time_conflict = false;
int GRID_LEN = 14;

void print_bar(int len) {
  for (int i = 0; i < len; i++) {
    cout << '-';
  }
  cout << endl;
}

void print_dbar(int len) {
  for (int i = 0; i < len; i++) {
    cout << '=';
  }
  cout << endl;
}

string get_space(int len) {
  string s;
  for (int i = 0; i < len; i++) {
    s += " ";
  }
  return s;
}

void print_table() {
   // title
   print_bar(GRID_LEN*5+19);
   cout << "   ";
   for (int i = 0; i < 5; i++) {
     cout << "| ";
     cout << weekdays[i];
     cout << get_space(GRID_LEN-2);
     if (i == 4)
       cout << "|" << endl;
   }
   print_dbar(GRID_LEN*5+19);

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
     print_bar(GRID_LEN*5+19);
   }
}

void print_extra_table() {
   // title
   print_bar(GRID_LEN*7+25);
   cout << "   ";
   for (int i = 0; i < 7; i++) {
     cout << "| ";
     cout << ex_weekdays[i];
     for (int s = 0; s < GRID_LEN-2; s++) { cout << " "; }
     if (i == 6)
       cout << "|" << endl;
   }
   print_dbar(GRID_LEN*7+25);

   for (int t = 0; t < 16; t++) {
     // time_row
     cout << " " << ex_time_code[t] << " ";
     for (int w = 0; w < 7; w++) {
       cout << "| " << ex_timetable[t][w][0] << " ";
     }
     cout << "|" << endl;
     // grid
     for (int g = 1; g < 4; g++) {
       cout << "   ";
       for (int w = 0; w < 7; w++) {
         cout << "| " << ex_timetable[t][w][g] << " ";
       }
       cout << "|" << endl;
     }
     print_bar(GRID_LEN*7+25);
   }
}

void fill_timetable(int row, int col, string class_name) {
  for (int i = 0; i <= class_name.length()/GRID_LEN; i++) {
    string grid_row;
    if (class_name.length()>(i+1)*GRID_LEN) {
      grid_row = class_name.substr(i*GRID_LEN, GRID_LEN);
    }
    else{
      grid_row = class_name.substr(i*GRID_LEN, class_name.length()-i*GRID_LEN);
      for (int s = 0; s < (i+1)*GRID_LEN-class_name.length(); s++)
        grid_row += " ";
    }

    if (show_extra){
      if (ex_timetable_used[row][col] && i == 0)
        time_conflict = true;
      ex_timetable[row][col][i] = grid_row;
      ex_timetable_used[row][col] = true;
    }
    else{
      if (timetable_used[row][col] && i == 0)
        time_conflict = true;
      timetable[row][col][i] = grid_row;
      timetable_used[row][col] = true;
    }
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
    if (class_time[i] >= '1' && class_time[i] <= '7')
      col = class_time[i] - '1';
    // extra
    if (show_extra){
      // time
      std::map<char, int>::iterator iter;
      iter = ex_time_map.find(class_time[i]);
      if(iter != ex_time_map.end()) {
        row = ex_time_map[class_time[i]];
        if (show_classroom)
          fill_timetable(row, col, classroom);
        else
          fill_timetable(row, col, class_name);
      }
      continue;
    }

    // time
    if (class_time[i] >= 'A' && class_time[i] <= 'K' && col <5) {
      row = class_time[i] - 'A';
      if (show_classroom)
        fill_timetable(row, col, classroom);
      else
        fill_timetable(row, col, class_name);
    }
  }
}

void init_table() {
  if (show_extra)
    GRID_LEN -= 2;

  for (int r = 0; r < 11; r++)
    for (int c = 0; c < 5; c++){
      timetable_used[r][c] = false;
      for (int i = 0; i < 4; i++)
        timetable[r][c][i] = get_space(GRID_LEN);
    }


  for (int r = 0; r < 16; r++)
    for (int c = 0; c < 7; c++){
      ex_timetable_used[r][c] = false;
      for (int i = 0; i < 4; i++)
        ex_timetable[r][c][i] = get_space(GRID_LEN);
    }


  for (int i = 0; i < 16; i++) {
    ex_time_map[ex_time_code[i]] = i;
  }
}

int main(int argc, char const *argv[]) {
  std::vector<string> classes;
  fstream fin;
  fin.open(argv[1],ios::in);
  show_classroom = (argc > 2 && argv[2][0]=='1')? true : false;
  show_extra = (argc > 3 && argv[3][0]=='1')? true : false;

  init_table();
  while(fin.getline(line,sizeof(line),'\n')){
      parse_time(line);
  }

  if (time_conflict)
    cout << "conflict" << endl;
  else {
    if (!show_extra)
      print_table();
    else
      print_extra_table();
  }

  return 0;
}
