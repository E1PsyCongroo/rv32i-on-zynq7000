#include <nvboard.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <Vtop.h>
// #define TRACE

static Vtop* top;

#ifdef TRACE
VerilatedContext* contextp = NULL;
VerilatedVcdC* tfp = NULL;

void step_and_dump_wave(){
  top->clk = !top->clk;
  top->eval();
  contextp->timeInc(1);
  tfp->dump(contextp->time());
}

void sim_init(){
  Verilated::traceEverOn(true);
  contextp = new VerilatedContext;
  tfp = new VerilatedVcdC;
  contextp->traceEverOn(true);
  top->trace(tfp, 0);
  tfp->open("./build/dump.vcd");
  top->clk = 0;
}

void sim_exit(){
  step_and_dump_wave();
  tfp->close();
}

#define wait_clk(N) {for(int i = 0; i < (N); i++) step_and_dump_wave();}

void kbd_sendcode(char code) {
  const char tmp0 = code & 0xff;
  const char tmp1 = tmp0 ^ (tmp0 >> 4);
  const char tmp2 = tmp1 ^ (tmp1 >> 2);
  const char tmp3 = tmp2 ^ (tmp2 >> 1);
  const int kdb_clk_period = 60;
  int send_buffer;
  send_buffer = 0;
  send_buffer |= tmp0 << 1;
  send_buffer |= (~tmp3 & 0x1) << 9;
  send_buffer |= 1 << 10;
  for (int i = 0; i < 11; i++) {
    top->ps2_data = (send_buffer >> i) & 0x1;
    wait_clk(kdb_clk_period / 2); top->ps2_clk = 0;
    wait_clk(kdb_clk_period / 2); top->ps2_clk = 1;
  }
}

void sim() {
  sim_init();

  top->ps2_clk = 1;
  top->rst = 1; wait_clk(20);
  top->rst = 0; wait_clk(20);
  kbd_sendcode(0x1C); // press 'A'
  wait_clk(20);
  assert(top->code == 0x1C);
  kbd_sendcode(0xF0); // break code
  wait_clk(20);
  assert(top->code == 0x0);

  sim_exit();
}

#else
void nvboard_bind_all_pins(TOP_NAME* top);

static void single_cycle() {
  top->clk = 0; top->eval();
  top->clk = 1; top->eval();
}
#endif

int main(int argc, char** argv) {
  top = new Vtop;
#ifdef TRACE
  sim();
#else
  nvboard_bind_all_pins(top);
  nvboard_init();
  while(1) {
    single_cycle();
    nvboard_update();
  }
  nvboard_quit();
#endif
}