#include <am.h>
#include <klib-macros.h>

extern char _heap_start;
int main(const char *args);

extern char _pmem_start;
#define PMEM_SIZE (128 * 1024 * 1024)
#define PMEM_END  ((uintptr_t)&_pmem_start + PMEM_SIZE)

Area heap = RANGE(&_heap_start, PMEM_END);
#ifndef MAINARGS
#define MAINARGS ""
#endif
static const char mainargs[] = MAINARGS;

#define URECV_CTRL (*((volatile uint32_t*)0x80000000) & 0x02)
#define URECV_DATA (*((volatile uint32_t*)0x80000004) & 0xff)

#define UTRAN_CTRL (*((volatile uint32_t*)0x80000000) & 0x01)
#define UTRAN_DATA (*((volatile uint32_t*)0x80000008))
void putch(char ch) {
  if (ch == '\n') {
    while (!UTRAN_CTRL) ;
    UTRAN_DATA = '\r';
    while (!UTRAN_CTRL) ;
    UTRAN_DATA = ch;
  } else {
    while (!UTRAN_CTRL) ;
    UTRAN_DATA = ch;
  }
}
char getch(void) {
  while (!URECV_CTRL) ;
  char ch = URECV_DATA;
  return ch;
}


void halt(int code) {
  while (1);
}

void _trm_init() {
  int ret = main(mainargs);
  halt(ret);
}
