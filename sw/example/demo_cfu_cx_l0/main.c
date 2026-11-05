// ================================================================================ //
// The NEORV32 RISC-V Processor - https://github.com/stnolting/neorv32              //
// Copyright (c) NEORV32 contributors.                                              //
// Copyright (c) 2020 - 2026 Stephan Nolting. All rights reserved.                  //
// Licensed under the BSD-3-Clause license, see LICENSE for details.                //
// SPDX-License-Identifier: BSD-3-Clause                                            //
// ================================================================================ //


/**********************************************************************//**
 * @file demo_cfu_modified/main.c
 * @brief Example program showing how to use the CFU's custom instructions
 * (XTEA example). Take a look at the commented "hardware-counterpart" of
 * this CFU example in 'rtl/core/neorv32_cpu_cp_cfu.vhd'.
 **************************************************************************/
#include <neorv32.h>

/**********************************************************************//**
 * @name User configuration
 **************************************************************************/
/**@{*/
/** UART BAUD rate */
#define BAUD_RATE   19200
/**@}*/
#define RTE_TERM_HL_ON  "\033[1;31m" // enable highlighting
#define RTE_TERM_HL_OFF "\033[0m"    // restore default

/**********************************************************************//**
 * @name Define XTEA CFU instruction based on the intrinsic templates
 **************************************************************************/
/**@{*/
//cxu 0 (arithmetic)
#define test_addi_hw(rs1, imm12) RISCV_INSTR_I_TYPE(RISCV_OPCODE_CUSTOM1, 0b000, rs1, imm12)
#define test_subi_hw(rs1, imm12) RISCV_INSTR_I_TYPE(RISCV_OPCODE_CUSTOM1, 0b001, rs1, imm12)
#define test_add_hw(rs1, rs2)    RISCV_INSTR_R_TYPE(RISCV_OPCODE_CUSTOM0, 0b010, 0b0000000, rs1, rs2)
#define test_sub_hw(rs1, rs2)    RISCV_INSTR_R_TYPE(RISCV_OPCODE_CUSTOM0, 0b011, 0b0000000, rs1, rs2)
#define test_bitswap_hw(rs1)     RISCV_INSTR_R_TYPE(RISCV_OPCODE_CUSTOM0, 0b100, 0b0000000, rs1, 0)

//cxu 1 (deadbeef)
#define test_deadbeef_hw()     RISCV_INSTR_I_TYPE(RISCV_OPCODE_CUSTOM1, 0b000, 0, 0)
#define test_cafebabe_hw()     RISCV_INSTR_R_TYPE(RISCV_OPCODE_CUSTOM0, 0b010, 0b0000000, 0, 0)
/**@}*/

/*
 * This is where the actual CFU instructions are defined. Based on the templates for generating custom
 * RISC-V instructions, intrinsics are created that can be used just like regular C functions
 * The instruction prototypes as well as the OPCODES available for the CFU are defined in
 * "sw/lib/neorv32_intrinsics.h".
 *
 * So far, two RISC-V instruction formats are available: R-type instructions and I-type instructions.
 *
 * R-type instructions require 5 arguments:
 * - opcode : The 7-bit OPCODE that identifies the instruction.
 * - funct3 : A 3-bit immediate for function select.
 * - funct7 : Another 7-bit immediate for function select.
 * - rs1    : The 1st register source operand.
 * - rs2    : The 2nd register source operand.
 *
 * I-type instructions require 4 arguments:
 * - opcode : The 7-bit OPCODE that identifies the instruction.
 * - funct3 : A 3-bit immediate for function select.
 * - rs1    : The 1st register source operand.
 * - imm12  : A 12-bit immediate operand.
 *
 * Each instruction returns a 32-bit data word of type uint32_t that represents
 * the processing result of the according instruction.
 */


/**********************************************************************//**
 * @name Global variables
 **************************************************************************/
volatile uint32_t illegal_instr_exception_count = 0;

/**********************************************************************//**
 * software references
 **************************************************************************/
uint32_t sw_bitswap(uint32_t rs1) {

  uint32_t res = 0;

  for (uint32_t i = 0; i < 32; i++) {
    res = (res << 1) | (rs1 & 1);
    rs1 >>= 1;
  }
  return res;
}

uint32_t test_addi_gold(uint32_t rs1, uint32_t imm12) {
  return rs1 + imm12;
}

uint32_t test_add_gold(uint32_t rs1, uint32_t rs2) {
  return rs1 + rs2;
}

uint32_t test_deadbeef_gold() {
  return 0xdeadbeef;
}

uint32_t test_cafebabe_gold() {
  return 0xcafebabe;
}

//reads csr, prints, then writes write_value to it, reads again and prints, restores old value. 
//returns err = 0 if the value read after writing is the desired write_value, else returns 1
#define verify_read_write_csr(csr_name, csr, write_value) ({ \
  uint32_t old_csr_val, new_csr_val, err, old_exception_ctr; \
  err = 0; \
  old_exception_ctr = illegal_instr_exception_count; \
  old_csr_val = neorv32_cpu_csr_read(csr); /*todo: check if there was an exception*/\
  neorv32_cpu_csr_write(csr, write_value);\
  new_csr_val = neorv32_cpu_csr_read(csr);\
  neorv32_cpu_csr_write(csr, old_csr_val); /*restore CSR to the value it had before calling this function*/\
  if (illegal_instr_exception_count != old_exception_ctr) { \
    err = 1; \
  } else if (new_csr_val != write_value) { \
    err = 1; \
    neorv32_uart0_printf("--error. Unexpected value %u read from CSR 0x%X: %s after writing %u.\n", new_csr_val, csr, csr_name, write_value); \
  } else { \
    neorv32_uart0_printf("--success -- Successfully written value 0x%X to CSR %s.\n", write_value, csr_name);\
  }\
  err; \
})

#define test_instruction(func_name, instr, gold) ({ \
  uint32_t res_hw, res_gold, time_hw, err, old_exception_ctr; \
  err = 0; \
  old_exception_ctr = illegal_instr_exception_count; \
  neorv32_cpu_csr_write(CSR_MCYCLE, 0); /*start timing*/\
  res_hw = (instr);\
  time_hw = neorv32_cpu_csr_read(CSR_MCYCLE); /*stop timing*/\
  res_gold = (gold);\
  if(old_exception_ctr != illegal_instr_exception_count) {\
    err = 1;\
  } else if (res_gold != res_hw) {\
    err = 1;\
    neorv32_uart0_printf("--error --%s-- res_hw: 0x%X and res_gold: 0x%X do not match!\n", func_name, res_hw, res_gold);\
  } else {\
    neorv32_uart0_printf("--success --%s-- res: 0x%X, time: %u\n", func_name, res_hw, time_hw);\
  }\
  err;\
})

void trap_handler_illegal_instruction(void) {
  // intro
  neorv32_uart0_printf(RTE_TERM_HL_ON "<NEORV32-CUSTOM-HANDLER-ILLEGAL-INSTR> ");
  // CPU ID
  if (neorv32_cpu_csr_read(CSR_MHARTID) & 1) {
    neorv32_uart0_printf("[cpu1|");
  }
  else {
    neorv32_uart0_printf("[cpu0|");
  }
  // privilege level of the CPU when the trap occurred
  if (neorv32_cpu_csr_read(CSR_MSTATUS) & (3 << CSR_MSTATUS_MPP_L)) {
    neorv32_uart0_printf("M] "); // machine-mode
  }
  else {
    neorv32_uart0_printf("U] "); // user-mode
  }
  // trap cause (should be 2 because this is only called if it's 2)
  //uint32_t cause = neorv32_cpu_csr_read(CSR_MCAUSE);
  //increment a counter that counts illegal instruction exceptions (implemented as a CSR? or as a variable in C code? but the variable would have to be global since the trap handler cannot take any arguments)
  illegal_instr_exception_count++;
  // instruction address
  neorv32_uart0_printf(" MEPC=0x%X", neorv32_cpu_csr_read(CSR_MEPC));
  // trap value
  neorv32_uart0_printf(" MTVAL=0x%X", neorv32_cpu_csr_read(CSR_MTVAL));
  // outro
  neorv32_uart0_printf(" </NEORV32-CUSTOM-HANDLER-ILLEGAL-INSTR>\n" RTE_TERM_HL_OFF);
}

/**********************************************************************//**
 * Main function: run pure-SW XTEA and compare with HW-accelerated XTEA
 *
 * @note This program requires UART0 and the Xcfu and Zicntr ISA extension.
 *
 * @return 0 if execution was successful
 **************************************************************************/
int main() {

  // initialize NEORV32 run-time environment
  neorv32_rte_setup();

  // check if UART0 is implemented
  if (neorv32_uart0_available() == 0) {
    return -1; // UART0 not available, exit
  }

  // setup UART0 at default baud rate, no interrupts
  neorv32_uart0_setup(BAUD_RATE, 0);

  // check if the CFU is implemented (the CFU is wrapped in the core's "Xcfu" ISA extension)
  if ((neorv32_cpu_csr_read(CSR_MXISA) & (1 << CSR_MXISA_XCFU)) == 0) {
    neorv32_uart0_printf("ERROR! CFU ('Xcfu' ISA extension) not implemented!\n");
    return -1;
  }

  // check if the CPU base counters are implemented
  if ((neorv32_cpu_csr_read(CSR_MXISA) & (1 << CSR_MXISA_ZICNTR)) == 0) {
    neorv32_uart0_printf("ERROR! Base counters ('Zicntr' ISA extension) not implemented!\n");
    return -1;
  }

  // intro
  neorv32_uart0_printf("\n<<< NEORV32 Custom Functions Unit (CFU) - Custom Instructions Example >>>\n\n");


////////////////////////////////////////////////////////////////////////
  //install my own trap handler for illegal instruction exceptions which increments a counter that can be checked after, to check if an illegal instruction occurred
  uint32_t install_handler_success = -1;
  install_handler_success = neorv32_rte_handler_install(TRAP_CODE_I_ILLEGAL, trap_handler_illegal_instruction);
  if (install_handler_success != 0) {
    neorv32_uart0_printf("ERROR when installing the custom trap handler for illegal instruction exceptions./n");
  }

////////////////////////////////////////////////////////////////////////
  uint32_t err = 0;

//test CX CSRs
  err += verify_read_write_csr("mcx_selector", CSR_MCX_SELECTOR, 0x7abcdef9);
  err += verify_read_write_csr("cx_status", CSR_CX_STATUS, 0b0011010);
  err += verify_read_write_csr("mcx_table", CSR_MCX_TABLE, 0xfa6be000); //need to pad last 12 bits with 0 so the value read corresponds to the value written (only 20 MSB are actually written)
  err += verify_read_write_csr("cx_index", CSR_CX_INDEX, 0b1110010100);

//test CXU 0 (arithmetic)
  neorv32_cpu_csr_write(CSR_MCX_SELECTOR, 0x00000000); //write CX_ID=0 (bits 7 downto 0)
  err += test_instruction("CXU 0: addi", test_addi_hw(25, 3), test_addi_gold(25, 3));
  err += test_instruction("CXU 0: add", test_add_hw(896, 32), test_add_gold(896, 32));

//test CXU 1 (deadbeef)
  neorv32_cpu_csr_write(CSR_MCX_SELECTOR, 0x00000001); //write CX_ID=0 (bits 7 downto 0)
  err += test_instruction("CXU 1: deadbeef", test_deadbeef_hw(), test_deadbeef_gold());
  err += test_instruction("CXU 1: cafebabe", test_cafebabe_hw(), test_cafebabe_gold());

  if (err != 0) {
    neorv32_uart0_printf(RTE_TERM_HL_ON "ERROR! %u errors occurred. illegal_instr_counter: %u" RTE_TERM_HL_OFF "\n", err, illegal_instr_exception_count);
  } else {
    neorv32_uart0_printf("SUCCESS! -- CFU demo program completed successfully.\n");
  }
  
  return 0;
}
