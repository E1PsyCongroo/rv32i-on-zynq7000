#include <nvboard.h>
#include <Vtop.h>
#define TRACE 0
static TOP_NAME top;
static VerilatedContext* contextp = NULL;
static VerilatedVcdC* tfp = NULL;

void step_and_dump_wave(){
  top.eval();
  contextp->timeInc(1);
  tfp->dump(contextp->time());
}

void sim_init(){
  contextp = new VerilatedContext;
  tfp = new VerilatedVcdC;
  contextp->traceEverOn(true);
  top.trace(&tfp, 0);
  tfp->open("dump.vcd");
}

void sim_exit(){
  step_and_dump_wave();
  tfp->close();
}

int sim() {
  sim_init();
  sim_exit();
}

void nvboard_bind_all_pins(TOP_NAME* top);

int main(int argc, char** argv) {
  nvboard_bind_all_pins(&top);
  nvboard_init();
#ifdef TRACE
  sim();
#endif
  while(1) {
    top.eval();
    nvboard_update();
  }
  nvboard_quit();
}