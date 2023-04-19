---------------------------------------------------------------------------
-- instruction_memory.vhd - Implementation of A Single-Port, 16 x 16-bit
--                          Instruction Memory.
-- 
-- Notes: refer to headers in single_cycle_core.vhd for the supported ISA.
--
-- Copyright (C) 2006 by Lih Wen Koh (lwkoh@cse.unsw.edu.au)
-- All Rights Reserved. 
--
-- The single-cycle processor core is provided AS IS, with no warranty of 
-- any kind, express or implied. The user of the program accepts full 
-- responsibility for the application of the program and the use of any 
-- results. This work may be downloaded, compiled, executed, copied, and 
-- modified solely for nonprofit, educational, noncommercial research, and 
-- noncommercial scholarship purposes provided that this notice in its 
-- entirety accompanies all copies. Copies of the modified software can be 
-- delivered to persons who use it solely for nonprofit, educational, 
-- noncommercial research, and noncommercial scholarship purposes provided 
-- that this notice in its entirety accompanies all copies.
--
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity instruction_memory is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(5 downto 0);
           insn_out : out std_logic_vector(19 downto 0) );
end instruction_memory;

architecture behavioral of instruction_memory is

type mem_array is array(0 to 63) of std_logic_vector(19 downto 0);
signal sig_insn_mem : mem_array;

begin
    mem_process: process ( clk,
                           addr_in ) is
  
    variable var_insn_mem : mem_array;
    variable var_addr     : integer;
  
    begin
    
        -- Instruction delay bug fix
        -- Continious read of the instruction memory location given by var_addr
        var_addr := conv_integer(addr_in);
        insn_out <= var_insn_mem(var_addr);

        if rising_edge(clk) then
            if (reset = '1') then
    
                -- initial values of the instruction memory :
                --  insn_0 : load  $1, $0, 0   - load data 0($0) into $1
                --  insn_1 : load  $2, $0, 1   - load data 1($0) into $2
                --  insn_2 : add   $3, $0, $1  - $3 <- $0 + $1
                --  insn_3 : add   $4, $1, $2  - $4 <- $1 + $2
                --  insn_4 : store $3, $0, 2   - store data $3 into 2($0)
                --  insn_5 : store $4, $0, 3   - store data $4 into 3($0)
                --  insn_6 - insn_15 : noop    - end of program
    
                -- Instructions layout:
                -- <instruction> <1sr arg> <dest> 2ndt arg>
    
                -- IMPORTANT: First instruction must be noop
                var_insn_mem(0)  := X"00000";
                
                -- First set of instructions: Read in patterns
                -- 78000 = <01111 - syscall>< n/a >< n/a > < n/a>
                -- 23c1e = <00100 - syscall BNE> <01111 - 15th element in register> <n/a> <11110 - update PC by -2>
                var_insn_mem(1)  := X"78000";
                var_insn_mem(2)  := X"2341e";
                
                -- Second set of instructions: Create lookup tables
                -- 1XXX = Load address <array index> <register> <element index> 
                -- 2XXX = Load immediate, <n/a> <register> <value> 
                -- 5XXX = BNE <register 1> <register 2> <branch value (+/- 7> 
                    -- (This is a special branch - it'll also branch if equal to '?')
                    -- (This is a bit of a limitation, but we can just chain a bunch of these if we need to do big jumps)
                -- 6XXX = ADDI <register> <register destination> <immediate>
                
                -- We'll store k in $0, i in $1, j in $2
                -- initialise $0 with 0 and $1 with i (representing i and j respectively)
                var_insn_mem(3)  := X"10020";  
                var_insn_mem(4)  := X"10041";
                
                -- load value from register[$0][$1] into $3
                var_insn_mem(5)  := X"08023";
                -- load value from register[$0][$2] into $4
                var_insn_mem(6)  := X"08044";
                -- compare $3 and $4, branch 4 if not equal
                var_insn_mem(7)  := X"28c84";
                
                -- if pattern[i] === pattern[j] || pattern[j] === '?'
                var_insn_mem(8)  := X"00000";
                var_insn_mem(9)  := X"00000";
                var_insn_mem(10)  := X"00000";
                var_insn_mem(11)  := X"00000";
             
                -- if i==0
                -- branch if $1 is not equal to 0 (register index 16 will be reserved for 0)
                var_insn_mem(12)  := X"285e2";
                -- Add 1 to j ($2)
                var_insn_mem(13)  := X"30841";
                -- set table[j] = 0
                var_insn_mem(14)  := X"00000";
                
                -- else
                var_insn_mem(15)  := X"38d01";
                var_insn_mem(16)  := X"00000";

                var_insn_mem(17) := X"00000";
                var_insn_mem(18) := X"00000";
                var_insn_mem(19) := X"00000";
                var_insn_mem(20) := X"00000";
                var_insn_mem(21) := X"00000";
                var_insn_mem(22) := X"00000";
                var_insn_mem(23) := X"00000";
                var_insn_mem(24) := X"00000";
                var_insn_mem(25) := X"00000";
                var_insn_mem(26) := X"00000";
                var_insn_mem(27) := X"00000";
                var_insn_mem(28) := X"00000";
                var_insn_mem(29) := X"00000";
                var_insn_mem(30) := X"00000";
                var_insn_mem(31) := X"00000";
                var_insn_mem(32) := X"00000";
                var_insn_mem(33) := X"00000";
                var_insn_mem(34) := X"00000";
                var_insn_mem(35) := X"00000";
                var_insn_mem(36) := X"00000";
                var_insn_mem(37) := X"00000";
                var_insn_mem(38) := X"00000";
                var_insn_mem(39) := X"00000";
                var_insn_mem(40) := X"00000";
                var_insn_mem(41) := X"00000";
                var_insn_mem(42) := X"00000";
                var_insn_mem(43) := X"00000";
                var_insn_mem(44) := X"00000";
                var_insn_mem(45) := X"00000";
                var_insn_mem(46) := X"00000";
                var_insn_mem(47) := X"00000";
                var_insn_mem(48) := X"00000";
                var_insn_mem(49) := X"00000";
                var_insn_mem(50) := X"00000";
                var_insn_mem(51) := X"00000";
                var_insn_mem(52) := X"00000";
                var_insn_mem(53) := X"00000";
                var_insn_mem(54) := X"00000";
                var_insn_mem(55) := X"00000";
                var_insn_mem(56) := X"00000";
                var_insn_mem(57) := X"00000";
                var_insn_mem(58) := X"00000";
                var_insn_mem(59) := X"00000";
                var_insn_mem(60) := X"00000";
                var_insn_mem(61) := X"00000";
                var_insn_mem(62) := X"00000";
                var_insn_mem(63) := X"00000";
            end if;
        end if;
        
        -- Removed for instruction delay bug fix
--        elsif (rising_edge(clk)) then
--            -- read instructions on the rising clock edge
--            var_addr := conv_integer(addr_in);
--            insn_out <= var_insn_mem(var_addr);
--        end if;

        -- the following are probe signals (for simulation purpose)
        sig_insn_mem <= var_insn_mem;

    end process;
  
end behavioral;
