library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

-- ID/EX register
entity reg_id_ex is
    port(   ID_PC4      : in    std_logic_vector(5 downto 0);
            ID_INSN     : in    std_logic_vector(19 downto 0);
            ID_data_in  : in    std_logic_vector(19 downto 0);
            ID_mem_to_reg, ID_reg_write, ID_mem_write : in std_logic;
            ID_ALUsrc, ID_reg_dst, ID_branch : in std_logic;
            ID_syscall  : in std_logic;
            -- ID_write_data   : in    std_logic_vector(19 downto 0);
            ID_reg_data_rs, ID_reg_data_rt, ID_xtnd_off : in std_logic_vector(19 downto 0);
            ID_wreg_rs, ID_wreg_rt  : in    std_logic_vector(4 downto 0);
            clk, rst, clear : in    std_logic;

            EX_mem_to_reg, EX_reg_write, EX_mem_write : out std_logic;
            EX_ALUsrc, EX_reg_dst, EX_branch : out std_logic;
            EX_syscall  : out std_logic;
            EX_PC4      : out   std_logic_vector(5 downto 0);
            EX_INSN     : out   std_logic_vector(19 downto 0);
            EX_data_in  : in    std_logic_vector(19 downto 0);
            EX_reg_data_rs, EX_reg_data_rt, EX_xtnd_off : out std_logic_vector(19 downto 0);
            EX_wreg_rs, EX_wreg_rt  : in    std_logic_vector(4 downto 0)
        );
end reg_id_ex;

architecture behavioural of reg_id_ex is
    begin
        process
        begin
            wait until (falling_edge(clk));
            if (rst = '1' or clear = '1') then
                EX_mem_to_reg <= '0';
                EX_reg_write <= '0';
                EX_mem_write <= '0';
                EX_ALUsrc <= '0';
                EX_reg_dst <= '0';
                EX_branch <= '0';
                EX_syscall <= '0';
                EX_PC4 <= "000000";
                EX_INSN <= x"00000";
                EX_reg_data_rs <= x"00000";
                EX_reg_data_rt <= x"00000";
                EX_xtnd_off <= x"00000";
                EX_wreg_rs <= "00000";
                EX_wreg_rt <= "00000";
            else
                EX_mem_to_reg <= ID_mem_to_reg ;
                EX_reg_write <= ID_reg_write;
                EX_mem_write <= ID_mem_write;
                EX_ALUsrc <= ID_ALUsrc;
                EX_reg_dst <= ID_reg_dst;
                EX_branch <= ID_branch;
                EX_ALU_rs_inc <= ID_ALU_rs_inc;
                EX_bshift_out <= ID_bshift_out;
                EX_check_sign <= ID_check_sign;
                EX_PC4 <= ID_PC4;
                EX_INSN <= ID_INSN;
                EX_reg_data_rs <= ID_reg_data_rs;
                EX_reg_data_rt <= ID_reg_data_rt;
                EX_xtnd_off <= ID_xtnd_off;
                EX_wreg_rs <= ID_wreg_rs;
                EX_wreg_rt <= ID_wreg_rt;
            end if;
        end process;
    end behavioural;