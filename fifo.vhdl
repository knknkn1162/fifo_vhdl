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
    -- o_stop : out std_logic
  );
end entity;

architecture behavior of fifo is

  component counter
    generic(N : natural; INIT : natural);
    port (
      clk, i_sclr, i_en : in std_logic;
      o_cnt : out std_logic_vector(N-1 downto 0)
    );
  end component;

  component bicounter
    generic(N : natural; INIT : natural);
    port (
      clk, i_sclr : in std_logic;
      i_inc, i_dec : in std_logic;
      o_cnt : out std_logic_vector(N-1 downto 0)
    );
  end component;

  component port1_ram
    generic(ADDR_WIDTH : natural; DATA_WIDTH : natural);
    port (
      clk, i_we : in std_logic;
      i_ra : in std_logic_vector(ADDR_WIDTH-1 downto 0);
      o_rd : out std_logic_vector(DATA_WIDTH-1 downto 0);
      i_wa : in std_logic_vector(ADDR_WIDTH-1 downto 0);
      i_wd : in std_logic_vector(DATA_WIDTH-1 downto 0)
    );
  end component;


  constant RAM_SIZE : natural := 2**ADDR_WIDTH;
  type ram_type is array(natural range<>) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal s_ram_data : ram_type(0 to RAM_SIZE-1);

  -- avoid if expression
  signal s_widx : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal s_ridx : std_logic_vector(ADDR_WIDTH-1 downto 0);

  -- Actually the range is [0 to RAM_SIZE-1]+-1 => [-1 to RAM_SIZE]
  -- but avoiding if expression, the range is increased by 1.
  -- signal s_fifo_cnt : integer range 0 to RAM_SIZE+1;
  signal s_fifo_cnt : std_logic_vector(ADDR_WIDTH downto 0);
  signal s_full, s_empty : std_logic;
  signal s_wen, s_ren : std_logic;

  constant CONST_UPPER_LIMIT : std_logic_vector(ADDR_WIDTH downto 0) := std_logic_vector(to_unsigned(RAM_SIZE, ADDR_WIDTH+1));
  constant CONST_LOWER_LIMIT : std_logic_vector(ADDR_WIDTH downto 0) := (0 => '1', others => '0');
begin

  s_wen <= i_wen and (not s_full);
  counter_widx : counter generic map(N=>ADDR_WIDTH, INIT=>0)
  port map (
    clk => clk, i_sclr => i_sclr,
    i_en => s_wen,
    o_cnt => s_widx
  );

  s_ren <= i_ren and (not s_empty);
  counter_ridx : counter generic map(N=>ADDR_WIDTH, INIT=>0)
  port map (
    clk => clk, i_sclr => i_sclr,
    i_en => s_ren,
    o_cnt => s_ridx
  );

  bicounter_fifo_cnt : bicounter generic map(N=>ADDR_WIDTH+1, INIT=>1)
  port map (
    clk => clk, i_sclr => i_sclr,
    i_inc => i_wen, i_dec => i_ren,
    o_cnt => s_fifo_cnt
  );

  ram0 : port1_ram generic map(ADDR_WIDTH=>ADDR_WIDTH, DATA_WIDTH=>DATA_WIDTH)
  port map (
    clk => clk, i_we => i_wen,
    i_ra => s_ridx, o_rd => o_rdata,
    i_wa => s_widx, i_wd => i_wdata
  );

  -- when reaches upper limit
  s_full <= '1' when s_fifo_cnt = CONST_UPPER_LIMIT else '0';
  -- when reaches lower limit
  s_empty <= '1' when s_fifo_cnt = CONST_LOWER_LIMIT else '0';
  o_full <= s_full; o_empty <= s_empty;

  -- process(clk)
  -- begin
  --   if rising_edge(clk) then
  --     if (s_full and i_wen) = '1' or (s_empty and i_ren) = '1' then
  --       o_stop <= '1';
  --     end if;
  --   end if;
  -- end process;
end  architecture;
