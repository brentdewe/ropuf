library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.ALL;

entity control is
    Port (
        clock : in std_logic;
        reset : in std_logic;
        pufbit_finished : in std_logic;
        enable_counting : out std_logic;
        next_challenge : out std_logic;
        reset_seed : out std_logic;
        buffer_ready : in std_logic
    );
end control;

architecture Behavioral of control is

type ControlState is (GEN_BITS, FINISHED);

signal state : ControlState;
signal bits_generated : std_logic_vector (12 downto 0);

begin

process(clock, reset) begin
	if reset = '0' then
		state <= GEN_BITS;
		enable_counting <= '0';
		next_challenge <= '0';
		bits_generated <= (others => '0');
		reset_seed <= '0';
	elsif rising_edge(clock) then
		enable_counting <= '0';
		next_challenge <= '0';
		state <= state;
		reset_seed <= '0';
		case state is
		when GEN_BITS =>
			if pufbit_finished = '1' then
				enable_counting <= '0';
--				if bits_generated = 1023 then
--					state <= FINISHED;
--					reset_seed <= '1';
--				else
--					next_challenge <= '1';
--				end if;
--				bits_generated <= bits_generated + 1;
				next_challenge <= '1';
			elsif buffer_ready = '0' then
				enable_counting <= '0';
			else
				enable_counting <= '1';
			end if;
		when FINISHED =>
		end case;
	end if;
end process;

end Behavioral;
