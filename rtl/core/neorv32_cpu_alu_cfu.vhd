-- ================================================================================ --
-- NEORV32 CPU - ALU Custom (RISC-V Instructions) Functions Unit (CFU)              --
-- -------------------------------------------------------------------------------- --
-- See the CPU's data sheet for more information. Also take a look at the "software --
-- counterpart" of this CFU example in sw/example/demo_cfu.                         --
-- -------------------------------------------------------------------------------- --
-- The NEORV32 RISC-V Processor - https://github.com/stnolting/neorv32              --
-- Copyright (c) NEORV32 contributors.                                              --
-- Copyright (c) 2020 - 2026 Stephan Nolting. All rights reserved.                  --
-- Licensed under the BSD-3-Clause license, see LICENSE for details.                --
-- SPDX-License-Identifier: BSD-3-Clause                                            --
-- ================================================================================ --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

entity neorv32_cpu_alu_cfu is
  port (
    -- global control --
    clk_i    : in  std_ulogic; -- global clock, rising edge
    rstn_i   : in  std_ulogic; -- global reset, low-active, async
    -- request --
    start_i  : in  std_ulogic; -- start trigger, single-shot
    inst_i   : in  std_ulogic_vector(31 downto 0); -- full instruction word
    rs1_i    : in  std_ulogic_vector(31 downto 0); -- register source operand 1
    rs2_i    : in  std_ulogic_vector(31 downto 0); -- register source operand 2
    -- response --
    result_o : out std_ulogic_vector(31 downto 0); -- operation result
    valid_o  : out std_ulogic                      -- operation done; result valid
  );
end entity;

architecture neorv32_cpu_alu_cfu_rtl of neorv32_cpu_alu_cfu is

  -- supported CFU opcodes --
  constant opcode_custom0_c : std_ulogic_vector(6 downto 0) := "0001011"; -- CUSTOM-0 opcode
  constant opcode_custom1_c : std_ulogic_vector(6 downto 0) := "0101011"; -- CUSTOM-1 opcode
  constant opcode_op32_c    : std_ulogic_vector(6 downto 0) := "0111011"; -- OP-32 opcode
  constant opcode_opimm32_c : std_ulogic_vector(6 downto 0) := "0011011"; -- OP-IMM-32 opcode

  -- **********************************************************
  -- CFU Example:
  -- **********************************************************

  -- instruction types (opcode field) --
  constant test_r_type_c : std_ulogic_vector(6 downto 0) := opcode_custom0_c; -- XTEA R-type instructions
  constant test_i_type_c : std_ulogic_vector(6 downto 0) := opcode_custom1_c; -- XTEA I-type instructions

  -- instruction identifiers (funct3 bit-field) --
  constant test_addi    : std_ulogic_vector(2 downto 0) := "000"; --Itype
  constant test_subi    : std_ulogic_vector(2 downto 0) := "001"; --Itype
  constant test_add     : std_ulogic_vector(2 downto 0) := "010"; --Rtype
  constant test_sub     : std_ulogic_vector(2 downto 0) := "011"; --Rtype
  constant test_bitswap : std_ulogic_vector(2 downto 0) := "100"; --Rtype

  -- instruction decoder --
  signal start  : std_ulogic; -- start valid CFU instruction
  signal itype  : std_ulogic; -- instruction type (0 = r-type, 1 = i-type)
  signal funct3 : std_ulogic_vector(2 downto 0); -- i-type/r-type function select
  signal imm12  : std_ulogic_vector(11 downto 0); -- i-type immediate

begin

  -- Instruction Decode ----------------------------------------------------------------
  start  <= start_i when (inst_i(6 downto 0) = test_r_type_c) or (inst_i(6 downto 0) = test_i_type_c) else '0'; -- valid instruction?
  itype  <= '0' when (inst_i(6 downto 0) = test_r_type_c) else '1'; -- r-type or i-type?
  funct3 <= inst_i(14 downto 12); -- type function select
  imm12  <= inst_i(31 downto 20); -- i-type 12-bit immediate

  -- Function Result Select 
  result_select: process(itype, funct3, imm12, rs1_i, rs2_i)
  begin -- no need for a register stage here; the CFU output is registered inside the ALU module anyway
    if (itype = '0') then -- R-type instructions; function select via "funct3"
    -- ----------------------------------------------------------------------
      case funct3 is -- just check "funct3" here
        when test_add =>
          result_o <= std_ulogic_vector(signed(rs1_i) + signed(rs2_i));
          valid_o  <= '1';
        when test_sub =>
          result_o <= std_ulogic_vector(signed(rs1_i) - signed(rs2_i));
          valid_o  <= '1'; -- pure-combinatorial, so we are done "immediately"
        when test_bitswap => 
          for i in 0 to 31 loop
            result_o(31 - i) <= rs1_i(i);
          end loop;
          valid_o  <= '1'; -- pure-combinatorial, so we are done "immediately"
        when others => -- all unspecified operations
          result_o <= (others => '0'); -- no logic implemented
          valid_o  <= '0'; -- this will cause an illegal instruction exception
      end case;
    else -- I-type instructions; used for key access
    -- ----------------------------------------------------------------------
      case funct3 is -- just check "funct3" here
        when test_addi =>
          result_o <= std_ulogic_vector(signed(rs1_i) + resize(signed(imm12), 32));
          valid_o  <= '1';
        when test_subi =>
          result_o <= std_ulogic_vector(signed(rs1_i) - resize(signed(imm12), 32));
          valid_o  <= '1'; -- pure-combinatorial, so we are done "immediately"
        when others => -- all unspecified operations
          result_o <= (others => '0'); -- no logic implemented
          valid_o  <= '0'; -- this will cause an illegal instruction exception
      end case;
    end if;
  end process;

end architecture;
