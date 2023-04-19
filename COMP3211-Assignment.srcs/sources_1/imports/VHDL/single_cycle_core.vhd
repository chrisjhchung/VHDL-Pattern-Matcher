---------------------------------------------------------------------------
-- single_cycle_core.vhd - A Single-Cycle Processor Implementation
--
-- Notes : 
--
-- See single_cycle_core.pdf for the block diagram of this single
-- cycle processor core.
--
-- Instruction Set Architecture (ISA) for the single-cycle-core:
--   Each instruction is 16-bit wide, with four 4-bit fields.
--
--     noop      
--        # no operation or to signal end of program
--        # format:  | opcode = 0 |  0   |  0   |   0    | 
--
--     load  rt, rs, offset     
--        # load data at memory location (rs + offset) into rt
--        # format:  | opcode = 1 |  rs  |  rt  | offset |
--
--     store rt, rs, offset
--        # store data rt into memory location (rs + offset)
--        # format:  | opcode = 3 |  rs  |  rt  | offset |
--
--     add   rd, rs, rt
--        # rd <- rs + rt
--        # format:  | opcode = 8 |  rs  |  rt  |   rd   |
--
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

entity single_cycle_core is
    port ( reset  : in  std_logic;
           clk    : in  std_logic;
           process_start    : in  std_logic;
           character_index: in std_logic_vector(4 downto 0);
           line_number_in: in std_logic_vector(4 downto 0);
           sig_flag: in std_logic_vector(19 downto 0);
           data_in  : in  std_logic_vector(19 downto 0);
           syscall: out std_logic
        );
end single_cycle_core;

architecture structural of single_cycle_core is

component program_counter is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(5 downto 0);
           addr_out : out std_logic_vector(5 downto 0) );
end component;

component instruction_memory is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(5 downto 0);
           insn_out : out std_logic_vector(19 downto 0) );
end component;

component sign_extend_4to16 is
    port ( data_in  : in  std_logic_vector(4 downto 0);
           data_out : out std_logic_vector(19 downto 0) );
end component;

component sign_extend_4b_to_6b  is
    port ( data_in  : in  std_logic_vector(4 downto 0);
           data_out : out std_logic_vector(5 downto 0) );
end component;

component mux_2to1_4b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(4 downto 0);
           data_b     : in  std_logic_vector(4 downto 0);
           data_out   : out std_logic_vector(4 downto 0) );
end component;

component mux_2to1_6b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(5 downto 0);
           data_b     : in  std_logic_vector(5 downto 0);
           data_out   : out std_logic_vector(5 downto 0) );
end component;

component mux_2to1_16b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(19 downto 0);
           data_b     : in  std_logic_vector(19 downto 0);
           data_out   : out std_logic_vector(19 downto 0) );
end component;

component control_unit is
    port ( opcode     : in  std_logic_vector(4 downto 0);
           syscall    : out std_logic;
           branch    : out std_logic;
           reg_dst    : out std_logic;
           reg_write  : out std_logic;
           alu_src    : out std_logic;
           mem_write  : out std_logic;
           mem_to_reg : out std_logic );
end component;

component register_file is
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
end component;

component adder_4b is
    port ( src_a     : in  std_logic_vector(4 downto 0);
           src_b     : in  std_logic_vector(4 downto 0);
           sum       : out std_logic_vector(0 downto 0);
           carry_out : out std_logic );
end component;

component adder_signed_4b is
    port ( src_a     : in  std_logic_vector(5 downto 0);
           src_b     : in  std_logic_vector(5 downto 0);
           sum       : out std_logic_vector(5 downto 0);
           carry_out : out std_logic );
           
end component;

component adder_6b is
    port ( src_a     : in  std_logic_vector(5 downto 0);
           src_b     : in  std_logic_vector(5 downto 0);
           sum       : out std_logic_vector(5 downto 0);
           carry_out : out std_logic );
end component;

component adder_16b is
    port ( src_a     : in  std_logic_vector(19 downto 0);
           src_b     : in  std_logic_vector(19 downto 0);
           sum       : out std_logic_vector(19 downto 0);
           carry_out : out std_logic );
end component;

component comparator_16b is
    port ( src_a     : in  std_logic_vector(19 downto 0);
           src_b     : in  std_logic_vector(19 downto 0);
           result : out std_logic );
end component;

component data_memory is
    port ( reset        : in  std_logic;
           clk          : in  std_logic;
           write_enable : in  std_logic;
           write_data   : in  std_logic_vector(19 downto 0);
           addr_in      : in  std_logic_vector(4 downto 0);
           data_out     : out std_logic_vector(19 downto 0) );
end component;

--component patterns_register is
--        port (
--            clk        : in std_logic;
--            reset      : in std_logic;
--            load       : in std_logic;
--            data_in    : in std_logic_vector(143 downto 0);
--            address: in std_logic_vector(2 downto 0);
--            data_out: out std_logic_vector(143 downto 0)
--        );
--end component;

signal sig_next_pc              : std_logic_vector(5 downto 0);
signal sig_curr_pc              : std_logic_vector(5 downto 0);
signal sig_one_6b               : std_logic_vector(5 downto 0);
signal sig_pc_carry_out         : std_logic;
signal sig_insn                 : std_logic_vector(19 downto 0);
signal sig_sign_extended_offset : std_logic_vector(19 downto 0);
signal sig_reg_dst              : std_logic;
signal sig_reg_write            : std_logic;
signal sig_alu_src              : std_logic;
signal sig_mem_write            : std_logic;
signal sig_mem_to_reg           : std_logic;
signal sig_write_register       : std_logic_vector(4 downto 0);
signal sig_write_data           : std_logic_vector(19 downto 0);
signal sig_read_data_a          : std_logic_vector(19 downto 0);
signal sig_read_data_b          : std_logic_vector(19 downto 0);
signal sig_alu_src_b            : std_logic_vector(19 downto 0);
signal sig_alu_result           : std_logic_vector(19 downto 0); 
signal sig_alu_carry_out        : std_logic;
signal sig_data_mem_out         : std_logic_vector(19 downto 0);

signal sig_next_pc_hold         : std_logic_vector(4 downto 0);

signal sig_pattern_register_data_in : std_logic_vector(143 downto 0);
signal sig_pattern_register_load_data: std_logic;
signal sig_pattern_register_row_address: std_logic_vector(2 downto 0);
signal sig_pattern_register_data_out : std_logic_vector(143 downto 0);

signal sig_syscall : std_logic;
signal sig_sign_extended_offset_temp : std_logic_vector(19 downto 0);
signal sig_sys_add_mux : std_logic_vector(19 downto 0);

signal sig_branch               : std_logic;
signal sig_next_temp            : std_logic_vector(5 downto 0);
signal sig_next_bne             : std_logic_vector(5 downto 0);
signal bne_comparator           : std_logic;
signal sig_syscall_read_data_b  : std_logic_vector(19 downto 0);

signal data_memory_address      : std_logic_vector(4 downto 0);

signal sig_read_register_a      : std_logic_vector(4 downto 0);
signal sig_read_register_b      : std_logic_vector(4 downto 0);

signal sig_bne_insn_extended    : std_logic_vector(5 downto 0);

begin

    sig_one_6b <= "000001";
    syscall <= sig_syscall;
    
pc : program_counter
    port map ( reset    => reset,
               clk      => clk,
               addr_in  => sig_next_pc,
               addr_out => sig_curr_pc ); 

    next_pc : adder_6b 
    port map ( src_a     => sig_curr_pc, 
               src_b     => sig_one_6b,
               sum       => sig_next_temp, --sig_next_pc_hold,   
               carry_out => sig_pc_carry_out );
               
    bne_insn_sign_extend: sign_extend_4b_to_6b 
    port map ( data_in  => sig_insn(4 downto 0),
               data_out => sig_bne_insn_extended );
  
    bne_next_pc : adder_signed_4b 
    port map ( src_a     => sig_bne_insn_extended, 
               src_b     => sig_next_temp,
               sum       => sig_next_bne,   
               carry_out => sig_pc_carry_out );
         
    bne_comparator <=  '1' when (not(sig_read_data_a = sig_flag) and (sig_insn(19 downto 15) = "00100")) 
                            or (not(sig_read_data_a = sig_read_data_b) and (sig_insn(19 downto 15) = "00101"))
                            else '0';
                            
    mux_next_pc : mux_2to1_6b 
    port map ( mux_select => bne_comparator,
               data_a     => sig_next_temp,
               data_b     => sig_next_bne,
               data_out   => sig_next_pc );
               
--    hold_instruction: entity work.mux_2to1_4b
--    port map ( mux_select => process_start,
--               data_a => sig_curr_pc,
--               data_b => sig_next_pc_hold,
--               data_out => sig_next_pc
--    );
    
    insn_mem : instruction_memory 
    port map ( reset    => reset,
               clk      => clk,
               addr_in  => sig_curr_pc,
               insn_out => sig_insn );

    sign_extend : sign_extend_4to16 
    port map ( data_in  => sig_insn(4 downto 0),
               data_out => sig_sign_extended_offset );

    ctrl_unit : control_unit 
    port map ( opcode     => sig_insn(19 downto 15),
               syscall    => sig_syscall, 
               branch     => sig_branch, 
               reg_dst    => sig_reg_dst,
               reg_write  => sig_reg_write,
               alu_src    => sig_alu_src,
               mem_write  => sig_mem_write,
               mem_to_reg => sig_mem_to_reg );

    mux_reg_dst : mux_2to1_4b 
    port map ( mux_select => sig_reg_dst,
               data_a     => sig_insn(9 downto 5),
               data_b     => sig_insn(4 downto 0),
               data_out   => sig_write_register );

    -- If it's a syscall, then the location in register 
    -- Comes from the testbench, so need a mux
    -- for the read_register_a and read_register_b
    
    mux_reg_read_a : mux_2to1_4b 
    port map ( mux_select => sig_syscall,
               data_a     => sig_insn(14 downto 10),
               data_b     => line_number_in,
               data_out   => sig_read_register_a );
               
    mux_reg_read_b : mux_2to1_4b 
    port map ( mux_select => sig_syscall,
               data_a     => sig_insn(9 downto 5),
               data_b     => character_index,
               data_out   => sig_read_register_b );
               
    reg_file : register_file 
    port map ( reset           => reset, 
               clk             => clk,
               instruction     => sig_insn(19 downto 15),
               read_register_a => sig_read_register_a,
               read_register_b => sig_read_register_b,
               write_enable    => sig_reg_write,
               write_register  => sig_write_register,
               write_data      => sig_write_data,
               syscall_enable  => sig_syscall, 
               read_data_a     => sig_read_data_a,
               read_data_b     => sig_read_data_b );
    
    mux_alu_src : mux_2to1_16b 
    port map ( mux_select => sig_alu_src,
               data_a     => sig_read_data_b,
               data_b     => sig_sign_extended_offset,
               data_out   => sig_alu_src_b );

    alu_adder : adder_16b 
    port map ( src_a     => sig_read_data_a,
               src_b     => sig_alu_src_b,
               sum       => sig_alu_result,
               carry_out => sig_alu_carry_out );

    -- These two muxes are used to help syscalls
    -- After a character is read in we need to write whether the pattern is done reading
    -- to memory for the branch instruction
    mux_syscall_mem : mux_2to1_16b 
    port map ( mux_select => sig_syscall,
               data_a     => sig_read_data_b,
               data_b     => sig_flag,
               data_out   => sig_syscall_read_data_b );
               
    mux_syscall_mem_address : mux_2to1_4b 
    port map ( mux_select => sig_syscall,
               data_a     => sig_alu_result(4 downto 0),
               data_b     => sig_insn(14 downto 10),
               data_out   => data_memory_address );

    data_mem : data_memory 
    port map ( reset        => reset,
               clk          => clk,
               write_enable => sig_mem_write,
               write_data   => sig_syscall_read_data_b,
               addr_in      => data_memory_address,
               data_out     => sig_data_mem_out );
    
    -- syscall mux (Controlled by syscall op code)
    mux_add_to_mux : mux_2to1_16b
     port map ( mux_select => sig_syscall,
               data_a     => sig_alu_result,
               data_b     => data_in,
               data_out   => sig_sys_add_mux );
    
    mux_mem_to_reg : mux_2to1_16b 
    port map ( mux_select => sig_mem_to_reg,
               data_a     => sig_sys_add_mux,
               data_b     => sig_data_mem_out,
               data_out   => sig_write_data );


--    PATTERN_REG: patterns_register
--        port map (
--            clk         => clk,
--            reset       => reset,
--            load   => sig_pattern_register_load_data,
--            data_in     => sig_pattern_register_data_in,
--            address => sig_pattern_register_row_address
--        );

end structural;
