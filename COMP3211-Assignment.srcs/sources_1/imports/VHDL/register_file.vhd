library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
    port ( reset           : in  std_logic;
           clk             : in  std_logic;
           instruction     : in  std_logic_vector(4 downto 0);
           read_register_a : in  std_logic_vector(4 downto 0);
           read_register_b : in  std_logic_vector(4 downto 0);
           write_enable    : in  std_logic;
           write_register  : in  std_logic_vector(4 downto 0);
           write_data      : in  std_logic_vector(19 downto 0);
           syscall_enable  : in  std_logic;
           read_data_a     : out std_logic_vector(19 downto 0);
           read_data_b     : out std_logic_vector(19 downto 0) );
end register_file;

architecture behavioral of register_file is

    type reg_row is array (0 to 17) of std_logic_vector(19 downto 0);
    type reg_file is array (0 to 16) of reg_row;
    signal sig_regfile : reg_file;

begin

    mem_process : process ( reset,
                            clk,
                            instruction, 
                            read_register_a,
                            read_register_b,
                            write_enable,
                            write_register,
                            write_data,
                            syscall_enable ) is

        variable var_regfile     : reg_file;
        variable var_write_addr  : integer;
    
    begin
    
        var_write_addr  := to_integer(unsigned(write_register));
        
        -- Initialize data:
                if (reset = '1') then
            -- Initialize the var_regfile variable with '-' for all elements except the last two elements in each reg_row
            var_regfile := (
              others => (
                others => (
                  std_logic_vector(to_unsigned(character'pos('-'), 20))
                )
              )
            );
            for i in var_regfile'range loop
              for j in var_regfile(i)'range loop
                if j >= 16 or i > 7 then  -- Set last two elements in each reg_row to '0'
                  var_regfile(i)(j) := (others => '0');
                end if;
                if j = 16 and i <=7 then
                  var_regfile(i)(j) := X"00001";
                end if;
                -- number of patterns check
                if j = 11 and i = 16 then
                  var_regfile(i)(j) := X"00008";
                end if;
                --12 is for k
                -- pattern finished check
                if j = 13 and i = 16 then
                  var_regfile(i)(j) := X"00001";
                end if;
                -- string finished check
                if j = 14 and i = 16 then
                  var_regfile(i)(j) := X"00002";
                end if;
                -- 15 is for zero
                -- question mark
                if j = 16 and i = 16 then
                  var_regfile(i)(j) := X"0006f";
                end if;-- dash
                if j = 17 and i = 16 then
                  var_regfile(i)(j) := X"0002D";
                end if;
                if j=0 and i=16 then
                  var_regfile(i)(j) := X"00008";
                  end if;
              end loop;
            end loop;
            
        -- Write data
        elsif (falling_edge(clk) and write_enable = '1') then
        if instruction = "01111" or instruction = "01110" then
            var_regfile(to_integer(unsigned(read_register_a)))
                       (to_integer(unsigned(read_register_b)))
                := write_data;
        elsif instruction = "00111" then
            var_regfile(to_integer(unsigned(var_regfile(16)(to_integer(unsigned(read_register_a))))))
                                     (to_integer(unsigned(var_regfile(16)(to_integer(unsigned(read_register_b))))))
                := var_regfile(16)(var_write_addr);
        elsif instruction = "01000" then
            var_regfile(16)(to_integer(unsigned(write_register))) := 
            var_regfile(to_integer(unsigned(var_regfile(16)(to_integer(unsigned(read_register_a))))))
                                     (to_integer(unsigned(var_regfile(16)(to_integer(unsigned(read_register_b))))));
        else
            var_regfile(16)
                       (to_integer(unsigned(write_register)))
                := write_data;
            end if;
        end if;

        -- Read data
        if instruction = "00001" then
            read_data_a <= var_regfile(to_integer(unsigned(var_regfile(16)(to_integer(unsigned(read_register_a))))))
                                     (to_integer(unsigned(var_regfile(16)(to_integer(unsigned(read_register_b))))));
            read_data_b <= X"00000";
        elsif instruction = "00010" then
            read_data_b <= var_regfile(to_integer(unsigned(var_regfile(16)(to_integer(unsigned(read_register_a))))))
                                     (to_integer(unsigned(var_regfile(16)(to_integer(unsigned(read_register_b))))));
            read_data_a <= X"00000";
        else
            read_data_a <= var_regfile(16)(to_integer(unsigned(read_register_a)));
            read_data_b <= var_regfile(16)(to_integer(unsigned(read_register_b)));
        end if;

        sig_regfile <= var_regfile;

    end process; 

end behavioral;
