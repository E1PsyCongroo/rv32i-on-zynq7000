#include <nvboard.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <Vtop.h>

#define TRACE

#ifdef TRACE
VerilatedContext* contextp = NULL;
VerilatedVcdC* tfp = NULL;

static TOP_NAME* top;

void step_and_dump_wave(){
  top->eval();
  contextp->timeInc(1);
  tfp->dump(contextp->time());
}

void sim_init(){
  contextp = new VerilatedContext;
  tfp = new VerilatedVcdC;
  top = new TOP_NAME;
  contextp->traceEverOn(true);
  top->trace(tfp, 0);
  tfp->open("./build/dump.vcd");
}

void sim_exit(){
  step_and_dump_wave();
  tfp->close();
}

void sim() {
  sim_init();

  top->en = 0b0;
  for (int i = 0; i <= 0b11111111; i++) {
    top->in = i;
    step_and_dump_wave();
  }
  top->en = 0b1;
  for (int i = 0; i <= 0b11111111; i++) {
    top->in = i;
    step_and_dump_wave();
  }

  sim_exit();
}
#endif

void nvboard_bind_all_pins(TOP_NAME* top);

int main(int argc, char** argv) {
#ifdef TRACE
  sim();
#endif
  nvboard_bind_all_pins(top);
  nvboard_init();
  while(1) {
    top->eval();
    nvboard_update();
  }
  nvboard_quit();
}