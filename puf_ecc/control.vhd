library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.STD_LOGIC_UNSIGNED.ALL;

USE work.const.all;

entity control is
    Port (
        clock : in std_logic;
        reset : in std_logic;
        pufbit_finished : in std_logic;
        write_finished, read_finished : in std_logic;
        decode_valid : in std_logic;
        provision : in std_logic;

        enable_counting : out std_logic;
        number0, number1 : out std_logic_vector(4 downto 0);
        decode_reset : out bit;
        write_out : out std_logic
    );
end control;

architecture Behavioral of control is

type ControlState is (AWAIT_INPUT, GEN_BITS, DECODE, UART_OUT, FINISHED);

signal state : ControlState;
signal count : std_logic_vector (m - 1 downto 0);

signal lfsr : std_logic_vector(9 downto 0);

begin

number0 <= lfsr(4 downto 0);
number1 <= lfsr(9 downto 5);

process(clock, reset) begin
	if reset = '0' then
		enable_counting <= '0';
		decode_reset <= '1';
		write_out <= '0';

		state <= AWAIT_INPUT;
		count <= (others => '0');
		lfsr <= "0000000001";
	elsif rising_edge(clock) then
		enable_counting <= '0';
		state <= state;
		decode_reset <= '1';
		write_out <= '0';
		case state is
		when AWAIT_INPUT =>
			if read_finished = '1' then
				state <= GEN_BITS;
			end if;
		when GEN_BITS =>
			if pufbit_finished = '1' then
				enable_counting <= '0';
				if count = k - 1 then
					if provision = '1' then
						state <= UART_OUT;
						write_out <= '1';
					else
						state <= DECODE;
					end if;
					count <= (others => '0');
					lfsr <= "0000000001";
				else
					lfsr <= lfsr(8 downto 0) & (lfsr(9) xor lfsr(6));
					count <= count + 1;
				end if;
			else
				enable_counting <= '1';
			end if;
		when DECODE =>
			decode_reset <= '0';
			if decode_valid = '1' then
				if count = k - 1 then
					decode_reset <= '1';
					count <= (others => '0');
					state <= UART_OUT;
					write_out <= '1';
				else
					count <= count + 1;
				end if;
			end if;
		when UART_OUT =>
			if write_finished = '1' then
				state <= AWAIT_INPUT;
			end if;
		when FINISHED =>
		end case;
	end if;
end process;

end Behavioral;
