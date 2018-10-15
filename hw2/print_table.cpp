#include<iostream>
#include <iomanip>
#include <string>
using namespace std;

std::string weekdays[] = { "Mon", "Tue", "Wed", "Thu", "Fri" };

void print_table() {
   cout << "| " << std::left << setw(15) << "id" << "|  " << std::left << setw(18) << "type" << "|  " << std::left << setw(10) << "scope" << "|" << endl;
   cout << "x  " <<
}

int main(int argc, char const *argv[]) {
  print_table();
  return 0;
}
