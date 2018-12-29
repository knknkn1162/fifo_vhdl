library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gray_counter_tb is
end entity;

architecture testbench of gray_counter_tb is
  component gray_counter is
    generic(WIDTH : natural);
    port (
      clk, i_sclr : in std_logic;
      i_en : in std_logic;
      o_cnt : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;

  constant WIDTH : natural := 4;
  signal clk, s_sclr, s_en : std_logic;
  signal s_cnt : std_logic_vector(WIDTH-1 downto 0);
  constant CLK_PERIOD : time := 10 ns;
  signal s_end : boolean;

begin
  uut : gray_counter generic map(WIDTH=>WIDTH)
  port map (
    clk => clk, i_sclr => s_sclr,
    i_en => s_en,
    o_cnt => s_cnt
  );

  clk_process: process
  begin
    while not s_end loop
      clk <= '0'; wait for CLK_PERIOD/2;
      clk <= '1'; wait for CLK_PERIOD/2;
    end loop;
    wait;
  end process;

  stim_proc : process
  begin
    wait for CLK_PERIOD;
    -- skip
    s_en <= '1';
    s_sclr <= '1'; wait until rising_edge(clk); wait for 1 ns; s_sclr <= '0';
    assert s_cnt = "0000";
    wait until rising_edge(clk); wait for 1 ns;
    assert s_cnt = "0001";
    wait until rising_edge(clk); wait for 1 ns;
    assert s_cnt = "0011";
    wait until rising_edge(clk); wait for 1 ns;
    assert s_cnt = "0010";
    wait until rising_edge(clk); wait for 1 ns;
    assert s_cnt = "0110";
    wait until rising_edge(clk); wait for 1 ns;
    assert s_cnt = "0111";
    wait until rising_edge(clk); wait for 1 ns;
    assert s_cnt = "0101";
    wait until rising_edge(clk); wait for 1 ns;
    assert s_cnt = "0100";
    wait until rising_edge(clk); wait for 1 ns;
    assert s_cnt = "1100";
    -- success message
    s_end <= TRUE;
    assert false report "end of test" severity note;
    wait;
  end process;
end architecture;
