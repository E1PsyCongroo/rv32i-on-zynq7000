#include <am.h>

#define TIMERLOW  (*((volatile uint32_t*)0x80000018))
#define TIMERHIGH (*((volatile uint32_t*)0x8000001C))
static uint64_t init_us;
void __am_timer_init() {
  init_us = TIMERHIGH;
  init_us = (init_us << 32) + TIMERLOW;
}

void __am_timer_uptime(AM_TIMER_UPTIME_T *uptime) {
  uint64_t current_us = TIMERHIGH;
  uptime->us = (current_us << 32) + TIMERLOW - init_us;
}

void __am_timer_rtc(AM_TIMER_RTC_T *rtc) {
  rtc->second = 0;
  rtc->minute = 0;
  rtc->hour   = 0;
  rtc->day    = 0;
  rtc->month  = 0;
  rtc->year   = 1900;
}
