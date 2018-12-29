library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fifo is
  generic(ADDR_WIDTH : natural; DATA_WIDTH : natural);
  port (
    clk, i_sclr : in std_logic;
    i_wen : in std_logic;
    i_wdata : in std_logic_vector(DATA_WIDTH-1 downto 0);
    i_ren : in std_logic;
    o_rdata : out std_logic_vector(DATA_WIDTH-1 downto 0);
    o_full : out std_logic;
    o_empty : out std_logic
  );
end entity;

architecture behavior of fifo is

  component gray_counter
    generic(WIDTH : natural);
    port (
      clk, i_sclr, i_en : in std_logic;
      o_cnt : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;

  component port1_syncram
    generic(ADDR_WIDTH : natural; DATA_WIDTH : natural);
    port (
      clk, i_we, i_re : in std_logic;
      i_ra : in std_logic_vector(ADDR_WIDTH-1 downto 0);
      o_rd : out std_logic_vector(DATA_WIDTH-1 downto 0);
      i_wa : in std_logic_vector(ADDR_WIDTH-1 downto 0);
      i_wd : in std_logic_vector(DATA_WIDTH-1 downto 0)
    );
  end component;

  constant RAM_SIZE : natural := 2**ADDR_WIDTH;
  type ram_type is array(natural range<>) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal s_ram_data : ram_type(0 to RAM_SIZE-1);

  signal s_widx_ex : std_logic_vector(ADDR_WIDTH downto 0);
  signal s_ridx_ex : std_logic_vector(ADDR_WIDTH downto 0);
  signal s_ridx, s_widx : std_logic_vector(ADDR_WIDTH-1 downto 0);

  signal s_full, s_empty : std_logic;
  signal s_wen, s_ren : std_logic;

begin
  s_wen <= i_wen and (not s_full);
  counter_widx0 : gray_counter generic map(WIDTH=>ADDR_WIDTH+1)
  port map (
    clk => clk, i_sclr => i_sclr,
    i_en => s_wen,
    o_cnt => s_widx_ex
  );

  s_ren <= i_ren and (not s_empty);
  counter_ridx0 : gray_counter generic map(WIDTH=>ADDR_WIDTH+1)
  port map (
    clk => clk, i_sclr => i_sclr,
    i_en => s_ren,
    o_cnt => s_ridx_ex
  );

  s_ridx <= (s_ridx_ex(ADDR_WIDTH) xor s_ridx_ex(ADDR_WIDTH-1)) & s_ridx_ex(ADDR_WIDTH-2 downto 0);
  s_widx <= (s_widx_ex(ADDR_WIDTH) xor s_widx_ex(ADDR_WIDTH-1)) & s_widx_ex(ADDR_WIDTH-2 downto 0);
  ram0 : port1_syncram generic map(ADDR_WIDTH=>ADDR_WIDTH, DATA_WIDTH=>DATA_WIDTH)
  port map (
    clk => clk, i_we => s_wen, i_re => s_ren,
    i_ra => s_ridx, o_rd => o_rdata,
    i_wa => s_widx, i_wd => i_wdata
  );

  -- when reaches lower limit
  s_full <= '1' when s_widx_ex = s_ridx_ex else '0';
  -- when reaches upper limit
  s_empty <= '1' when s_widx_ex = ((not s_ridx_ex(ADDR_WIDTH downto ADDR_WIDTH-1)) & s_ridx_ex(ADDR_WIDTH-2 downto 0))  else '0';

  o_full <= s_full; o_empty <= s_empty;
end  architecture;
