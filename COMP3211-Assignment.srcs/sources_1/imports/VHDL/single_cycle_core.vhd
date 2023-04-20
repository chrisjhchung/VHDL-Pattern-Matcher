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

component reg_if_id is
    port(   IF_PC4      : in    std_logic_vector(5 downto 0);
            IF_INSN     : in    std_logic_vector(19 downto 0);
            IF_line_num, IF_char_idx    : in    std_logic_vector(3 downto 0);
            IF_data_in, IF_sig_flag     : in    std_logic_vector(19 downto 0);
            IF_syscall  : in    std_logic;
            clk, rst, clear : in    std_logic;

            ID_PC4      : out   std_logic_vector(5 downto 0);
            ID_INSN     : out   std_logic_vector(19 downto 0);
            ID_line_num, ID_char_idx    : in    std_logic_vector(3 downto 0);
            ID_data_in, ID_sig_flag     : in    std_logic_vector(19 downto 0);
            ID_syscall  : in    std_logic
        );
end component;


component reg_id_ex is
    port(   ID_PC4      : in    std_logic_vector(5 downto 0);
            ID_INSN     : in    std_logic_vector(19 downto 0);
            ID_data_in  : in    std_logic_vector(19 downto 0);
            ID_mem_to_reg, ID_reg_write, ID_mem_write : in std_logic;
            ID_ALUsrc, ID_reg_dst, ID_branch : in std_logic;
            ID_syscall  : in std_logic;
            -- ID_write_data   : in    std_logic_vector(19 downto 0);
            ID_reg_data_rs, ID_reg_data_rt, ID_syscall_data_rt, ID_xtnd_off : in std_logic_vector(19 downto 0);
            ID_wreg_rs, ID_wreg_rt, ID_syscall_addr : in    std_logic_vector(4 downto 0);
            clk, rst, clear : in    std_logic;

            EX_mem_to_reg, EX_reg_write, EX_mem_write : out std_logic;
            EX_ALUsrc, EX_reg_dst, EX_branch : out std_logic;
            EX_syscall  : out std_logic;
            EX_PC4      : out   std_logic_vector(5 downto 0);
            EX_INSN     : out   std_logic_vector(19 downto 0);
            EX_data_in  : in    std_logic_vector(19 downto 0);
            EX_reg_data_rs, EX_reg_data_rt, EX_syscall_data_rt, EX_xtnd_off : out std_logic_vector(19 downto 0);
            EX_wreg_rs, EX_wreg_rt, EX_syscall_addr : in    std_logic_vector(4 downto 0)
        );
end component;

component reg_ex_mem is
    port(   EX_Mem_To_Reg, EX_Reg_Write, EX_Mem_Write   : in std_logic;
            EX_carry_out, EX_syscall    : in std_logic;
            EX_aluop_result, EX_reg_data_rt : in std_logic_vector(19 downto 0);
            EX_data_in                  : in std_logic_vector(19 downto 0);
            EX_wreg_addr                : in std_logic_vector(4 downto 0);
            EX_mem_addr                 : in std_logic_vector(4 downto 0);
            clk, reset, clear           : in std_logic;

            MEM_Mem_To_Reg, MEM_Reg_Write, MEM_Mem_Write    : out std_logic;
            MEM_carry_out, MEM_syscall  : out std_logic;
            MEM_aluop_result, MEM_reg_data_rt   : out std_logic_vector(19 downto 0);
            MEM_data_in                 : out std_logic_vector(19 downto 0);
            MEM_wreg_addr               : out std_logic_vector(4 downto 0);
            MEM_mem_addr                : out std_logic_vector(4 downto 0)
        );
end component;

component reg_mem_wb is
    port(   MEM_Mem_To_Reg, MEM_Reg_Write   : in std_logic;
            MEM_memory_data, MEM_aluop_result   : in std_logic_vector(19 downto 0);
            MEM_wreg_addr       : in std_logic_vector(4 downto 0);
            clk, reset          : in std_logic;

            wb_Mem_To_Reg, wb_Reg_Write, wb_rs_plus     : out std_logic;
            wb_memory_data, wb_aluop_result     : out std_logic_vector(19 downto 0);
            wb_wreg_addr        : out std_logic_vector(4 downto 0)
        );
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

-- pipeline signals begin
-- ID stage
signal sig_ID_PC4   : std_logic_vector(5 downto 0);
signal sig_ID_INSN, sig_ID_data_in, sig_ID_sig_flag : std_logic_vector(19 downto 0);
signal sig_ID_line_num, sig_ID_char_idx : std_logic_vector(3 downto 0);
signal sig_ID_syscall : std_logic; 
-- EX stage
signal sig_EX_mem_to_reg, sig_EX_reg_write, sig_EX_mem_write : std_logic;
signal sig_EX_ALUsrc, sig_EX_reg_dst, sig_EX_branch    : std_logic;
signal sig_EX_syscall   : std_logic;
signal sig_EX_PC4   : std_logic_vector(5 downto 0);
signal sig_EX_INSN, sig_EX_data_in  : std_logic_vector(19 downto 0);
signal sig_EX_read_data_a, sig_EX_read_data_b, sig_EX_syscall_read_data_b, sig_EX_xtnd_off  : std_logic_vector(19 downto 0);
signal sig_EX_wreg_a, sig_EX_wreg_b, sig_EX_syscall_addr    : std_logic_vector(4 downto 0);
-- MEM stage
signal sig_MEM_mem_to_reg, sig_MEM_reg_write, sig_MEM_mem_write : std_logic;
signal sig_MEM_branch, sig_MEM_carry_out, sig_MEM_syscall   : std_logic;
signal sig_MEM_aluop_result, sig_MEM_read_data_b, sig_MEM_data_in : std_logic_vector(19 downto 0);
signal sig_MEM_wreg_addr, sig_MEM_data_mem_addr : std_logic_vector(4 downto 0);
-- WB stage
signal sig_wb_mem_to_reg, sig_wb_reg_write  : std_logic;
signal sig_wb_memory_data, sig_wb_sys_add_mux  : std_logic_vector(19 downto 0);
signal sig_wb_wreg_addr : std_logic_vector(4 downto 0);

-- pipeline signals end

-- forwarding signals
signal EXMEM_fwdA, EXMEM_fwdB, MEMWB_fwdA, MEMWB_fwdB   : std_logic;
signal clear : std_logic;


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
    
    -- branch here
    bne_comparator <=  '1' when (not(sig_read_data_a = sig_IF_sig_flag) and (sig_insn(19 downto 15) = "00100")) 
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


    -- data hazard detection starts
    -- forwarding control
    EXMEM_fwdA <= '1' when (sig_MEM_reg_write = '1'
                      and sig_MEM_wreg_addr /= "00000"
                      and sig_ID_INSN(4 downto 0) = sig_MEM_wreg_addr)
                      else '0';
    EXMEM_fwdB <= '1' when (sig_MEM_reg_write = '1'
                      and sig_MEM_wreg_addr /= "00000"
                      and sig_ID_INSN(9 downto 5) = sig_MEM_wreg_addr)
                      else '0';
    MEMWB_fwdA <= '1' when (sig_wb_reg_write = '1'
                      and sig_wb_wreg_addr /= "00000"
                      and sig_ID_INSN(4 downto 0) = sig_wb_wreg_addr)
                      else '0';
    MEMWB_fwdB <= '1' when (sig_wb_reg_write = '1'
                      and sig_wb_wreg_addr /= "00000"
                      and sig_ID_INSN(9 downto 5) = sig_wb_wreg_addr)
                      else '0';

    -- pipeline forwarding
    sig_EX_read_data_a <= sig_MEM_aluop_result when EXMEM_fwdA = '1' else sig_EX_read_data_a;
    sig_EX_read_data_b <= sig_MEM_aluop_result when EXMEM_fwdB = '1' else sig_EX_read_data_b;
    sig_EX_read_data_a <= sig_write_data when MEMWB_fwdA = '1' else sig_EX_read_data_a;
    sig_EX_read_data_a <= sig_write_data when MEMWB_fwdB = '1' else sig_EX_read_data_a;

    -- end data hazard detection
    insn_mem : instruction_memory 
    port map ( reset    => reset,
               clk      => clk,
               addr_in  => sig_curr_pc,
               insn_out => sig_insn );

    -- IF/ID
    IF_ID : reg_if_id
    port map (IF_PC4 => sig_curr_pc,
              IF_INSN => sig_insn,
              IF_line_num => line_number_in,
              IF_char_idx => character_index,
              IF_data_in => data_in,
              IF_sig_flag => sig_flag,
              IF_syscall => sig_syscall
              clk => clk,
              rst => reset,
              clear => clear,
              ID_PC4 => sig_ID_PC4,
              ID_INSN => sig_ID_INSN,
              ID_line_num => sig_ID_line_num,
              ID_char_idx => sig_ID_char_idx,
              ID_data_in => sig_ID_data_in,
              ID_sig_flag => sig_ID_sig_flag,
              ID_syscall => sig_ID_syscall );
    -- ========
    
    sign_extend : sign_extend_4to16 
    port map ( data_in  => sig_ID_INSN(4 downto 0),
               data_out => sig_sign_extended_offset );

    ctrl_unit : control_unit 
    port map ( opcode     => sig_ID_INSN(19 downto 15),
               syscall    => sig_ID_syscall, 
               branch     => sig_branch, 
               reg_dst    => sig_reg_dst,
               reg_write  => sig_reg_write,
               alu_src    => sig_alu_src,
               mem_write  => sig_mem_write,
               mem_to_reg => sig_mem_to_reg );


    -- If it's a syscall, then the location in register 
    -- Comes from the testbench, so need a mux
    -- for the read_register_a and read_register_b
    
    mux_reg_read_a : mux_2to1_4b 
    port map ( mux_select => sig_ID_syscall,
               data_a     => sig_ID_INSN(14 downto 10),
               data_b     => sig_ID_line_num,
               data_out   => sig_read_register_a );
               
    mux_reg_read_b : mux_2to1_4b 
    port map ( mux_select => sig_ID_syscall,
               data_a     => sig_ID_INSN(9 downto 5),
               data_b     => sig_ID_char_idx,
               data_out   => sig_read_register_b );

    -- replace write_data and write_reg with WB pipe-back
    reg_file : register_file 
    port map ( reset           => reset, 
               clk             => clk,
               instruction     => sig_ID_INSN(19 downto 15),
               read_register_a => sig_read_register_a,
               read_register_b => sig_read_register_b,
               write_enable    => sig_reg_write,
               write_register  => sig_write_register,
               write_data      => sig_write_data,
               syscall_enable  => sig_ID_syscall, 
               read_data_a     => sig_read_data_a,
               read_data_b     => sig_read_data_b );
    
    -- These two muxes are used to help syscalls
    -- After a character is read in we need to write whether the pattern is done reading
    -- to memory for the branch instruction
    mux_syscall_mem : mux_2to1_16b 
    port map ( mux_select => sig_ID_syscall,
               data_a     => sig_read_data_b,
               data_b     => sig_ID_sig_flag,
               data_out   => sig_syscall_read_data_b );
    
    -- ID/EX
    ID_EX : reg_id_ex
    port map (ID_data_in => sig_ID_data_in,
              ID_mem_to_reg => sig_mem_to_reg,
              ID_reg_write => sig_reg_write,
              ID_mem_write => sig_mem_write,
              ID_ALUsrc => sig_alu_src,
              ID_reg_dst => sig_reg_dst,
              ID_branch => sig_branch,
              ID_syscall => sig_ID_syscall,
              ID_reg_data_rs => sig_read_data_a,
              ID_reg_data_rt => sig_read_data_b,
              ID_syscall_data_rt => sig_syscall_read_data_b,
              ID_xtnd_off => sig_sign_extended_offset,
              ID_wreg_rt => sig_read_register_b,
              ID_wreg_rd => sig_ID_INSN(4 downto 0),
              ID_syscall_addr => sig_ID_INSN(14 downto 0),

              clk => clk,
              rst => reset,
              clear => clear,

              EX_mem_to_reg => sig_EX_mem_to_reg,
              EX_reg_write => sig_EX_reg_write,
              EX_mem_write => sig_EX_mem_write,
              EX_ALUsrc => sig_EX_ALUsrc,
              EX_reg_dst => sig_EX_reg_dst,
              EX_branch => sig_EX_branch,
              EX_syscall => sig_EX_syscall,
              EX_data_in => sig_EX_data_in,
              EX_reg_data_rs => sig_EX_read_data_a,
              EX_reg_data_rt => sig_EX_read_data_b,
              EX_syscall_data_rt => sig_EX_syscall_read_data_b,
              EX_xtnd_off => sig_EX_xtnd_off,
              EX_wreg_rt => sig_EX_wreg_a,
              EX_wreg_rd => sig_EX_wreg_b,
              EX_syscall_addr => sig_EX_syscall_addr );
    -- ========


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

    -- note: replace instruction bit pos with ex_wreg_a/b
    mux_reg_dst : mux_2to1_4b 
    port map ( mux_select => sig_reg_dst,
               data_a     => sig_ID_INSN(9 downto 5),
               data_b     => sig_ID_INSN(4 downto 0),
               data_out   => sig_write_register );
    
    -- note: replace syscall bit pos with ex_syscall_addr
    mux_syscall_mem_address : mux_2to1_4b 
    port map ( mux_select => sig_ID_syscall,
               data_a     => sig_alu_result(4 downto 0),
               data_b     => sig_ID_INSN(14 downto 10),
               data_out   => data_memory_address );


    -- EX/MEM
    EX_MEM : reg_ex_mem
    port map (EX_Mem_To_Reg => sig_EX_mem_to_reg,
              EX_Reg_Write => sig_EX_reg_write,
              EX_Mem_Write => sig_EX_mem_write,
              EX_carry_out => sig_alu_carry_out,
              EX_syscall => sig_EX_syscall,
              EX_aluop_result => sig_alu_result,
              EX_reg_data_rt => sig_EX_syscall_read_data_b,
              EX_data_in => sig_EX_data_in,
              EX_wreg_addr => sig_write_register,
              EX_mem_addr => data_memory_address,

              clk => clk,
              rst => reset,
              clear => clear,

              MEM_Mem_To_Reg => sig_MEM_mem_to_reg,
              MEM_Reg_Write => sig_MEM_reg_write,
              MEM_Mem_Write => sig_MEM_mem_write,
              MEM_carry_out => sig_MEM_carry_out,
              MEM_syscall => sig_MEM_syscall,
              MEM_aluop_result => sig_MEM_aluop_result,
              MEM_reg_data_rt => sig_syscall_read_data_b,
              MEM_data_in => sig_MEM_data_in,
              MEM_wreg_addr => sig_MEM_wreg_addr,
              MEM_mem_addr => sig_MEM_data_mem_addr
            );
    -- ========


    data_mem : data_memory 
    port map ( reset        => reset,
               clk          => clk,
               write_enable => sig_mem_write,
               write_data   => sig_syscall_read_data_b,
               addr_in      => data_memory_address,
               data_out     => sig_data_mem_out );
    
    -- syscall mux (Controlled by syscall op code)
    mux_add_to_mux : mux_2to1_16b
     port map ( mux_select => sig_ID_syscall,
               data_a     => sig_alu_result,
               data_b     => sig_ID_data_in,
               data_out   => sig_sys_add_mux );


    -- EX/MEM
    MEM_WB : reg_mem_wb
    port map (MEM_Mem_To_Reg => sig_MEM_mem_to_reg,
              MEM_Reg_Write => sig_MEM_reg_write,
              MEM_memory_data => sig_data_mem_out,
              MEM_aluop_result => sig_sys_add_mux,
              MEM_wreg_addr => sig_MEM_wreg_addr,

              clk => clk,
              rst => reset,

              wb_Mem_To_Reg => sig_wb_mem_to_reg,
              wb_Reg_Write => sig_wb_reg_write,
              wb_memory_data => sig_wb_memory_data,
              wb_aluop_result => sig_wb_sys_add_mux,
              wb_wreg_addr => sig_wb_wreg_addr
            );
    -- ========


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
