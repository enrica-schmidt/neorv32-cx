library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library neorv32;
use neorv32.neorv32_package.all;

entity neorv32_cpu_alu_cfu_switch is
  generic (
    --CXU_CXU_ID_W   : natural range 0 to 16   := 0;
    --CXU_FUNC_ID_W  : natural range 3 to 11   := 11;
    CXU_DATA_W     : natural range 32 to 64  := 32;
    CXU_STATUS_W   : natural range 3 to 3    := 3
  );
  port (
    -- global control --
    clk_i    : in  std_ulogic; -- global clock, rising edge
    rstn_i   : in  std_ulogic; -- global reset, low-active, async
    -- CSR interface --
    --csr_we_i    : in  std_ulogic;                     -- write enable
    --csr_addr_i  : in  std_ulogic_vector(11 downto 0); -- address (later only use necessary bits to distinguish within the csrs of the cfu)
    --csr_wdata_i : in  std_ulogic_vector(31 downto 0); -- write data
    --csr_rdata_o : out std_ulogic_vector(31 downto 0); -- read data
    -- cxu id --
    cxu_id_i : in std_ulogic_vector(7 downto 0);
    -- request --
    start_i  : in  std_ulogic; -- start trigger, single-shot
    inst_i   : in  std_ulogic_vector(31 downto 0); -- full instruction word
    rs1_i    : in  std_ulogic_vector(31 downto 0); -- register source operand 1
    rs2_i    : in  std_ulogic_vector(31 downto 0); -- register source operand 2
    -- response --
    result_o : out std_ulogic_vector(31 downto 0); -- operation result
    valid_o  : out std_ulogic;                     -- operation done; result valid
    -- cxu 0 ports --
    req_valid_0   : out std_ulogic;
    req_instr_0   : out std_ulogic_vector(31 downto 0);
    req_data0_0   : out std_ulogic_vector((CXU_DATA_W - 1) downto 0);
    req_data1_0   : out std_ulogic_vector((CXU_DATA_W - 1) downto 0);
    resp_status_0 : in std_ulogic_vector((CXU_STATUS_W - 1) downto 0);
    resp_data_0   : in std_ulogic_vector((CXU_DATA_W - 1) downto 0);
    -- cxu 1 ports --
    req_valid_1   : out std_ulogic;
    req_instr_1   : out std_ulogic_vector(31 downto 0);
    req_data0_1   : out std_ulogic_vector((CXU_DATA_W - 1) downto 0);
    req_data1_1   : out std_ulogic_vector((CXU_DATA_W - 1) downto 0);
    resp_status_1 : in std_ulogic_vector((CXU_STATUS_W - 1) downto 0);
    resp_data_1   : in std_ulogic_vector((CXU_DATA_W - 1) downto 0)
  );
end entity;

architecture neorv32_cpu_alu_cfu_switch_rtl of neorv32_cpu_alu_cfu_switch is
begin
   -- todo: introduce new error signal to avoid having to wait for timeout on valid_o
   -- todo: for now, dont use func_id, instead pass complete instruction word directly, might want to change this later
   -- todo: check status and forward res=0 to cpu accordingly etc.
  switch: process(cxu_id_i, start_i, inst_i, rs1_i, rs2_i, resp_status_0, resp_status_1, resp_data_0, resp_data_1)
  begin
    -- cxu0 ports --
    req_valid_0 <= '0';
    req_instr_0 <= (others => '0');
    req_data0_0 <= (others => '0');
    req_data1_0 <= (others => '0');
    -- cxu1 ports --
    req_valid_1 <= '0';
    req_instr_1 <= (others => '0');
    req_data0_1 <= (others => '0');
    req_data1_1 <= (others => '0');
    -- to CPU --
    result_o      <= (others => '0');
    valid_o       <= '0';
    case cxu_id_i is
      when x"00" => 
        req_valid_0   <= start_i;
        req_instr_0   <= inst_i;
        req_data0_0   <= rs1_i;
        req_data1_0   <= rs2_i;
        valid_o       <= '1' when (resp_status_0 = CXU_OK) else '0';
        result_o      <= resp_data_0;
      when x"01" => 
        req_valid_1   <= start_i;
        req_instr_1   <= inst_i;
        req_data0_1   <= rs1_i;
        req_data1_1   <= rs2_i;
        valid_o       <= '1' when (resp_status_1 = CXU_OK) else '0';
        result_o      <= resp_data_1;
      when others => null;
    end case;
  end process;

end architecture;
