library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity patterns_register is
    port (
        clk        : in std_logic;
        reset      : in std_logic;
        data_in    : in std_logic_vector(143 downto 0);
        data_out   : out std_logic_vector(143 downto 0);
        load       : in std_logic;
        address    : in std_logic_vector(2 downto 0)
    );
end patterns_register;

architecture Behavioral of patterns_register is
    type memory_array is array(0 to 7) of std_logic_vector(143 downto 0);
    signal memory : memory_array := (others => (others => '0'));

begin
    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                memory <= (others => (others => '0'));
            elsif load = '1' then
                memory(to_integer(unsigned(address))) <= data_in;
            end if;
        end if;
    end process;

    process(address, memory)
    begin
        data_out <= memory(to_integer(unsigned(address)));
    end process;

end Behavioral;
