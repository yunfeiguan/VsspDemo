// CPP program to traverse a map using range
// based for loop
#include <iostream>
#include <map>
using namespace std;
 
int main()
{
    int arr[] = { 1, 1, 2, 1, 1, 3, 4, 3 };
    int n = sizeof(arr) / sizeof(arr[0]);
    
    cout << "n is : " << n << endl;
    map<int, int> m;
    for (int i = 0; i < n; i++)
        m[arr[i]]++;
 
    cout << "Element  Frequency" << endl;
    for (auto i : m) {
        cout << i.first << "   " << i.second
             << endl;
        if (i.first == 2) {
            m.erase(3);
        }
    }

    cout << "error printing" << endl;
    for (map<int, int>::iterator p = m.begin(); p != m.end();) {
        int key = p->first;
        cout<< p->first << "    " << p->second << endl; 
        
        //++p; //should point to new iterator here
        if (key == 3)
            m.erase(key+1);
        ++p; //error used of iterator
    }

    cout << "second pring" << endl;
     for (auto &i : m)
         cout << i.first << "   " << i.second 
         << endl;

     return 0;
}
