library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.const.all;

entity uart is
	Port (
	clock : in STD_LOGIC;
	reset : in STD_LOGIC;
	dec_out, dec_valid : in std_logic;
	pufbit, pufbit_valid : in std_logic;
	write_out : std_logic;

	wready, bvalid : in std_logic;
	bresp : in std_logic_vector(1 downto 0);
	arready, rvalid : in std_logic;
	rdata : in std_logic_vector(31 downto 0);
	rresp : in std_logic_vector(1 downto 0);

	awvalid, wvalid, bready : out std_logic;
	awaddr : out std_logic_vector(3 downto 0);
	wdata : out std_logic_vector(31 downto 0);
	arvalid, rready : out std_logic;
	araddr : out std_logic_vector(3 downto 0);

	write_finished, read_finished : out std_logic;
	provision_out : out std_logic;
	syndrome : out std_logic_vector(nk - 1 downto 0)
	);
end uart;

architecture Behavioral of uart is

type DataState is (START_READ, READ_STARTED, AWAIT_RESPONSE, WRITE_STARTED);

signal state : DataState;
signal response : std_logic_vector(k - 1 downto 0);
signal bitcount : unsigned(m - 1 downto 0);
signal provision : std_logic;
signal reading_syndrome : std_logic;
signal syndrome_in : std_logic_vector(nk - 1 + 7 downto 0); -- +7 for unused bits in the last received byte

begin

provision_out <= provision;
syndrome <= syndrome_in(nk - 1 downto 0);

process (clock, reset) begin
	if reset = '0' then
		awaddr <= "0000";
		awvalid <= '0';
		wdata <= (others => '0');
		wvalid <= '0';
		bready <= '0';
		arvalid <= '0';
		rready <= '0';
		araddr <= "0000";
		write_finished <= '0';
		read_finished <= '0';
		provision <= '1';

		state <= START_READ;
		response <= (others => '0');
		bitcount <= (others => '0');
		reading_syndrome <= '0';
	elsif rising_edge(clock) then
		write_finished <= '0';
		read_finished <= '0';

		case state is
		when START_READ =>
			araddr <= "0000";
			arvalid <= '1';
			rready <= '1';
			state <= READ_STARTED;
		when READ_STARTED =>
			if arready = '1' then
				arvalid <= '0';
			end if;
			if rvalid = '1' then
				rready <= '0';
				if rresp = "00" then
					if reading_syndrome = '1' then
						syndrome_in(to_integer(bitcount) + 7 downto to_integer(bitcount)) <= rdata(7 downto 0);
						if bitcount + 8 >= nk then
							bitcount <= (others => '0');
							reading_syndrome <= '0';
							read_finished <= '1';
							state <= AWAIT_RESPONSE;
						else
							bitcount <= bitcount + 8;
							-- read next byte
							araddr <= "0000";
							arvalid <= '1';
							rready <= '1';
						end if;
					elsif rdata(7 downto 0) = "01110000" then -- character 'p'
						-- provisioning (raw response)
						provision <= '1';
						read_finished <= '1';
						state <= AWAIT_RESPONSE;
					elsif rdata(7 downto 0) = "01110011" then -- character 's'
						-- use BCH decoding
						provision <= '0';
						-- read syndrome
						reading_syndrome <= '1';
						araddr <= "0000";
						arvalid <= '1';
						rready <= '1';
					else
						state <= START_READ;
					end if;
				else
					-- failed read, try again
					state <= START_READ;
				end if;
			end if;
		when AWAIT_RESPONSE =>
			if provision = '1' then
				if pufbit_valid = '1' then
					response <= pufbit & response(k - 1 downto 1);
				end if;
			else
				if dec_valid = '1' then
					response <= dec_out & response(k - 1 downto 1);
				end if;
			end if;
			if write_out = '1' then
				state <= WRITE_STARTED;
				awaddr <= "0100";
				awvalid <= '1';
				wdata(7 downto 0) <= response(7 downto 0);
				wvalid <= '1';
				bready <= '1';
			end if;
		when WRITE_STARTED =>
			if wready = '1' then
				wdata <= (others => '0');
				wvalid <= '0';
				awaddr <= "0000";
				awvalid <= '0';
			end if;
			if bvalid = '1' then
				if bresp = "10" then
					-- failure, try again
					awaddr <= "0100";
					awvalid <= '1';
					wdata(7 downto 0) <= response(7 downto 0);
					wvalid <= '1';
					bready <= '1';
				else
					bready <= '0';
					if bitcount + 8 >= k then
						state <= START_READ;
						write_finished <= '1';
						bitcount <= (others => '0');
						response <= (others => '0');
					else
						awaddr <= "0100";
						awvalid <= '1';
						wdata(7 downto 0) <= response(15 downto 8);
						wvalid <= '1';
						bready <= '1';
						response <= "00000000" & response(k - 1 downto 8);
						bitcount <= bitcount + 8;
					end if;
				end if;
			end if;
		end case;
	end if;
end process;

end Behavioral;
