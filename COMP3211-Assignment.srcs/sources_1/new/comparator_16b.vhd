library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity comparator_16b is
    port ( src_a     : in  std_logic_vector(19 downto 0);
           src_b     : in  std_logic_vector(19 downto 0);
           result : out std_logic );
end comparator_16b;

architecture behavioural of comparator_16b is

begin

    result <= '1' when not(src_a = src_b);
    
end behavioural;
