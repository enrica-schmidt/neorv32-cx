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
/** Number of XTEA rounds */
//#define XTEA_ROUNDS 20
/** Input data size (number of 32-bit words), has to be even */
//#define DATA_NUM    64
/**@}*/


/**********************************************************************//**
 * @name Define XTEA CFU instruction based on the intrinsic templates
 **************************************************************************/
/**@{*/
#define test_addi_hw(rs1, imm12) RISCV_INSTR_I_TYPE(RISCV_OPCODE_CUSTOM1, 0b000, rs1, imm12)
#define test_subi_hw(rs1, imm12) RISCV_INSTR_I_TYPE(RISCV_OPCODE_CUSTOM1, 0b001, rs1, imm12)
#define test_add_hw(rs1, rs2)    RISCV_INSTR_R_TYPE(RISCV_OPCODE_CUSTOM0, 0b010, 0b0000000, rs1, rs2)
#define test_sub_hw(rs1, rs2)    RISCV_INSTR_R_TYPE(RISCV_OPCODE_CUSTOM0, 0b011, 0b0000000, rs1, rs2)
#define test_bitswap_hw(rs1)     RISCV_INSTR_R_TYPE(RISCV_OPCODE_CUSTOM0, 0b100, 0b0000000, rs1, 0)
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
/**@{*/
/** Timing data */
uint32_t time_addi_sw, time_addi_hw, time_subi_sw, time_subi_hw, time_add_sw, time_add_hw, time_sub_sw, time_sub_hw, time_bitswap_sw, time_bitswap_hw;
/**@}*/
/**********************************************************************//**
 * bitswap - software reference  
 **************************************************************************/
uint32_t sw_bitswap(uint32_t rs1) {

  uint32_t res = 0;

  for (uint32_t i = 0; i < 32; i++) {
    res = (res << 1) | (rs1 & 1);
    rs1 >>= 1;
  }
  return res;
}


/**********************************************************************//**
 * Main function: run pure-SW XTEA and compare with HW-accelerated XTEA
 *
 * @note This program requires UART0 and the Xcfu and Zicntr ISA extension.
 *
 * @return 0 if execution was successful
 **************************************************************************/
int main() {

  //uint32_t i, j;
  uint32_t addi_rs1, addi_imm12, subi_rs1, subi_imm12, add_rs1, add_rs2, sub_rs1, sub_rs2, bitswap_rs1;
  addi_rs1    = 3;
  addi_imm12  = 9;
  subi_rs1    = 44;
  subi_imm12  = 2;
  add_rs1     = 25;
  add_rs2     = 9;
  sub_rs1     = 87;
  sub_rs2     = 28;
  bitswap_rs1 = 67;

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

  /*
  // check if data size configuration is even
  if ((DATA_NUM & 1) != 0) {
    neorv32_uart0_printf("ERROR! DATA_NUM has to be even!\n");
    return -1;
  }
  */

  // intro
  neorv32_uart0_printf("\n<<< NEORV32 Custom Functions Unit (CFU) - Custom Instructions Example >>>\n\n");

////////////////////////////////////////////////////////////////////////
//read and write CSR mcycle (make sure this mechanism works for an implemented csr)
  uint32_t csr_fflags_read, csr_fflags_write;
  csr_fflags_read = neorv32_cpu_csr_read(CSR_FFLAGS);
  neorv32_uart0_printf("CSR_FFLAGS contains: %u\n", csr_fflags_read);
  csr_fflags_write = 0x3;
  neorv32_cpu_csr_write(CSR_FFLAGS, csr_fflags_write);
  csr_fflags_read = neorv32_cpu_csr_read(CSR_FFLAGS);
  neorv32_uart0_printf("CSR_FFLAGS contains: %u and should contain %u\n", csr_fflags_read, csr_fflags_write);
  csr_fflags_write = 0x1F; //fflags is only 5 bit, therefore can only store values up to 0x1F
  neorv32_cpu_csr_write(CSR_FFLAGS, csr_fflags_write);
  csr_fflags_read = neorv32_cpu_csr_read(CSR_FFLAGS);
  neorv32_uart0_printf("CSR_FFLAGS contains: %u and should contain %u\n", csr_fflags_read, csr_fflags_write);
//read new test CSR (test if newly added csr works, can be read and written)
  /*uint32_t csr_test_read, csr_test_write;
  csr_test_read = neorv32_cpu_csr_read(CSR_TEST);
  neorv32_uart0_printf("CSR_TEST contains: %u\n", csr_test_read);
  csr_test_write = 0;
  neorv32_cpu_csr_write(CSR_TEST, csr_test_write);
  neorv32_uart0_printf("CSR_TEST contains: %u and should contain %u\n", csr_test_read, csr_test_write);
  csr_test_write = 384;
  neorv32_cpu_csr_write(CSR_TEST, csr_test_write);
  neorv32_uart0_printf("CSR_TEST contains: %u and should contain %u\n", csr_test_read, csr_test_write);*/
////////////////////////////////////////
//addi
  //neorv32_uart0_printf("test_addi...\n");
  neorv32_cpu_csr_write(CSR_MCYCLE, 0); // start timing
  uint32_t addi_res_hw = test_addi_hw(addi_rs1, addi_imm12);
  time_addi_hw = neorv32_cpu_csr_read(CSR_MCYCLE); // stop timing
  //neorv32_uart0_printf("addi res: %u, time_enc_hw: %u\n", addi_res, time_enc_hw);

  neorv32_cpu_csr_write(CSR_MCYCLE, 0); // start timing
  uint32_t addi_res_sw = addi_rs1 + addi_imm12;
  time_addi_sw = neorv32_cpu_csr_read(CSR_MCYCLE); // stop timing

//subi
  //neorv32_uart0_printf("test_subi...\n");
  neorv32_cpu_csr_write(CSR_MCYCLE, 0); // start timing
  uint32_t subi_res_hw = test_subi_hw(subi_rs1, subi_imm12);
  time_subi_hw = neorv32_cpu_csr_read(CSR_MCYCLE); // stop timing
  //neorv32_uart0_printf("subi res: %u, time_enc_hw: %u\n", subi_res, time_enc_hw);

  neorv32_cpu_csr_write(CSR_MCYCLE, 0); // start timing
  uint32_t subi_res_sw = subi_rs1 - subi_imm12;
  time_subi_sw = neorv32_cpu_csr_read(CSR_MCYCLE); // stop timing

//add
  //neorv32_uart0_printf("test_add_hw...\n");
  neorv32_cpu_csr_write(CSR_MCYCLE, 0); // start timing
  uint32_t add_res_hw = test_add_hw(add_rs1, add_rs2);
  time_add_hw = neorv32_cpu_csr_read(CSR_MCYCLE); // stop timing
  //neorv32_uart0_printf("add res: %u, time_enc_hw: %u\n", add_res, time_enc_hw);
  neorv32_cpu_csr_write(CSR_MCYCLE, 0); // start timing
  uint32_t add_res_sw = add_rs1 + add_rs2;
  time_add_sw = neorv32_cpu_csr_read(CSR_MCYCLE); // stop timing

//sub
  //neorv32_uart0_printf("test_sub_hw...\n");
  neorv32_cpu_csr_write(CSR_MCYCLE, 0); // start timing
  uint32_t sub_res_hw = test_sub_hw(sub_rs1, sub_rs2);
  time_sub_hw = neorv32_cpu_csr_read(CSR_MCYCLE); // stop timing
  //neorv32_uart0_printf("sub res: %u, time_enc_hw: %u\n", sub_res, time_enc_hw);

  neorv32_cpu_csr_write(CSR_MCYCLE, 0); // start timing
  uint32_t sub_res_sw = sub_rs1 - sub_rs2;
  time_sub_sw = neorv32_cpu_csr_read(CSR_MCYCLE); // stop timing

// bitswap
  //neorv32_uart0_printf("test_bitswap_hw...\n");
  neorv32_cpu_csr_write(CSR_MCYCLE, 0); // start timing
  uint32_t bitswap_res_hw = test_bitswap_hw(bitswap_rs1);
  time_bitswap_hw = neorv32_cpu_csr_read(CSR_MCYCLE); // stop timing
  //neorv32_uart0_printf("bitswap res: %u, time_hw: %u\n", bitswap_res, time_enc_hw);

  //neorv32_uart0_printf("test_bitswap_sw...\n");
  neorv32_cpu_csr_write(CSR_MCYCLE, 0); // start timing
  uint32_t bitswap_res_sw = sw_bitswap(bitswap_rs1);
  time_bitswap_sw = neorv32_cpu_csr_read(CSR_MCYCLE); // stop timing
  //neorv32_uart0_printf("bitswap res: %u, time_enc_hw: %u\n", bitswap_sw_res, time_enc_hw);

////////////////////////////////////////////////////////////////////////


  // compare results
  uint32_t errs = 0;
  neorv32_uart0_printf("Comparing results... ");
  if (addi_res_hw != addi_res_sw) {
    errs = 1;
    neorv32_uart0_printf("addi_res_hw: %u != addi_res_sw: %u\n", addi_res_hw, addi_res_sw);
  }
  if (subi_res_hw != subi_res_sw) {
    errs = 1;
    neorv32_uart0_printf("subi_res_hw: %u != subi_res_sw: %u\n", subi_res_hw, subi_res_sw);
  }
  if (add_res_hw != add_res_sw) {
    errs = 1;
    neorv32_uart0_printf("add_res_hw: %u != add_res_sw: %u\n", add_res_hw, add_res_sw);
  }
  if (sub_res_hw != sub_res_sw) {
    errs = 1;
    neorv32_uart0_printf("sub_res_hw: %u != sub_res_sw: %u\n", sub_res_hw, sub_res_sw);
  }
  if (bitswap_res_hw != bitswap_res_sw) {
    errs = 1;
    neorv32_uart0_printf("bitswap_res_hw: %u != bitswap_res_sw: %u\n", bitswap_res_hw, bitswap_res_sw);
  }

  if (errs == 0) {
    neorv32_uart0_printf("Custom instructions OK!\n");
  } else {
    return 1;
  }

  /*for (i=0; i<DATA_NUM; i++) {
    if (cypher_data_sw[i] != cypher_data_hw[i]) {
      neorv32_uart0_printf("FAILED at byte index %d\n", i);
      return -1;
    }
  }*/
  //neorv32_uart0_printf("OK\n");

/*
  // compare results
  neorv32_uart0_printf("Comparing results... ");
  for (i=0; i<DATA_NUM; i++) {
    if ((plain_data_sw[i] != plain_data_hw[i]) || (plain_data_sw[i] != input_data[i])) {
      neorv32_uart0_printf("FAILED at byte index %d\n", i);
      return -1;
    }
  }
  neorv32_uart0_printf("OK\n");
*/

  // ----------------------------------------------------------
  // Print timing results
  // ----------------------------------------------------------
  //neorv32_uart0_printf("\nExecution timing:\n");
  //neorv32_uart0_printf("ENC SW = %u cycles\n", time_enc_sw);
  //neorv32_uart0_printf("ENC HW = %u cycles\n", time_enc_hw);
  //neorv32_uart0_printf("DEC SW = %u cycles\n", time_dec_sw);
  //neorv32_uart0_printf("DEC HW = %u cycles\n", time_dec_hw);


  // ----------------------------------------------------------
  // Execute an unimplemented CFU instruction word
  // ----------------------------------------------------------
  //neorv32_uart0_printf("\nExecuting not-implemented CFU instruction (raise ILLEGAL INSTRUCTION exception)...\n");
  //xtea_hw_illegal_inst();


  neorv32_uart0_printf("\nCFU demo program completed.\n");
  return 0;
}
