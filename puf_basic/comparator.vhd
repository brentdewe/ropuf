library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.ALL;

entity comparator is
    Port (
		clock : in std_logic;
		enable : in std_logic;
		refcount : in STD_LOGIC_VECTOR (31 downto 0);
		count0 : in STD_LOGIC_VECTOR (31 downto 0);
		count1 : in STD_LOGIC_VECTOR (31 downto 0);
		result : out STD_LOGIC;
		finished : out std_logic
	);
end comparator;

architecture Behavioral of comparator is

begin

process(clock, enable) begin
	if enable = '0' then
		finished <= '0';
		result <= '0';
	elsif rising_edge(clock) then
		if refcount = 200 then
			finished <= '1';
			if count1 > count0 then
				result <= '1';
			else
				result <= '0';
			end if;
		end if;
	end if;
end process;

end Behavioral;
