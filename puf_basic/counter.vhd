library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity counter is
    Port ( clk : in STD_LOGIC;
           enable : in STD_LOGIC;
           count : out std_logic_vector(31 downto 0)
    );
end counter;

architecture Behavioral of counter is

signal count_internal : std_logic_vector(31 downto 0);

begin

count <= count_internal;

process(clk, enable)
begin
    if enable = '0' then
        count_internal <= (others => '0');
    elsif rising_edge(clk) then
        count_internal <= count_internal + 1;
    end if;
end process;

end Behavioral;
