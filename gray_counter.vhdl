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
  signal s_cnt, s_below : std_logic_vector(WIDTH downto 0);
  signal s_cnt_msb : std_logic;
begin
  s_cnt_msb <= s_cnt(WIDTH-1) or s_cnt(WIDTH);
  process(clk)
  begin
    if rising_edge(clk) then
      if i_sclr = '1' then
        s_cnt <= (0 => '1', others => '0');
      else
        s_cnt(0) <= not s_cnt(0);
        for i in 1 to WIDTH-1 loop
          -- Flip s_cnt(i) if lower bits are a 1 followed by all 0's
          s_cnt(i) <= s_cnt(i) xor (s_cnt(i-1) and s_below(i-1));
        end loop;  -- i
        s_cnt(WIDTH) <= s_cnt(WIDTH) xor (s_cnt_msb and s_below(WIDTH-1));
      end if;
    end if;
  end process;
  s_below(0) <= '1';
  gen : for j in 1 to WIDTH generate
    s_below(j) <= s_below(j-1) and not s_cnt(j-1);
  end generate;
  o_cnt <= s_cnt(WIDTH downto 1);
end architecture;
