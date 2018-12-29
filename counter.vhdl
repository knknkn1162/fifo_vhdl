library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter is
  generic(N : natural; INIT : natural);
  port (
    clk, i_sclr, i_en : in std_logic;
    o_cnt : out std_logic_vector(N-1 downto 0)
  );
end entity;

architecture behavior of counter is
  signal s_cnt : std_logic_vector(N-1 downto 0);
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if i_sclr = '1' then
        s_cnt <= std_logic_vector(to_unsigned(INIT, N));
      elsif i_en = '1' then
        s_cnt <= std_logic_vector(unsigned(s_cnt) + 1);
      end if;
    end if;
  end process;
  o_cnt <= s_cnt;
end architecture;
