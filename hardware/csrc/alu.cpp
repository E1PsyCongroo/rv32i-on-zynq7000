#include <verilated.h>
#include <verilated_vcd_c.h>
#include <Valu.h>
#include <stdio.h>
#include <assert.h>

#define Assert(cond) sim_exit(); assert(cond);

static Valu* top;

VerilatedContext* contextp = NULL;
VerilatedVcdC* tfp = NULL;

void step_and_dump_wave(){
  top->eval();
  contextp->timeInc(1);
  tfp->dump(contextp->time());
}

void sim_init(){
  srand(time(0));
  contextp = new VerilatedContext;
  tfp = new VerilatedVcdC;
  top = new Valu;
  contextp->traceEverOn(true);
  top->trace(tfp, 0);
  tfp->open("./build/verilator/dump_alu.vcd");
}

void sim_exit(){
  step_and_dump_wave();
  tfp->close();
}

enum OPCODE {
  OP_ADD      = 0b0000,
  OP_SUB      = 0b1000,
  OP_SLL      = 0b0001,
  OP_SLT      = 0b0010,
  OP_SLTU     = 0b0011,
  OP_XOR      = 0b0100,
  OP_OR       = 0b0110,
  OP_AND      = 0b0111,
  OP_SRL      = 0b0101,
  OP_SRA      = 0b1101
};

static vluint32_t op_add(vluint32_t a, vluint32_t b) {
  return a + b;
}

static vluint32_t op_sub(vluint32_t a, vluint32_t b) {
  return a - b;
}

static vluint32_t op_sll(vluint32_t a, vluint32_t b) {
  return a << (b & 0b11111);
}

static vluint32_t op_slt(vluint32_t a, vluint32_t b) {
  return (vlsint32_t)a < (vlsint32_t)b;
}

static vluint32_t op_sltu(vluint32_t a, vluint32_t b) {
  return a < b;
}

static vluint32_t op_xor(vluint32_t a, vluint32_t b) {
  return a ^ b;
}

static vluint32_t op_or(vluint32_t a, vluint32_t b) {
  return a | b;
}

static vluint32_t op_and(vluint32_t a, vluint32_t b) {
  return a & b;
}

static vluint32_t op_srl(vluint32_t a, vluint32_t b) {
  return a >> (b & 0b11111);
}

static vluint32_t op_sra(vluint32_t a, vluint32_t b) {
  return (vlsint32_t)a >> (b & 0b11111);
}


struct {
  OPCODE opcode;
  vluint32_t (*op)(vluint32_t, vluint32_t);
  char* string;
} aluop[] = {
  { OP_ADD,   op_add,   "ADD" },
  { OP_SUB,   op_sub,   "SUB" },
  { OP_SLL,   op_sll,   "SLL" },
  { OP_SLT,   op_slt,   "SLT" },
  { OP_SLTU,  op_sltu,  "SLTU" },
  { OP_XOR,   op_xor,   "XOR" },
  { OP_OR,    op_or,    "OR" },
  { OP_AND,   op_and,   "AND" },
  { OP_SRL,   op_srl,   "SRL" },
  { OP_SRA,   op_sra,   "SRA" },
};

static void printBinary(vluint32_t n) {
  int numBits = sizeof(n) * 8;
  vluint32_t mask = 1 << (numBits - 1); // 创建一个最高位为1的掩码

  for (int i = 0; i < numBits; i++) {
    // 根据掩码的结果打印 0 或 1
    printf("%d", (n & mask) ? 1 : 0);
    // 将掩码右移一位
    mask >>= 1;

    // 每4位插入一个空格（可选）
    if ((i + 1) % 4 == 0) {
        printf(" ");
    }
  }
}

void sim() {
  sim_init();

  vluint32_t ina, inb;
  vluint32_t expected_out;

  for (int i = 0; i < 10000; i++) {
    ina = rand();
    inb = rand();
    if (rand() % 2) {
      ina = -ina;
    }
    if (rand() % 2) {
      inb = -inb;
    }
    top->ina = ina;
    top->inb = inb;
    for (int i = 0; i < (sizeof aluop) / (sizeof aluop[0]); i++) {
      top->op = aluop[i].opcode;
      expected_out = aluop[i].op(ina, inb);
      step_and_dump_wave();
      if (expected_out != top->out) {
        printf("ina: ");
        printBinary(ina);
        putchar('\n');
        printf("inb: ");
        printBinary(inb);
        putchar('\n');
        printf("op: %s\n", aluop[i].string);
        printf("expected_out: ");
        printBinary(expected_out);
        putchar('\n');
        printf("get: ");
        printBinary(top->out);
        putchar('\n');
        Assert(expected_out == top->out);
      }
    }
  }

  sim_exit();
}

int main(int argc, char** argv) {
  sim();
}