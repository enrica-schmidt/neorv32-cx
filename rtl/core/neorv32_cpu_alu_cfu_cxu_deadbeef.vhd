library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

entity neorv32_cpu_alu_cfu_cxu_deadbeef is
  generic (
    --CXU_CXU_ID_W   : natural range 0 to 16   := 0;
    --CXU_FUNC_ID_W  : natural range 3 to 11   := 11;
    CXU_DATA_W     : natural range 32 to 64  := 32;
    CXU_STATUS_W   : natural range 3 to 3    := 3
  );
  port (
    req_valid   : in  std_ulogic;
    req_instr   : in  std_ulogic_vector(31 downto 0);
    req_data0   : in  std_ulogic_vector((CXU_DATA_W - 1) downto 0);
    req_data1   : in  std_ulogic_vector((CXU_DATA_W - 1) downto 0);
    resp_status : out  std_ulogic_vector((CXU_STATUS_W - 1) downto 0);
    resp_data   : out  std_ulogic_vector((CXU_DATA_W - 1) downto 0)
  );
end entity;

architecture neorv32_cpu_alu_cfu_cxu_deadbeef_rtl of neorv32_cpu_alu_cfu_cxu_deadbeef is
  -- CFU CSRs -- stateful
  
  --signal csr_test    : std_ulogic_vector(31 downto 0);
  --signal csr_test_2  : std_ulogic_vector(31 downto 0);

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
  constant test_deadbeef    : std_ulogic_vector(2 downto 0) := "000"; --Itype
  constant test_cafebabe    : std_ulogic_vector(2 downto 0) := "010"; --Rtype

  -- instruction decoder --
  signal start  : std_ulogic; -- start valid CFU instruction
  signal itype  : std_ulogic; -- instruction type (0 = r-type, 1 = i-type)
  signal funct3 : std_ulogic_vector(2 downto 0); -- i-type/r-type function select
  signal imm12  : std_ulogic_vector(11 downto 0); -- i-type immediate

begin

  -- CSR Access -----------------------------------------------------------------------------
  -- -------------------------------------------------------------------------------------------

  -- write access --
  --csr_write: process(rstn_i, clk_i)
  --begin
  --  if (rstn_i = '0') then
  --    csr_mcx_selector <= (others => '0');
  --    csr_cx_status    <= (others => '0');
  --    csr_mcx_table    <= (others => '0');
  --    csr_cx_index     <= (others => '0');
      --csr_test   <= (others => '0');
      --csr_test_2 <= (others => '0');
  --  elsif rising_edge(clk_i) then
  --    if (csr_we_i = '1') then
  --      if (csr_addr_i = csr_mcx_selector_c) then
  --        csr_mcx_selector <= csr_wdata_i;
  --      elsif (csr_addr_i = csr_cx_status_c) then
  --        csr_cx_status <= csr_wdata_i(6 downto 0);
  --      elsif (csr_addr_i = csr_mcx_table_c) then
  --        csr_mcx_table <= csr_wdata_i(31 downto 12);
  --      elsif (csr_addr_i = csr_cx_index_c) then
  --        csr_cx_index <= csr_wdata_i(9 downto 0);
  --      end if;
  --    end if;
  --  end if;
  --end process;

  -- read access --
  --csr_read: process(csr_addr_i, csr_mcx_selector, csr_cx_status, csr_mcx_table, csr_cx_index)
  --begin
  --  csr_rdata_o <= (others => '0'); -- default
  --  case csr_addr_i is
  --    when csr_mcx_selector_c => csr_rdata_o <= csr_mcx_selector;
  --    when csr_cx_status_c    => csr_rdata_o(6 downto 0) <= csr_cx_status;
  --    when csr_mcx_table_c    => csr_rdata_o(31 downto 12) <= csr_mcx_table;
  --    when csr_cx_index_c     => csr_rdata_o(9 downto 0) <= csr_cx_index;
  --    when others => null;
  --  end case;
  --end process;

  -- Instruction Decode ----------------------------------------------------------------
  start  <= req_valid when (req_instr(6 downto 0) = test_r_type_c) or (req_instr(6 downto 0) = test_i_type_c) else '0'; -- valid instruction?
  itype  <= '0' when (req_instr(6 downto 0) = test_r_type_c) else '1'; -- r-type or i-type?
  funct3 <= req_instr(14 downto 12); -- type function select
  imm12  <= req_instr(31 downto 20); -- i-type 12-bit immediate

  -- Function Result Select 
  result_select: process(itype, funct3, imm12, req_data0, req_data1)
  begin -- no need for a register stage here; the CFU output is registered inside the ALU module anyway
    if (itype = '0') then -- R-type instructions; function select via "funct3"
    -- ----------------------------------------------------------------------
      case funct3 is -- just check "funct3" here
        when test_cafebabe =>
          resp_data <= x"cafebabe";
          resp_status  <= CXU_OK;
        when others => -- all unspecified operations
          resp_data <= (others => '0'); -- no logic implemented
          resp_status  <= CXU_ERROR_CUSTOM; -- this will cause an illegal instruction exception
      end case;
    else -- I-type instructions; used for key access
    -- ----------------------------------------------------------------------
      case funct3 is -- just check "funct3" here
        when test_deadbeef =>
          resp_data <= x"deadbeef";
          resp_status  <= CXU_OK; -- pure-combinatorial, so we are done "immediately"
        when others => -- all unspecified operations
          resp_data <= (others => '0'); -- no logic implemented
          resp_status  <= CXU_ERROR_CUSTOM; -- this will cause an illegal instruction exception
      end case;
    end if;
  end process;

end architecture;
