library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

-- MEM/WB register
entity reg_mem_wb is
    port(   MEM_Mem_To_Reg, MEM_Reg_Write   : in std_logic;
            MEM_memory_data, MEM_aluop_result   : in std_logic_vector(19 downto 0);
            MEM_wreg_addr       : in std_logic_vector(4 downto 0);
            clk, reset          : in std_logic;

            wb_Mem_To_Reg, wb_Reg_Write : out std_logic;
            wb_memory_data, wb_aluop_result : out std_logic_vector(19 downto 0);
            wb_wreg_addr        : out std_logic_vector(4 downto 0)
        );
end reg_mem_wb;

architecture behavioural of reg_mem_wb is
    begin
        process
        begin
            wait until (falling_edge(clk));
            if rst = '1' then
                wb_Mem_To_Reg <= '0';
                wb_Reg_Write <= '0';
                wb_memory_data <= x"00000";
                wb_aluop_result <= x"00000";
                wb_wreg_addr <= "00000";
            else
                wb_Mem_To_Reg <= MEM_Mem_To_Reg;
                wb_Reg_Write <= MEM_Reg_Write;
                wb_memory_data <= MEM_memory_data;
                wb_aluop_result <= MEM_aluop_result;
                wb_wreg_addr <= MEM_wreg_addr;
            end if;
        end process;
    end behavioural;