library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity comparator_16b is
    port ( src_a     : in  std_logic_vector(15 downto 0);
           src_b     : in  std_logic_vector(15 downto 0);
           result : out std_logic );
end comparator_16b;

architecture behavioural of comparator_16b is

signal sig_result : std_logic_vector(16 downto 0);

begin

    result <= '1' when not(src_a = src_b);
    
end behavioural;
