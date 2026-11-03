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
  generic (
    --CXU_CXU_ID_W   : natural range 0 to 16   := 7;
    --CXU_FUNC_ID_W  : natural range 3 to 11   := 11;
    CXU_DATA_W     : natural range 32 to 64  := 32;
    CXU_STATUS_W   : natural range 3 to 3    := 3
  );
  port (
    -- global control --
    clk_i    : in  std_ulogic; -- global clock, rising edge
    rstn_i   : in  std_ulogic; -- global reset, low-active, async
    -- CSR interface --
    csr_we_i    : in  std_ulogic;                     -- write enable
    csr_addr_i  : in  std_ulogic_vector(11 downto 0); -- address (later only use necessary bits to distinguish within the csrs of the cfu)
    csr_wdata_i : in  std_ulogic_vector(31 downto 0); -- write data
    csr_rdata_o : out std_ulogic_vector(31 downto 0); -- read data
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
  -- CFU CSRs -- stateful
  --signal csr_test    : std_ulogic_vector(31 downto 0);
  --signal csr_test_2  : std_ulogic_vector(31 downto 0);
  signal csr_mcx_selector : std_ulogic_vector(31 downto 0); 
  signal csr_cx_status    : std_ulogic_vector(6 downto 0);
  signal csr_mcx_table    : std_ulogic_vector(19 downto 0);
  signal csr_cx_index     : std_ulogic_vector(9 downto 0);

  -- supported CFU opcodes --
  --constant opcode_custom0_c : std_ulogic_vector(6 downto 0) := "0001011"; -- CUSTOM-0 opcode
  --constant opcode_custom1_c : std_ulogic_vector(6 downto 0) := "0101011"; -- CUSTOM-1 opcode
  --constant opcode_op32_c    : std_ulogic_vector(6 downto 0) := "0111011"; -- OP-32 opcode
  --constant opcode_opimm32_c : std_ulogic_vector(6 downto 0) := "0011011"; -- OP-IMM-32 opcode

  -- **********************************************************
  -- CFU Example:
  -- **********************************************************

  -- instruction types (opcode field) --
  --constant test_r_type_c : std_ulogic_vector(6 downto 0) := opcode_custom0_c; -- XTEA R-type instructions
  --constant test_i_type_c : std_ulogic_vector(6 downto 0) := opcode_custom1_c; -- XTEA I-type instructions

  -- instruction identifiers (funct3 bit-field) --
  --constant test_addi    : std_ulogic_vector(2 downto 0) := "000"; --Itype
  --constant test_subi    : std_ulogic_vector(2 downto 0) := "001"; --Itype
  --constant test_add     : std_ulogic_vector(2 downto 0) := "010"; --Rtype
  --constant test_sub     : std_ulogic_vector(2 downto 0) := "011"; --Rtype
  --constant test_bitswap : std_ulogic_vector(2 downto 0) := "100"; --Rtype

  -- instruction decoder --
  --signal start  : std_ulogic; -- start valid CFU instruction
  --signal itype  : std_ulogic; -- instruction type (0 = r-type, 1 = i-type)
  --signal funct3 : std_ulogic_vector(2 downto 0); -- i-type/r-type function select
  --signal imm12  : std_ulogic_vector(11 downto 0); -- i-type immediate

  signal req_valid_0   : std_ulogic;
  signal req_instr_0   : std_ulogic_vector(31 downto 0);
  signal req_data0_0   : std_ulogic_vector((CXU_DATA_W - 1) downto 0);
  signal req_data1_0   : std_ulogic_vector((CXU_DATA_W - 1) downto 0);
  signal resp_status_0 : std_ulogic_vector((CXU_STATUS_W - 1) downto 0);
  signal resp_data_0   : std_ulogic_vector((CXU_DATA_W - 1) downto 0);
  signal req_valid_1   : std_ulogic;
  signal req_instr_1   : std_ulogic_vector(31 downto 0);
  signal req_data0_1   : std_ulogic_vector((CXU_DATA_W - 1) downto 0);
  signal req_data1_1   : std_ulogic_vector((CXU_DATA_W - 1) downto 0);
  signal resp_status_1 : std_ulogic_vector((CXU_STATUS_W - 1) downto 0);
  signal resp_data_1   : std_ulogic_vector((CXU_DATA_W - 1) downto 0);

begin

  switch: entity neorv32.neorv32_cpu_alu_cfu_switch
  generic map (
    --CXU_CXU_ID_W   => CXU_CXU_ID_W,
    --CXU_FUNC_ID_W  => CXU_FUNC_ID_W,
    CXU_DATA_W     => CXU_DATA_W,
    CXU_STATUS_W   => CXU_STATUS_W
  )
  port map (
    clk_i         => clk_i,
    rstn_i        => rstn_i,
    --csr_we_i      =>
    --csr_addr_i    =>
    --csr_wdata_i   =>
    --csr_rdata_o   =>
    cxu_id_i      => csr_mcx_selector(7 downto 0),
    start_i       => start_i,
    inst_i        => inst_i,
    rs1_i         => rs1_i,
    rs2_i         => rs2_i,
    result_o      => result_o,
    valid_o       => valid_o,
    req_valid_0   => req_valid_0,
    req_instr_0   => req_instr_0,
    req_data0_0   => req_data0_0,
    req_data1_0   => req_data1_0,
    resp_status_0 => resp_status_0,
    resp_data_0   => resp_data_0,
    req_valid_1   => req_valid_1,
    req_instr_1   => req_instr_1,
    req_data0_1   => req_data0_1,
    req_data1_1   => req_data1_1,
    resp_status_1 => resp_status_1,
    resp_data_1   => resp_data_1
  );

  cxu0: entity neorv32.neorv32_cpu_alu_cfu_cxu_arithmetic
  generic map (
    --CXU_CXU_ID_W   => CXU_CXU_ID_W,
    --CXU_FUNC_ID_W  => CXU_FUNC_ID_W,
    CXU_DATA_W     => CXU_DATA_W,
    CXU_STATUS_W   => CXU_STATUS_W
  )
  port map (
    req_valid   => req_valid_0,
    req_instr   => req_instr_0,
    req_data0   => req_data0_0,
    req_data1   => req_data1_0,
    resp_status => resp_status_0,
    resp_data   => resp_data_0
  );

  cxu1: entity neorv32.neorv32_cpu_alu_cfu_cxu_deadbeef
  generic map (
    --CXU_CXU_ID_W   => CXU_CXU_ID_W,
    --CXU_FUNC_ID_W  => CXU_FUNC_ID_W,
    CXU_DATA_W     => CXU_DATA_W,
    CXU_STATUS_W   => CXU_STATUS_W
  )
  port map (
    req_valid   => req_valid_1,
    req_instr   => req_instr_1,
    req_data0   => req_data0_1,
    req_data1   => req_data1_1,
    resp_status => resp_status_1,
    resp_data   => resp_data_1
  );

  -- CSR Access -----------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------

  -- write access --
  csr_write: process(rstn_i, clk_i)
  begin
    if (rstn_i = '0') then
      csr_mcx_selector <= (others => '0');
      csr_cx_status    <= (others => '0');
      csr_mcx_table    <= (others => '0');
      csr_cx_index     <= (others => '0');
      --csr_test   <= (others => '0');
      --csr_test_2 <= (others => '0');
    elsif rising_edge(clk_i) then
      if (csr_we_i = '1') then
        if (csr_addr_i = csr_mcx_selector_c) then
          csr_mcx_selector <= csr_wdata_i;
        elsif (csr_addr_i = csr_cx_status_c) then
          csr_cx_status <= csr_wdata_i(6 downto 0);
        elsif (csr_addr_i = csr_mcx_table_c) then
          csr_mcx_table <= csr_wdata_i(31 downto 12);
        elsif (csr_addr_i = csr_cx_index_c) then
          csr_cx_index <= csr_wdata_i(9 downto 0);
        end if;
      end if;
    end if;
  end process;

  -- read access --
  csr_read: process(csr_addr_i, csr_mcx_selector, csr_cx_status, csr_mcx_table, csr_cx_index)
  begin
    csr_rdata_o <= (others => '0'); -- default
    case csr_addr_i is
      when csr_mcx_selector_c => csr_rdata_o <= csr_mcx_selector;
      when csr_cx_status_c    => csr_rdata_o(6 downto 0) <= csr_cx_status;
      when csr_mcx_table_c    => csr_rdata_o(31 downto 12) <= csr_mcx_table;
      when csr_cx_index_c     => csr_rdata_o(9 downto 0) <= csr_cx_index;
      when others => null;
    end case;
  end process;

  -- Instruction Decode ----------------------------------------------------------------
  --start  <= start_i when (inst_i(6 downto 0) = test_r_type_c) or (inst_i(6 downto 0) = test_i_type_c) else '0'; -- valid instruction?
  --itype  <= '0' when (inst_i(6 downto 0) = test_r_type_c) else '1'; -- r-type or i-type?
  --funct3 <= inst_i(14 downto 12); -- type function select
  --imm12  <= inst_i(31 downto 20); -- i-type 12-bit immediate

  -- Function Result Select 
  --result_select: process(itype, funct3, imm12, rs1_i, rs2_i)
  --begin -- no need for a register stage here; the CFU output is registered inside the ALU module anyway
  --  if (itype = '0') then -- R-type instructions; function select via "funct3"
    -- ----------------------------------------------------------------------
  --    case funct3 is -- just check "funct3" here
  --      when test_add =>
  --        result_o <= std_ulogic_vector(signed(rs1_i) + signed(rs2_i));
  --        valid_o  <= '1';
  --      when test_sub =>
  --        result_o <= std_ulogic_vector(signed(rs1_i) - signed(rs2_i));
  --        valid_o  <= '1'; -- pure-combinatorial, so we are done "immediately"
  --      when test_bitswap => 
  --        for i in 0 to 31 loop
  --          result_o(31 - i) <= rs1_i(i);
  --        end loop;
  --        valid_o  <= '1'; -- pure-combinatorial, so we are done "immediately"
  --      when others => -- all unspecified operations
  --        result_o <= (others => '0'); -- no logic implemented
  --        valid_o  <= '0'; -- this will cause an illegal instruction exception
  --    end case;
  --  else -- I-type instructions; used for key access
    -- ----------------------------------------------------------------------
  --    case funct3 is -- just check "funct3" here
  --      when test_addi =>
  --        result_o <= std_ulogic_vector(signed(rs1_i) + resize(signed(imm12), 32));
  --        valid_o  <= '1';
  --      when test_subi =>
  --        result_o <= std_ulogic_vector(signed(rs1_i) - resize(signed(imm12), 32));
  --        valid_o  <= '1'; -- pure-combinatorial, so we are done "immediately"
  --      when others => -- all unspecified operations
  --        result_o <= (others => '0'); -- no logic implemented
  --        valid_o  <= '0'; -- this will cause an illegal instruction exception
  --    end case;
  --  end if;
  --end process;

end architecture;
