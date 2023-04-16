library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sign_extend_4b_to_6b is
    port ( data_in  : in  std_logic_vector(3 downto 0);
           data_out : out std_logic_vector(5 downto 0) );
end sign_extend_4b_to_6b;

architecture behavioural of sign_extend_4b_to_6b is

begin

    process (data_in)
    begin
        if data_in(3) = '1' then  -- input is negative
            data_out <= "11" & data_in;
        else  -- input is non-negative
            data_out <= "00" & data_in;
        end if;
    end process;

end behavioural;
