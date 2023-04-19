library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

-- IF/ID register, 
entity reg_if_id is
    port(   IF_PC4      : in    std_logic_vector(5 downto 0);
            IF_INSN     : in    std_logic_vector(19 downto 0);
            IF_line_num, IF_char_idx    : in    std_logic_vector(3 downto 0);
            IF_data_in  : in    std_logic_vector(19 downto 0);
            IF_syscall  : in    std_logic;
            clk, rst, clear : in    std_logic;

            ID_PC4      : out   std_logic_vector(5 downto 0);
            ID_INSN     : out   std_logic_vector(19 downto 0);
            EX_line_num, IF_char_idx    : in    std_logic_vector(3 downto 0);
            EX_data_in  : in    std_logic_vector(19 downto 0);
        );
end reg_if_id;

architecture behavioural of reg_if_id is
begin
    process
    begin
        wait until (falling_edge(clk));
        if (rst = '1' or clear = '1') then
            ID_PC4 = "000000";
            ID_INSN = x"00000";
        else
            ID_PC4 <= IF_PC4;
            ID_INSN <= IF_INST;
        end if;
    end process;
end behavioural;