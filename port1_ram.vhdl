library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity port1_ram is
  generic(ADDR_WIDTH : natural; DATA_WIDTH : natural);
  port (
    clk, i_we : in std_logic;
    i_ra : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    o_rd : out std_logic_vector(DATA_WIDTH-1 downto 0);
    i_wa : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    i_wd : in std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity;

architecture behavior of port1_ram is
  type ram_type is array(natural range<>) of std_logic_vector(DATA_WIDTH-1 downto 0);
  signal ram_data : ram_type(0 to 2**ADDR_WIDTH-1);
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if i_we = '1' then
        ram_data(to_integer(unsigned(i_wa))) <= i_wd;
      end if;
    end if;
  end process;
  o_rd <= ram_data(to_integer(unsigned(i_ra)));
end architecture;
