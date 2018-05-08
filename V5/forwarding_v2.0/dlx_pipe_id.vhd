-- ===================================================================
-- (C)opyright 2001, 2002
-- 
-- Lehrstuhl Entwurf Mikroelektronischer Systeme
-- Prof. Wehn
-- Universitaet Kaiserslautern
-- 
-- ===================================================================
-- 
-- Autoren:  Frank Gilbert
--           Christian Neeb
--           Timo Vogt
-- 
-- ===================================================================
-- 
-- Projekt: Mikroelektronisches Praktikum
--          SS 2002
-- 
-- ===================================================================
-- 
-- Modul:
-- DLX Pipeline: Instruction Decode Stufe.
-- 
-- ===================================================================
--
-- $Author: gilbert $
-- $Date: 2002/06/18 09:36:09 $
-- $Revision: 2.1 $
-- 
-- ===================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.dlx_global.all;
use work.dlx_opcode_package.all;
-- synopsys translate_off
use work.dlx_debug.all;
-- synopsys translate_on

-- ===================================================================
entity dlx_pipe_id is

  port (
  
    clk                : in std_logic;
    rst                : in std_logic;
    stall              : in std_logic; 
    dc_wait            : in std_logic;
      
    -- NPC and IR from IF-Stage
    if_id_npc          : in dlx_word_us;
    if_id_ir           : in dlx_word;

    -- Data from Register-File
    id_a               : in dlx_word;
    id_b               : in dlx_word;                   
    
    -- Instr. Data to/from Forwarding-Ctrl
    id_opcode_class    : out Opcode_class;    
    id_ir_rs1          : out Regadr;
    id_ir_rs2          : out Regadr;
    id_a_fwd_sel       : in  Forward_select; 
    ex_mem_alu_out     : in  dlx_word;

    -- Ctrl-Signals for the DLX-Pipeline, IF Stage
    id_cond            : out std_logic;
    id_npc             : out dlx_word_us;
    id_illegal_instr   : out std_logic;
    id_halt            : out std_logic;

    -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
    id_ex_a            : out dlx_word := (others => '0');
    id_ex_b            : out dlx_word := (others => '0');
    id_ex_imm          : out Imm17    := (others => '0');
    id_ex_alu_func     : out Alu_func; 
    id_ex_alu_opb_sel  : out std_logic;
    id_ex_dm_en        : out std_logic;
    id_ex_dm_wen       : out std_logic;
    id_ex_dm_width     : out Mem_width;
    id_ex_us_sel       : out std_logic;
    id_ex_data_sel     : out std_logic;
    id_ex_reg_rd       : out RegAdr;
    id_ex_reg_wen      : out std_logic;
    id_ex_opcode_class : out Opcode_class;
    id_ex_ir_rs1       : out RegAdr;
    id_ex_ir_rs2       : out RegAdr
  
  );
  
end dlx_pipe_id;

-- ===================================================================
architecture behavior of dlx_pipe_id is

  signal iar                 : dlx_word_us;
  signal id_a_fwd            : dlx_word;
  signal id_opcode_class_int : Opcode_class;
  
  signal if_id_ir_opcode     : Opcode;
  signal if_id_ir_rs1        : Regadr;
  signal if_id_ir_rs2        : Regadr;
  signal if_id_ir_rd_rtype   : Regadr;
  signal if_id_ir_rd_itype   : Regadr;
  signal if_id_ir_spfunc     : Spfunc;
  signal if_id_ir_fpfunc     : Fpfunc;
  signal if_id_ir_imm16      : std_logic_vector( 0 to 15 );
  signal if_id_ir_imm26      : std_logic_vector( 0 to 25 );

begin
  
  -- splitting of instruction word 
  if_id_ir_opcode   <= if_id_ir(  0 to  5 );
  if_id_ir_rs1      <= if_id_ir(  6 to 10 );
  if_id_ir_rs2      <= if_id_ir( 11 to 15 );
  if_id_ir_rd_rtype <= if_id_ir( 16 to 20 );
  if_id_ir_rd_itype <= if_id_ir( 11 to 15 );
  if_id_ir_spfunc   <= if_id_ir( 26 to 31 );
  if_id_ir_fpfunc   <= if_id_ir( 27 to 31 );
  if_id_ir_imm16    <= if_id_ir( 16 to 31 );
  if_id_ir_imm26    <= if_id_ir(  6 to 31 );

  id_ir_rs1         <= if_id_ir_rs1;
  id_ir_rs2         <= if_id_ir_rs2;
  id_opcode_class   <= id_opcode_class_int;
  
  
  -- =================================================================
  -- multiplexing operand a (forwarding)
  -- =================================================================
  id_fwd_a_mux : with id_a_fwd_sel select
    id_a_fwd <= ex_mem_alu_out  when FWDSEL_EX_MEM_ALU_OUT,
                id_a            when others;
  
  
  -- =================================================================
  -- combinatorial logic
  -- =================================================================
  id_comb : process(  if_id_ir_imm16,  if_id_ir_imm26,    if_id_ir_opcode,
                      if_id_npc,       id_a_fwd,          iar,            
                      if_id_ir_spfunc, if_id_ir_rd_rtype, if_id_ir_rd_itype )

    variable imm16 : unsigned(0 to 31);
    variable imm26 : unsigned(0 to 31);
    
  begin
    id_cond          <= '0';
    id_illegal_instr <= '0';
    id_halt          <= '0';
    id_npc           <= (others => '-');      

    -- Address Calculation: 32-Unsigned-Reg. + 16/26-Signed-Immediate
    imm16( 0 to 15)  := (0 to 15 => if_id_ir_imm16(0));
    imm16(16 to 31)  := unsigned(if_id_ir_imm16);
    imm26( 0 to  5)  := (0 to  5 => if_id_ir_imm26(0));
    imm26( 6 to 31)  := unsigned(if_id_ir_imm26);
    
    case if_id_ir_opcode is
      -- ====================================================
      -- Your code for combinatorial decoder logic goes here
      -- ====================================================

      --signals to drive: id_cond, id_npc, id_halt & id_illegal_instr(for testbench)  
            -- Integer ADD (signed) (ADD)
            -- Integer ADD Unsigned (ADDU)
	    -- Subtract (Register Type signed) (SUB)
	    -- Subtract unsigned (Register Type) (SUBU)
            -- Logical AND (AND)
            -- Logical Or (OR)
            -- Logical XOR (XOR)
            -- Set On Equal To (SEQ)
            -- Set on Greater Than Or Equal To (SGE)
            -- Set On Greater Than (SGT)
            -- Set On Less Than Or Equal To (SLE)
            -- Shift Left Logical (SLL)
            -- Set On Less Than (SLT)
            -- Set On Not Equal To (SNE)
            -- Shift Right Arithmetic (SRA)
            -- Shift Right Logical (SRL)


        when op_special =>
	    -- spfunc not valid? 
            id_opcode_class_int <= RR_ALU;
            id_cond             <= '0';
            id_npc              <= (others => '-');
            
	  -- ====================================================

        -- Integer Add Immediate (signed) (ADDI)
	when op_addi =>
		id_opcode_class_int <= IM_ALU; 
     	
 	  -- ====================================================

        -- Integer ADD Unsigned Immediate (ADDUI)
        when op_addui =>
            id_opcode_class_int <= IM_ALU;

 	  -- ====================================================

        -- Logical AND Immediate (ANDI)
        when op_andi =>
            id_opcode_class_int <= IM_ALU;

 	  -- ====================================================

        -- Branch on Integer Equal To Zero (BEQZ) 
        when op_beqz =>
            id_opcode_class_int <= BRANCH;
            if (id_a_fwd = X"00_00_00_00") then
                id_npc                 <= imm16 + if_id_npc;
                id_cond                <= '1';
            end if;
            


 	  -- ====================================================

        -- Branch on Integer Not Equal To Zero (BNEZ)
        when op_bnez =>
            id_opcode_class_int <= BRANCH;
		if (id_a_fwd /= X"00_00_00_00") then
			id_npc              <= imm16 + if_id_npc;
			id_cond             <= '1';
		end if;

            

 	  -- ====================================================

        -- Jump (J)
        when op_j =>
            id_opcode_class_int <= NOFORW;
            id_cond <= '1';
            id_npc <= imm26 + if_id_npc; --if_id_npc = PC + 4 or only PC? 

 	  -- ====================================================

        -- Jump And Link Register (JALR)
        when op_jalr =>
            id_opcode_class_int <= BRANCH;
            id_cond <= '1';
            id_npc <= unsigned(id_a);
 	  -- ====================================================

        -- Jump And Link (JAL)
        when op_jal =>
            id_opcode_class_int <= NOFORW;
            id_cond <= '1';
            id_npc <= imm26 + if_id_npc;
 	  -- ====================================================

        -- Jump Register (JR)
        when op_jr =>
            id_opcode_class_int <= BRANCH;
            id_cond <= '1';
            id_npc <= unsigned(id_a);

 	  -- ====================================================

        -- Logical Or Immediate (Signed) (ORI)
        when op_ori => 
            id_opcode_class_int <= IM_ALU;

 	  -- ====================================================

        -- Set On Equal To Immediate (SEQI)
        when op_seqi => 
            id_opcode_class_int <= IM_ALU;

 	  -- ====================================================

        -- Set On Greater Or Equal To Immediate (SGEI)
        when op_sgei => 
            id_opcode_class_int <= IM_ALU;

 	  -- ====================================================

        -- Set On Greater Than Immediate (SGTI)
        when op_sgti => 
            id_opcode_class_int <= IM_ALU;

 	  -- ====================================================

        -- Set On Less Than Or Equal To Immediate (SLEI)
        when op_slei => 
            id_opcode_class_int <= IM_ALU;

 	  -- ====================================================

        -- Shift Left Logical Immediate (SLLI)
        when op_slli => 
            id_opcode_class_int <= IM_ALU;

 	  -- ====================================================

        -- Set On Less Than Immediate (SLTI)
        when op_slti => 
            id_opcode_class_int <= IM_ALU;

 	  -- ====================================================

        -- Set On Not Equal To Immediate (SNEI)
        when op_snei => 
            id_opcode_class_int <= IM_ALU;

 	  -- ====================================================

        -- Shift Right Arithmetic Immediate (SRAI)
        when op_srai => 
            id_opcode_class_int <= IM_ALU;

 	  -- ====================================================

        -- Shift Right Logical Immediate (SRLI)
        when op_srli => 
            id_opcode_class_int <= IM_ALU;

 	  -- ====================================================

        -- Trap (TRAP)
        when op_trap => 
            id_opcode_class_int <= NOFORW;
            id_cond             <= '1';
	    id_halt 		<= '1';
            id_npc              <= imm26;

 	  -- ====================================================

        -- Logical XOR Immediate (Signed) (XORI)       
        when op_xori =>
			id_opcode_class_int <= IM_ALU;

	  -- ====================================================

        -- Load High Immediate (LHI)
        when op_lhi =>
            id_opcode_class_int <= IM_ALU;

	  -- ====================================================

		-- NOP
		--when op_nop =>
		--	id_opcode_class_int <= NOFORW;

	  -- ====================================================

		-- Load Byte (signed)
		when op_lb =>
			id_opcode_class_int <= LOAD;

	  -- ====================================================

		-- Load Byte unsigned
		when op_lbu =>
			id_opcode_class_int <= LOAD;
			
	  -- ====================================================
		-- Load Half-Word (signed)
		when op_lh =>
			id_opcode_class_int <= LOAD;
			
	  -- ====================================================

		-- Load Half-Word unsigned
		when op_lhu =>
			id_opcode_class_int <= LOAD;
			
	  -- ====================================================

		-- Load Word
		when op_lw =>
			id_opcode_class_int <= LOAD;

 	  -- ====================================================

		-- Store Byte
		when op_sb =>
			id_opcode_class_int <= STORE;

	  -- ====================================================

		-- Store Half-Word
		when op_sh =>
			id_opcode_class_int <= STORE;
		
	  -- ====================================================

		-- Store Word
		when op_sw =>
			id_opcode_class_int <= STORE;

	  -- ====================================================

		-- Subtract immediate (signed) (SUBI)
		when op_subi =>
			id_opcode_class_int <= IM_ALU;
		
	  -- ====================================================

		-- Subtract immediate unsigned (SUBUI)
		when op_subui =>
			id_opcode_class_int <= IM_ALU;
      -- ====================================================


      when others =>
        id_opcode_class_int <= NOFORW;
        id_illegal_instr    <= '1';
    end case;
  end process id_comb;


  -- =================================================================
  -- sequential logic (clocked process)
  -- =================================================================
  id_seq : process( clk )
  begin
    if clk'event and clk = '1' then
      if rst = '1' then
        iar                 <= X"00_00_00_00"; 
        id_ex_dm_wen        <= '0';
        id_ex_dm_en         <= '0';
        id_ex_reg_wen       <= '0';
        id_ex_a             <= X"00_00_00_00";
        id_ex_b             <= X"00_00_00_00";
        id_ex_imm           <= '0' & X"00_00";
        id_ex_opcode_class  <= NOFORW;

      else

        -- synopsys translate_off
        debug_disassemble (if_id_ir);            
        -- synopsys translate_on

        if dc_wait = '0' then
          -- NOP Verhalten als Default
          id_ex_a            <= id_a;
          id_ex_b            <= id_b;
          id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
          id_ex_alu_opb_sel  <= SEL_ID_EX_B;
          id_ex_us_sel       <= SEL_SIGNED;
          id_ex_data_sel     <= SEL_ALU_OUT;
          id_ex_alu_func     <= alu_add;
          id_ex_dm_wen       <= '0';
          id_ex_dm_en        <= '0';
          id_ex_reg_rd       <= REG_0;
          id_ex_reg_wen      <= '0';
          id_ex_ir_rs1       <= if_id_ir_rs1;
          id_ex_ir_rs2       <= if_id_ir_rs2;
  
          if stall = '1' then
            id_ex_opcode_class <= NOFORW;
          else
            id_ex_opcode_class <= id_opcode_class_int;

            -- von NOP abweichendes Verhalten
            case if_id_ir_opcode is
              -- ====================================================
              -- Your code for sequential decoder logic goes here
              -- ====================================================  
                -- Integer ADD (signed) (ADD)
                -- Integer ADD Unsigned (ADDU)
		        -- Subtract (Register Type signed) (SUB)
		        -- Subtract unsigned (Register Type) (SUBU)
                -- Logical AND (AND)
                -- Logical Or (OR)
                -- Logical XOR (XOR)
                -- Set On Equal To (SEQ)
                -- Set On Not Equal To (SNE)
                -- Set on Greater Than Or Equal To (SGE)
                -- Set On Greater Than (SGT)
                -- Set On Less Than Or Equal To (SLE)
                -- Set On Less Than (SLT)
                -- Shift Left Logical (SLL)
                -- Shift Right Arithmetic (SRA)
                -- Shift Right Logical (SRL)

              when op_special =>
                  case if_id_ir_spfunc is
                      when sp_add => -- integer ADD (signed)
                          id_ex_a            <= id_a;
                          id_ex_b            <= id_b;
                          id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
                          id_ex_alu_opb_sel  <= SEL_ID_EX_B;
                          id_ex_us_sel       <= SEL_SIGNED;
                          id_ex_data_sel     <= SEL_ALU_OUT;
                          id_ex_alu_func     <= alu_add;
                          id_ex_dm_width     <= MEM_WIDTH_WORD;
                          id_ex_dm_wen       <= '0';
                          id_ex_dm_en        <= '0';
                          id_ex_reg_rd       <= if_id_ir_rd_rtype;
                          id_ex_reg_wen      <= '1';
                          id_ex_ir_rs1       <= if_id_ir_rs1;
                          id_ex_ir_rs2       <= if_id_ir_rs2;
                      when sp_addu => --  Integer ADD Unsigned (ADDU)
                          id_ex_a            <= id_a;
                          id_ex_b            <= id_b;
                          id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
                          id_ex_alu_opb_sel  <= SEL_ID_EX_B;
                          id_ex_us_sel       <= SEL_UNSIGNED;
                          id_ex_data_sel     <= SEL_ALU_OUT;
                          id_ex_alu_func     <= alu_add;
                          id_ex_dm_width     <= MEM_WIDTH_WORD;
                          id_ex_dm_wen       <= '0';
                          id_ex_dm_en        <= '0';
                          id_ex_reg_rd       <= if_id_ir_rd_rtype;
                          id_ex_reg_wen      <= '1';
                          id_ex_ir_rs1       <= if_id_ir_rs1;
                          id_ex_ir_rs2       <= if_id_ir_rs2;
                      when sp_sub => --  Subtract (Register Type signed) (SUB)
                          id_ex_a            <= id_a;
                          id_ex_b            <= id_b;
                          id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
                          id_ex_alu_opb_sel  <= SEL_ID_EX_B;
                          id_ex_us_sel       <= SEL_SIGNED;
                          id_ex_data_sel     <= SEL_ALU_OUT;
                          id_ex_alu_func     <= alu_sub;
                          id_ex_dm_width     <= MEM_WIDTH_WORD;
                          id_ex_dm_wen       <= '0';
                          id_ex_dm_en        <= '0';
                          id_ex_reg_rd       <= if_id_ir_rd_rtype;
                          id_ex_reg_wen      <= '1';
                          id_ex_ir_rs1       <= if_id_ir_rs1;
                          id_ex_ir_rs2       <= if_id_ir_rs2;
                      when sp_subu => --  Subtract unsigned (Register Type) (SUBU)
                          id_ex_a            <= id_a;
                          id_ex_b            <= id_b;
                          id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
                          id_ex_alu_opb_sel  <= SEL_ID_EX_B;
                          id_ex_us_sel       <= SEL_UNSIGNED;
                          id_ex_data_sel     <= SEL_ALU_OUT;
                          id_ex_alu_func     <= alu_sub;
                          id_ex_dm_width     <= MEM_WIDTH_WORD;
                          id_ex_dm_wen       <= '0';
                          id_ex_dm_en        <= '0';
                          id_ex_reg_rd       <= if_id_ir_rd_rtype;
                          id_ex_reg_wen      <= '1';
                          id_ex_ir_rs1       <= if_id_ir_rs1;
                          id_ex_ir_rs2       <= if_id_ir_rs2;
                      when sp_and => --  Logical AND (AND)
                          id_ex_a            <= id_a;
                          id_ex_b            <= id_b;
                          id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
                          id_ex_alu_opb_sel  <= SEL_ID_EX_B;
                          id_ex_us_sel       <= SEL_SIGNED;
                          id_ex_data_sel     <= SEL_ALU_OUT;
                          id_ex_alu_func     <= alu_and;
                          id_ex_dm_width     <= MEM_WIDTH_WORD;
                          id_ex_dm_wen       <= '0';
                          id_ex_dm_en        <= '0';
                          id_ex_reg_rd       <= if_id_ir_rd_rtype;
                          id_ex_reg_wen      <= '1';
                          id_ex_ir_rs1       <= if_id_ir_rs1;
                          id_ex_ir_rs2       <= if_id_ir_rs2;
                      when sp_or => --  Logical Or (OR)
                          id_ex_a            <= id_a;
                          id_ex_b            <= id_b;
                          id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
                          id_ex_alu_opb_sel  <= SEL_ID_EX_B;
                          id_ex_us_sel       <= SEL_SIGNED;
                          id_ex_data_sel     <= SEL_ALU_OUT;
                          id_ex_alu_func     <= alu_or;
                          id_ex_dm_width     <= MEM_WIDTH_WORD;
                          id_ex_dm_wen       <= '0';
                          id_ex_dm_en        <= '0';
                          id_ex_reg_rd       <= if_id_ir_rd_rtype;
                          id_ex_reg_wen      <= '1';
                          id_ex_ir_rs1       <= if_id_ir_rs1;
                          id_ex_ir_rs2       <= if_id_ir_rs2;
                      when sp_xor => --  Logical Xor (XOR)
                          id_ex_a            <= id_a;
                          id_ex_b            <= id_b;
                          id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
                          id_ex_alu_opb_sel  <= SEL_ID_EX_B;
                          id_ex_us_sel       <= SEL_SIGNED;
                          id_ex_data_sel     <= SEL_ALU_OUT;
                          id_ex_alu_func     <= alu_xor;
                          id_ex_dm_width     <= MEM_WIDTH_WORD;
                          id_ex_dm_wen       <= '0';
                          id_ex_dm_en        <= '0';
                          id_ex_reg_rd       <= if_id_ir_rd_rtype;
                          id_ex_reg_wen      <= '1';
                          id_ex_ir_rs1       <= if_id_ir_rs1;
                          id_ex_ir_rs2       <= if_id_ir_rs2;
                      when sp_seq => --  Set On Equal To (SEQ)
                          id_ex_a            <= id_a;
                          id_ex_b            <= id_b;
                          id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
                          id_ex_alu_opb_sel  <= SEL_ID_EX_B;
                          id_ex_us_sel       <= SEL_SIGNED;
                          id_ex_data_sel     <= SEL_ALU_OUT;
                          id_ex_alu_func     <= alu_seq;
                          id_ex_dm_width     <= MEM_WIDTH_WORD;
                          id_ex_dm_wen       <= '0';
                          id_ex_dm_en        <= '0';
                          id_ex_reg_rd       <= if_id_ir_rd_rtype;
                          id_ex_reg_wen      <= '1';
                          id_ex_ir_rs1       <= if_id_ir_rs1;
                          id_ex_ir_rs2       <= if_id_ir_rs2;
                      when sp_sne => --  Set On Not Equal To (SNE)
                          id_ex_a            <= id_a;
                          id_ex_b            <= id_b;
                          id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
                          id_ex_alu_opb_sel  <= SEL_ID_EX_B;
                          id_ex_us_sel       <= SEL_SIGNED;
                          id_ex_data_sel     <= SEL_ALU_OUT;
                          id_ex_alu_func     <= alu_sne;
                          id_ex_dm_width     <= MEM_WIDTH_WORD;
                          id_ex_dm_wen       <= '0';
                          id_ex_dm_en        <= '0';
                          id_ex_reg_rd       <= if_id_ir_rd_rtype;
                          id_ex_reg_wen      <= '1';
                          id_ex_ir_rs1       <= if_id_ir_rs1;
                          id_ex_ir_rs2       <= if_id_ir_rs2;
                      when sp_sge => --  Set on Greater Than Or Equal To (SGE)
                          id_ex_a            <= id_a;
                          id_ex_b            <= id_b;
                          id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
                          id_ex_alu_opb_sel  <= SEL_ID_EX_B;
                          id_ex_us_sel       <= SEL_SIGNED;
                          id_ex_data_sel     <= SEL_ALU_OUT;
                          id_ex_alu_func     <= alu_sge;
                          id_ex_dm_width     <= MEM_WIDTH_WORD;
                          id_ex_dm_wen       <= '0';
                          id_ex_dm_en        <= '0';
                          id_ex_reg_rd       <= if_id_ir_rd_rtype;
                          id_ex_reg_wen      <= '1';
                          id_ex_ir_rs1       <= if_id_ir_rs1;
                          id_ex_ir_rs2       <= if_id_ir_rs2;
                      when sp_sgt => --  Set On Greater Than (SGT)
                          id_ex_a            <= id_a;
                          id_ex_b            <= id_b;
                          id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
                          id_ex_alu_opb_sel  <= SEL_ID_EX_B;
                          id_ex_us_sel       <= SEL_SIGNED;
                          id_ex_data_sel     <= SEL_ALU_OUT;
                          id_ex_alu_func     <= alu_sgt;
                          id_ex_dm_width     <= MEM_WIDTH_WORD;
                          id_ex_dm_wen       <= '0';
                          id_ex_dm_en        <= '0';
                          id_ex_reg_rd       <= if_id_ir_rd_rtype;
                          id_ex_reg_wen      <= '1';
                          id_ex_ir_rs1       <= if_id_ir_rs1;
                          id_ex_ir_rs2       <= if_id_ir_rs2;
                      when sp_sle => --  Set On Less Than Or Equal To (SLE)
                          id_ex_a            <= id_a;
                          id_ex_b            <= id_b;
                          id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
                          id_ex_alu_opb_sel  <= SEL_ID_EX_B;
                          id_ex_us_sel       <= SEL_UNSIGNED;
                          id_ex_data_sel     <= SEL_ALU_OUT;
                          id_ex_alu_func     <= alu_sle;
                          id_ex_dm_width     <= MEM_WIDTH_WORD;
                          id_ex_dm_wen       <= '0';
                          id_ex_dm_en        <= '0';
                          id_ex_reg_rd       <= if_id_ir_rd_rtype;
                          id_ex_reg_wen      <= '1';
                          id_ex_ir_rs1       <= if_id_ir_rs1;
                          id_ex_ir_rs2       <= if_id_ir_rs2;
                      when sp_slt => --  Set On Less Than (SLT)
                          id_ex_a            <= id_a;
                          id_ex_b            <= id_b;
                          id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
                          id_ex_alu_opb_sel  <= SEL_ID_EX_B;
                          id_ex_us_sel       <= SEL_SIGNED;
                          id_ex_data_sel     <= SEL_ALU_OUT;
                          id_ex_alu_func     <= alu_slt;
                          id_ex_dm_width     <= MEM_WIDTH_WORD;
                          id_ex_dm_wen       <= '0';
                          id_ex_dm_en        <= '0';
                          id_ex_reg_rd       <= if_id_ir_rd_rtype;
                          id_ex_reg_wen      <= '1';
                          id_ex_ir_rs1       <= if_id_ir_rs1;
                          id_ex_ir_rs2       <= if_id_ir_rs2;
                      when sp_sll => --  Shift Left Logical (SLL)
                          id_ex_a            <= id_a;
                          id_ex_b            <= "000000000000000000000000000" & id_b (27 to 31);
                          id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
                          id_ex_alu_opb_sel  <= SEL_ID_EX_B;
                          id_ex_us_sel       <= SEL_SIGNED;
                          id_ex_data_sel     <= SEL_ALU_OUT;
                          id_ex_alu_func     <= alu_sll;
                          id_ex_dm_width     <= MEM_WIDTH_WORD;
                          id_ex_dm_wen       <= '0';
                          id_ex_dm_en        <= '0';
                          id_ex_reg_rd       <= if_id_ir_rd_rtype;
                          id_ex_reg_wen      <= '1';
                          id_ex_ir_rs1       <= if_id_ir_rs1;
                          id_ex_ir_rs2       <= if_id_ir_rs2;
                      when sp_srl => --  Shift Right Logical (SRL)
                          id_ex_a            <= id_a;
                          id_ex_b            <= "000000000000000000000000000" & id_b (27 to 31);
                          id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
                          id_ex_alu_opb_sel  <= SEL_ID_EX_B;
                          id_ex_us_sel       <= SEL_UNSIGNED;
                          id_ex_data_sel     <= SEL_ALU_OUT;
                          id_ex_alu_func     <= alu_srl;
                          id_ex_dm_width     <= MEM_WIDTH_WORD;
                          id_ex_dm_wen       <= '0';
                          id_ex_dm_en        <= '0';
                          id_ex_reg_rd       <= if_id_ir_rd_rtype;
                          id_ex_reg_wen      <= '1';
                          id_ex_ir_rs1       <= if_id_ir_rs1;
                          id_ex_ir_rs2       <= if_id_ir_rs2;
                      when sp_sra => -- Shift Right Arithmetic (SRA)
                          id_ex_a            <= id_a;
                          id_ex_b            <= "000000000000000000000000000" & id_b (27 to 31);
                          id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
                          id_ex_alu_opb_sel  <= SEL_ID_EX_B;
                          id_ex_us_sel       <= SEL_UNSIGNED;
                          id_ex_data_sel     <= SEL_ALU_OUT;
                          id_ex_alu_func     <= alu_sra;
                          id_ex_dm_width     <= MEM_WIDTH_WORD;
                          id_ex_dm_wen       <= '0';
                          id_ex_dm_en        <= '0';
                          id_ex_reg_rd       <= if_id_ir_rd_rtype;
                          id_ex_reg_wen      <= '1';
                          id_ex_ir_rs1       <= if_id_ir_rs1;
                          id_ex_ir_rs2       <= if_id_ir_rs2;
                      when others => --nop
								 id_ex_a            <= id_a;
								 id_ex_b            <= id_b;
								 id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
								 id_ex_alu_opb_sel  <= SEL_ID_EX_B;
								 id_ex_us_sel       <= SEL_SIGNED;
								 id_ex_data_sel     <= SEL_ALU_OUT;
								 id_ex_alu_func     <= alu_add;
								 id_ex_dm_wen       <= '0';
								 id_ex_dm_en        <= '0';
								 id_ex_reg_rd       <= REG_0;
								 id_ex_reg_wen      <= '0';
								 id_ex_ir_rs1       <= if_id_ir_rs1;
								 id_ex_ir_rs2       <= if_id_ir_rs2;
                  end case;

              when op_addi =>
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_SIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_add;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;--REG_0;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
              when op_addui =>
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= '0' & if_id_ir_imm16;
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_UNSIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_add;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;--REG_0;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
              when op_andi =>
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= '0' & if_id_ir_imm16;
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_SIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_and;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;--REG_0;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
              when op_ori =>
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= '0' & if_id_ir_imm16;
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_SIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_or;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;--REG_0;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
              when op_xori =>
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= '0' & if_id_ir_imm16;
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_SIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_xor;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;--REG_0;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
              when op_subi =>
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_SIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_sub;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;--REG_0;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
              when op_subui =>
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= '0' & if_id_ir_imm16;
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_UNSIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_sub;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;--REG_0;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
             when op_lhi => --I Format
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= if_id_ir_imm16 & X"00_00"; 				--X"00_00" & if_id_ir_imm16 ;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16; --'0' & if_id_ir_imm16; -- '0' & X"00_00_00_10"
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_UNSIGNED; 
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_a;--alu_sll;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;

              when op_seqi =>
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16; 
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_SIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_seq;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;--REG_0;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
              when op_snei =>
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16; 
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_SIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_sne;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;--REG_0;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
              when op_sgei =>
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16; 
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_SIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_sge;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;--REG_0;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
              when op_slei =>
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16; 
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_SIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_sle;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;--REG_0;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
              when op_sgti =>
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16; 
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_SIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_sgt;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;--REG_0;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
              when op_slti =>
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16; 
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_SIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_slt;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;--REG_0;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;

                --SHIFTING
              when op_slli =>
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a_fwd;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= "0" & "00000000000" & if_id_ir_imm16 (11 to 15);  
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_UNSIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_sll;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
              when op_srli =>
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a_fwd;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= "0" & "00000000000" & if_id_ir_imm16 (11 to 15);  
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_UNSIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_srl;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
              when op_srai =>
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a_fwd;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= "0" & "00000000000" & if_id_ir_imm16 (11 to 15);  
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_UNSIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_sra;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
              --when op_nop =>
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
              --    id_ex_a            <= id_a;
              --    id_ex_b            <= id_b;
              --    id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
              --    id_ex_alu_opb_sel  <= SEL_ID_EX_B;
              --    id_ex_us_sel       <= SEL_SIGNED;
              --    id_ex_data_sel     <= SEL_ALU_OUT;
              --    id_ex_alu_func     <= alu_add;
              --    id_ex_dm_width     <= MEM_WIDTH_WORD;
              --    id_ex_dm_wen       <= '0';
              --    id_ex_dm_en        <= '0';
              --    id_ex_reg_rd       <= REG_0;
              --    id_ex_reg_wen      <= '0';
              --    id_ex_ir_rs1       <= if_id_ir_rs1;
              --    id_ex_ir_rs2       <= if_id_ir_rs2;
              when op_trap => --J Format
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                    iar                <= if_id_npc + X"00_00_00_04";            
              --    id_ex_a            <= id_a;
              --    id_ex_b            <= id_b;
              --    id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16; 
              --    id_ex_alu_opb_sel  <= SEL_ID_EX_B;
              --    id_ex_us_sel       <= SEL_SIGNED;
              --    id_ex_data_sel     <= SEL_ALU_OUT;
              --    id_ex_alu_func     <= alu_add;
              --    id_ex_dm_width     <= MEM_WIDTH_WORD;
              --    id_ex_dm_wen       <= '0';
              --    id_ex_dm_en        <= '0';
              --    id_ex_reg_rd       <= REG_0;--REG_0;
              --    id_ex_reg_wen      <= '0';
              --    id_ex_ir_rs1       <= if_id_ir_rs1;
              --    id_ex_ir_rs2       <= if_id_ir_rs2;
             when op_j => --J Format
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16; 
                  id_ex_alu_opb_sel  <= SEL_ID_EX_B;
                  id_ex_us_sel       <= SEL_SIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_add;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= REG_0;
                  id_ex_reg_wen      <= '0';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
             when op_jalr => --I Format
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= std_logic_vector(if_id_npc); --PC + 4 
                  id_ex_b            <= id_b;
                  id_ex_imm          <= '0' & X"00_04";
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_UNSIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_add;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= REG_31;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
             when op_jal => --I Format
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= std_logic_vector(if_id_npc);
                  id_ex_b            <= id_b;
                  id_ex_imm          <= '0' & X"00_04";
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_SIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_add;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= REG_31;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
             when op_jr => --I Format
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16; 
                  id_ex_alu_opb_sel  <= SEL_ID_EX_B;
                  id_ex_us_sel       <= SEL_SIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_add;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= REG_0;
                  id_ex_reg_wen      <= '0';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
             when op_beqz => --I Format
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= (others => '0');--X"00_00_00_00"; 
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_UNSIGNED;
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_seq;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= REG_0;
                  id_ex_reg_wen      <= '0';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
             when op_bnez => --I Format
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= (others => '0'); --X"00_00_00_00"; 
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_UNSIGNED; --SIGNED??
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_sne;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '0';
                  id_ex_reg_rd       <= REG_0;
                  id_ex_reg_wen      <= '0';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
             when op_lb => --I Format
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16; 
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_SIGNED; 
                  id_ex_data_sel     <= SEL_DM_OUT;
                  id_ex_alu_func     <= alu_add;
                  id_ex_dm_width     <= MEM_WIDTH_BYTE;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '1';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
             when op_lbu => --I Format
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16; 
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_UNSIGNED; 
                  id_ex_data_sel     <= SEL_DM_OUT;
                  id_ex_alu_func     <= alu_add;
                  id_ex_dm_width     <= MEM_WIDTH_BYTE;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '1';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
             when op_lh => --I Format
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16; 
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_SIGNED; 
                  id_ex_data_sel     <= SEL_DM_OUT;
                  id_ex_alu_func     <= alu_add;
                  id_ex_dm_width     <= MEM_WIDTH_HALFWORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '1';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
             when op_lhu => --I Format
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16; 
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_UNSIGNED; 
                  id_ex_data_sel     <= SEL_DM_OUT;
                  id_ex_alu_func     <= alu_add;
                  id_ex_dm_width     <= MEM_WIDTH_HALFWORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '1';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
             when op_lw => --I Format
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b;
                  id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16; 
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_UNSIGNED; 
                  id_ex_data_sel     <= SEL_DM_OUT;
                  id_ex_alu_func     <= alu_add;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '0';
                  id_ex_dm_en        <= '1';
                  id_ex_reg_rd       <= if_id_ir_rd_itype;
                  id_ex_reg_wen      <= '1';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;
               when op_sb => --I Format
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b; --rd/ex_dm_data_sel = '00' -> DEFAULT (NO FORWARDING)
                  id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16; 
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_UNSIGNED; 
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_add;
                  id_ex_dm_width     <= MEM_WIDTH_BYTE;
                  id_ex_dm_wen       <= '1';
                  id_ex_dm_en        <= '1';
                  id_ex_reg_rd       <= REG_0;
                  id_ex_reg_wen      <= '0';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;  
               when op_sh => --I Format
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b; --rd/ex_dm_data_sel = '00' -> DEFAULT (NO FORWARDING)
                  id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16; 
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_UNSIGNED; 
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_add;
                  id_ex_dm_width     <= MEM_WIDTH_HALFWORD;
                  id_ex_dm_wen       <= '1';
                  id_ex_dm_en        <= '1';
                  id_ex_reg_rd       <= REG_0;
                  id_ex_reg_wen      <= '0';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;   
               when op_sw => --I Format
                -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
                  id_ex_a            <= id_a;
                  id_ex_b            <= id_b; --rd/ex_dm_data_sel = '00' -> DEFAULT (NO FORWARDING)
                  id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16; 
                  id_ex_alu_opb_sel  <= SEL_ID_EX_IMM;
                  id_ex_us_sel       <= SEL_UNSIGNED; 
                  id_ex_data_sel     <= SEL_ALU_OUT;
                  id_ex_alu_func     <= alu_add;
                  id_ex_dm_width     <= MEM_WIDTH_WORD;
                  id_ex_dm_wen       <= '1';
                  id_ex_dm_en        <= '1';
                  id_ex_reg_rd       <= REG_0;
                  id_ex_reg_wen      <= '0';
                  id_ex_ir_rs1       <= if_id_ir_rs1;
                  id_ex_ir_rs2       <= if_id_ir_rs2;                     

--op_lhi not correct!

              when others => null;
                -- Tue nichts. Illegal-Instruktion wird kombinatorisch
                -- generiert !!!
            end case;  
          end if;  -- stall
        end if;  -- wait
      end if;  -- rst
    end if;  -- clk
  end process id_seq;

end behavior;
