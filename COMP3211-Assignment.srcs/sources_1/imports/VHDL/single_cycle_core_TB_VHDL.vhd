library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity Single_cycle_core_TB_VHDL is
end Single_cycle_core_TB_VHDL;

architecture behave of Single_cycle_core_TB_VHDL is

    -- Signal declarations
    -- 1 GHz = 2 nanoseconds period
    constant c_CLOCK_PERIOD : time := 2 ns;
    
    signal r_CLOCK  : std_logic := '0';
    signal r_reset  : std_logic := '0';
    
 
    -- Pattern signals
    signal syscall_active: std_logic:= '0';
    signal patterns_reading: std_logic :='1';
    signal patterns_finished_next: std_logic := '0';
    signal patterns_finished: std_logic := '0';
    signal line_number : integer := 0;
    signal character_index: integer := 0;
    signal line_number_vector : std_logic_vector(4 downto 0) := "00000";
    signal character_index_vector: std_logic_vector(4 downto 0) := "00000";
    signal sig_flag : std_logic_vector(19 downto 0) := X"00000";

    -- String signals
    signal data_in  : std_logic_vector(19 downto 0);
    signal string_finished_next: std_logic := '0';
    signal string_finished: std_logic := '0';
     
    -- Component declaration for the Unit Under Test (UUT)
    component single_cycle_core is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           process_start : in std_logic;
           character_index: in std_logic_vector(4 downto 0);
           line_number_in: in std_logic_vector(4 downto 0);
           data_in  : in  std_logic_vector(19 downto 0);
           sig_flag  : in  std_logic_vector(19 downto 0);
           syscall  : out std_logic
         );
    end component;
    
    -- File declaration
    file string_file_in : text open read_mode is "string.txt";
    file patterns_file_in: text open read_mode is "patterns.txt";
    
begin

    -- Instantiate the Unit Under Test (UUT)
    UUT : single_cycle_core
    port map (
      reset   => r_reset,
      clk     => r_CLOCK,
      process_start => patterns_finished,
      line_number_in => line_number_vector,
      character_index => character_index_vector,
      sig_flag => sig_flag,
      data_in => data_in,
      syscall => syscall_active
    );
        
    -- Clock generation process
    p_CLK_GEN : process is
    begin
    wait for c_CLOCK_PERIOD/2;
    r_CLOCK <= not r_CLOCK;
    end process p_CLK_GEN;
     
    p_FILE_OP: process (r_CLOCK)
    -- Variables
    variable line_in: line;
    variable char_in: character;
    -- Current index used to check to see if end of file has been reached
    variable patterns_current_index: integer := 1;
    variable string_current_index: integer := 1;
    variable line_number_count: integer := 0;
    
begin
    if rising_edge(r_CLOCK) and (character_index = 0 or syscall_active = '1') then
        if r_reset = '0' then
            if patterns_finished_next = '0' then
                character_index <= patterns_current_index;
                character_index_vector <= std_logic_vector(to_unsigned(patterns_current_index-1, 5));

                -- If not end of file, read the next line
                -- Might not need this if we assume that string.txt only ever has one line
                if patterns_current_index = 1 and not endfile(patterns_file_in) then
                    readline(patterns_file_in, line_in);
                    line_number_count := line_number_count + 1;
                end if;
    
                if line_in'length > 0 then
                    char_in := line_in(patterns_current_index);
                    -- Pass in characters one at a time to single_cycle_process
                    data_in <= std_logic_vector(to_unsigned(character'pos(char_in), 20));
                    line_number <= line_number_count;
                    line_number_vector <= std_logic_vector(to_unsigned(line_number_count-1, 5));
                    patterns_current_index := patterns_current_index + 1;
    
                    if patterns_current_index > line_in'length then
                        patterns_current_index := 1;
                        if  endfile(patterns_file_in) then                            
                            file_close(patterns_file_in);
                            -- Set the flag when reading is finished
                            patterns_finished_next <= '1'; 
                            line_number_count := 0;
                        end if;
                    end if;
                end if;
            end if;
            
            
            if string_finished_next = '1' and string_finished = '0' then
                sig_flag <= X"00002";
                string_finished <= '1';
                data_in <= std_logic_vector(to_unsigned(character'pos('-'), 20));
            end if;
            
            if string_finished_next = '0' and patterns_finished_next = '1' then
                sig_flag <= X"00001";
               character_index <= string_current_index;
                character_index_vector <= std_logic_vector(to_unsigned(string_current_index-1, 5));

                if patterns_finished = '0' then
                    patterns_finished <= '1';                
                end if;
                -- If not end of file, read the next line
                -- Might not need this if we assume that string.txt only ever has one line
                if string_current_index = 1 and not endfile(string_file_in) then
                    readline(string_file_in, line_in);
                    line_number_count := line_number_count + 1;
                end if;
    
                if line_in'length > 0 then
                    char_in := line_in(string_current_index);
                    
                    -- Pass in characters one at a time to single_cycle_process
                    data_in <= std_logic_vector(to_unsigned(character'pos(char_in), 20));
                    line_number <= line_number_count;
                    line_number_vector <= std_logic_vector(to_unsigned(line_number_count-1, 5));

                    string_current_index := string_current_index + 1;

                    if string_current_index > line_in'length then
                        string_current_index := 1;
                        line_in := "";
                        if endfile(string_file_in) then
                            file_close(string_file_in);
                            -- Set the flag when reading is finished
                            string_finished_next <= '1';  
                        end if;
                    end if;
                end if;
            end if;    
        end if;
    end if;
end process p_FILE_OP;


  -- Reset process
    p_RESET : process is
    begin
    r_reset <= '1';
    wait for c_CLOCK_PERIOD;
    r_reset <= '0';
    wait;
    end process p_RESET;
    
end behave;
