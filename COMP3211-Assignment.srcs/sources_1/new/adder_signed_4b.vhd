library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adder_signed_4b is
    port ( src_a     : in  std_logic_vector(3 downto 0);
           src_b     : in  std_logic_vector(3 downto 0);
           sum       : out std_logic_vector(3 downto 0);
           carry_out : out std_logic );
end adder_signed_4b;

architecture behavioural of adder_signed_4b is

signal sig_result : signed(4 downto 0);

begin

    sig_result <= resize(signed('0' & src_a), 5) + resize(signed('0' & src_b), 5);
    sum        <= std_logic_vector(sig_result(3 downto 0));
    carry_out  <= sig_result(4);

end behavioural;
