library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

USE WORK.const.ALL;

entity sink is
	Port (
	pufbit : in STD_LOGIC;
	pufbit_valid : in STD_LOGIC;
	clock : in STD_LOGIC;
	reset : in STD_LOGIC;
	decode_reset : in std_logic;
	syndrome_in : in std_logic_vector(nk - 1 downto 0);

	decode_input : out bit
    );
end sink;

architecture Behavioral of sink is

signal response : std_logic_vector(k - 1 downto 0);
signal syndrome : std_logic_vector(nk - 1 downto 0);
signal count : unsigned(m - 1 downto 0);
signal output_response : std_logic;

begin

process (clock, reset) begin
	if reset = '0' then
		decode_input <= '0';

		response <= (others => '0');
		syndrome <= (others => '0');
		count <= (others => '0');
		output_response <= '1';
	elsif rising_edge(clock) then
		if pufbit_valid = '1' then
			response <= pufbit & response(k - 1 downto 1);
			decode_input <= to_bit(response(1));
		end if;

		if decode_reset = '0' then
			if output_response = '1' then
				response <= '0' & response(k - 1 downto 1);
				decode_input <= to_bit(response(1));
				if count = k - 1 then
					output_response <= '0';
					count <= (others => '0');
					decode_input <= to_bit(syndrome(0));
				else
					count <= count + 1;
				end if;
			else
				syndrome <= '0' & syndrome(nk - 1 downto 1);
				decode_input <= to_bit(syndrome(1));
			end if;
		else
			output_response <= '1';
			syndrome <= syndrome_in;
		end if;
	end if;
end process;

end Behavioral;
