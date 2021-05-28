library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity lfsr10 is
	Port (
		clock : in STD_LOGIC;
		reset : in STD_LOGIC;
		next_challenge : in STD_LOGIC;
		number0 : out STD_LOGIC_VECTOR (4 downto 0);
		number1 : out STD_LOGIC_VECTOR (4 downto 0);
		reset_seed : in std_logic
	 );
end lfsr10;

architecture Behavioral of lfsr10 is

signal reg : std_logic_vector(9 downto 0);
signal count : std_logic_vector(3 downto 0);

begin

number0 <= reg(4 downto 0);
number1 <= reg(9 downto 5);

process (clock, reset) begin
	if reset = '0' or reset_seed = '1' then
		reg <= "0000000001";
	elsif rising_edge(clock) then
		if next_challenge = '1' then
			reg <= reg(8 downto 0) & (reg(9) xor reg(6));
		end if;
	end if;
end process;

end Behavioral;
