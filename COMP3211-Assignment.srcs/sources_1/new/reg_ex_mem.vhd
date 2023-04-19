library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

-- EX/MEM register
entity reg_ex_mem is
    port(   EX_Mem_To_Reg, EX_Reg_Write, EX_Mem_Write, EX_Branch, EX_Zero   : in std_logic;
            EX_carry_out, EX_syscall    : in std_logic;
            EX_aluop_result, EX_reg_data_rt, EX_branch_PC       : in std_logic_vector(19 downto 0);
            EX_data_in                  : in std_logic_vector(19 downto 0);
            EX_wreg_addr                : in std_logic_vector(4 downto 0);
            clk, reset, clear           : in std_logic;

            MEM_Mem_To_Reg, MEM_Reg_Write, MEM_Mem_Write, MEM_Branch, MEM_Zero  : out std_logic;
            MEM_carry_out, MEM_syscall  : in std_logic;
            MEM_aluop_result, MEM_reg_data_rt, MEM_branch_PC    : out std_logic_vector(19 downto 0);
            MEM_data_in                 : in  std_logic_vector(19 downto 0);
            MEM_wreg_addr               : out std_logic_vector(4 downto 0)
        );
end reg_ex_mem;

architecture behavioural of reg_ex_mem is
    begin
        process
        begin
            wait until (falling_edge(clk));
            if (rst = '1' or clear = '1') then
                MEM_Mem_To_Reg <= '0';
                MEM_Reg_Write <= '0';
                MEM_Mem_Write <= '0';
                MEM_Branch <= '0';
                MEM_Zero <= '0';
                MEM_carry_out <= '0';
                MEM_syscall <= '0';
                MEM_aluop_result <= x"00000";
                MEM_reg_data_rt <= x"00000";
                MEM_branch_PC <= x"00000";
                MEM_wreg_addr <= "00000";
            else
                MEM_Mem_To_Reg <= EX_Mem_To_Reg;
                MEM_Reg_Write <= EX_Reg_Write;
                MEM_Mem_Write <= EX_Mem_Write;
                MEM_Branch <= EX_Branch;
                MEM_Zero <= EX_Zero;
                MEM_carry_out <= EX_carry_out;
                MEM_syscall <= EX_check_sign;
                MEM_aluop_result <= EX_aluop_result;
                MEM_reg_data_rt <= EX_reg_rt;
                MEM_branch_PC <= EX_branch_PC;
                MEM_wreg_addr <= EX_wreg_addr;
            end if;
        end process;
    end behavioural;