#include<iostream>
#include <iomanip>
#include <string>
using namespace std;

std::string weekdays[] = { "Mon", "Tue", "Wed", "Thu", "Fri" };

void print_bar() {
  for (int i = 0; i < 80; i++) {
    /* code */
  }
}

void print_table() {
   // title
   cout << "x  ";
   for (int i = 0; i < 5; i++) {
     cout << '.';
     cout << weekdays[i];
     if (i == 4){
       cout << endl;
       break;
     }
     cout << "              ";
   }
}

int main(int argc, char const *argv[]) {
  print_table();
  return 0;
}
