library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity muxer is
    generic (select_size : integer);
    Port ( inputs : in STD_LOGIC_VECTOR(2**select_size - 1 downto 0);
           sel_output : out STD_LOGIC;
           selection : in STD_LOGIC_VECTOR(select_size - 1 downto 0)
    );
end muxer;

architecture Behavioral of muxer is

begin

sel_output <= inputs(to_integer(unsigned(selection)));

end Behavioral;
