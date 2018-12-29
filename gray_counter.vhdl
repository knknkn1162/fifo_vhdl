library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gray_counter is
  generic(WIDTH : natural);
  port (
    clk, i_sclr : in std_logic;
    i_en : in std_logic;
    o_cnt : out std_logic_vector(WIDTH-1 downto 0)
  );
end entity;

architecture behavior of gray_counter is
  signal s_cnt : std_logic_vector(WIDTH-1 downto 0);
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if i_sclr = '1' then
        s_cnt <= (others => '0');
      else
        s_cnt <= s_cnt(WIDTH-2 downto 0) & (not s_cnt(WIDTH-1));
      end if;
    end if;
  end process;
  o_cnt <= s_cnt;
end architecture;
