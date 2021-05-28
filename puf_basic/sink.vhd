library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sink is
	Port (
	result : in STD_LOGIC;
	finished : in STD_LOGIC;
	clock : in STD_LOGIC;
	reset : in STD_LOGIC;
	awvalid : out std_logic;
	awaddr : out std_logic_vector(3 downto 0);
	wready : in std_logic;
	wvalid : out std_logic;
	wdata : out std_logic_vector(31 downto 0);
	bvalid : in std_logic;
	bready : out std_logic;
	bresp : in std_logic_vector(1 downto 0);
	buffer_ready : out std_logic
	);
end sink;

architecture Behavioral of sink is

signal databuffer : std_logic_vector(7 downto 0);
signal buffercount : unsigned(3 downto 0);

begin

process (clock, reset) begin
	if reset = '0' then
		databuffer <= (others => '0');
		buffercount <= (others => '0');
		buffer_ready <= '1';
		awaddr <= "0000";
		awvalid <= '0';
		wdata <= (others => '0');
		wvalid <= '0';
		bready <= '0';
	elsif rising_edge(clock) then
		if wready = '1' then
			wdata <= (others => '0');
			wvalid <= '0';
			awaddr <= "0000";
			awvalid <= '0';
		end if;
		if bvalid = '1' then
			if bresp = "10" then
				awaddr <= "0100";
				awvalid <= '1';
				wdata(7 downto 0) <= databuffer;
				wvalid <= '1';
				bready <= '1';
			else
				buffercount <= (others => '0');
				buffer_ready <= '1';
				bready <= '0';
			end if;
		end if;
		if buffercount < 8 and finished = '1' then
			databuffer <= databuffer(6 downto 0) & result;
			if buffercount = 7 then
				-- buffer full
				buffer_ready <= '0';
				-- write out
				awaddr <= "0100";
				awvalid <= '1';
				wdata(7 downto 0) <= databuffer;
				wvalid <= '1';
				bready <= '1';
			end if;
			buffercount <= buffercount + 1;
		end if;
	end if;
end process;

end Behavioral;
