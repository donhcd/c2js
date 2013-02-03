#include <stdio.h>
int fib(int i) {
  int f1=0;
  int f2=1;
  int q=0;
  while (q<i-1) {
    int tmp = f2;
    f2 = f1+f2;
    f1 = tmp;
    q = q+1;
  }
  return f1;
}
int main(){
  printf("%d",fib(7));
  return 0;
}

