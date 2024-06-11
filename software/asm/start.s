.section    .start
.global     _start

_start:

# Follow a convention
# x1 = result register 1
# x2 = result register 2
# x10 = argument 1 register
# x11 = argument 2 register
# x20 = flag register

# Test ADD
li x10, 100         # Load argument 1 (rs1)
li x11, 200         # Load argument 2 (rs2)
add x1, x10, x11    # Execute the instruction being tested
li x20, 1           # Set the flag register to stop execution and inspect the result register
                    # Now we check that x1 contains 300

# Test BEQ
li x2, 100          # Set an initial value of x2
beq x0, x0, branch1 # This branch should succeed and jump to branch1
li x2, 123          # This shouldn't execute, but if it does x2 becomes an undesirable value
branch1: li x1, 500 # x1 now contains 500
li x20, 2           # Set the flag register
                    # Now we check that x1 contains 500 and x2 contains 100

# TODO: add more tests here
li	x3,3
lui	x1,0xff01
addi	x1,x1,-16 # ff00ff0 <_start-0xff010>
lui	x2,0xf0f0f
addi	x2,x2,240 # f0f0f0f0 <_end+0xe0f0e0f0>
and	x14,x1,x2
lui	x7,0xf00
addi	x7,x7,240 # f000f0 <_start-0xf0fff10>
sub x1, x14, x7
li x20, 3

done: j done
