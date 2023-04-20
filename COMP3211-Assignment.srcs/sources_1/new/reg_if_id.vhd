library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

-- IF/ID register, 
entity reg_if_id is
    port(   IF_PC4      : in    std_logic_vector(5 downto 0);
            IF_INSN     : in    std_logic_vector(19 downto 0);
            IF_line_num, IF_char_idx    : in    std_logic_vector(4 downto 0);
            IF_data_in, IF_sig_flag     : in    std_logic_vector(19 downto 0);
            IF_syscall  : in    std_logic;
            clk, rst, clear : in    std_logic;

            ID_PC4      : out   std_logic_vector(5 downto 0);
            ID_INSN     : out   std_logic_vector(19 downto 0);
            ID_line_num, ID_char_idx    : out    std_logic_vector(4 downto 0);
            ID_data_in, ID_sig_flag     : out    std_logic_vector(19 downto 0);
            ID_syscall  : out   std_logic;
        );
end reg_if_id;

architecture behavioural of reg_if_id is
begin
    process
    begin
        wait until (falling_edge(clk));
        if (rst = '1' or clear = '1') then
            ID_PC4 <= "000000";
            ID_INSN <= x"00000";
            ID_line_num <= "00000";
            ID_char_idx <= "00000";
            ID_data_in <= x"00000";
            ID_sig_flag <= x"00000";
            ID_syscall <= '0';
        else
            ID_PC4 <= IF_PC4;
            ID_INSN <= IF_INST;
            ID_line_num <= IF_line_num;
            ID_char_idx = IF_char_idx;
            ID_data_in = IF_data_in;
            ID_sig_flag <= IF_sig_flag;
            ID_syscall <= IF_syscall;
        end if;
    end process;
end behavioural;