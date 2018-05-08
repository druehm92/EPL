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
-- DLX Pipeline Controller. Erzeugt Pipeline-Stall bei nicht 
-- aufloesbaren Datenabhaengigkeiten und steuert die "forwarding"
-- Logik.
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
use work.dlx_global.all;


-- ===================================================================
entity dlx_pipe_ctrl is


  port(
      
    id_ir_rs1           : in RegAdr;
    id_ir_rs2           : in RegAdr;
    id_opcode_class     : in Opcode_class;
    
    id_ex_opcode_class  : in Opcode_class;
    id_ex_ir_rs1        : in RegAdr;
    id_ex_ir_rs2        : in RegAdr;
    id_ex_reg_rd        : in RegAdr;

    ex_mem_opcode_class : in Opcode_class;
    ex_mem_reg_rd       : in RegAdr;

    mem_wb_opcode_class : in Opcode_class;
    mem_wb_reg_rd       : in RegAdr;
    
    ic_ready            : in std_logic;    
    dc_ready            : in std_logic;    

    id_a_fwd_sel        : out Forward_select;
    ex_alu_opa_sel      : out Forward_select;
    ex_alu_opb_sel      : out Forward_select;
    ex_dm_data_sel      : out Forward_select;

    stall               : out std_logic;
    dc_wait             : out std_logic
    
  );
  
end dlx_pipe_ctrl;


-- ===================================================================
architecture behavior of dlx_pipe_ctrl is
begin

  dc_wait <= not dc_ready;


  -- =================================================================
  -- Pipeline-Stall control to resolve data-dependencies
  -- =================================================================
  stall_ctrl : process ( id_opcode_class,     id_ex_opcode_class, 
                         ex_mem_opcode_class, id_ir_rs1, 
                         id_ir_rs2,           id_ex_reg_rd, 
                         ex_mem_reg_rd,       ic_ready )
  begin
    stall <= '0';
    if ic_ready = '0' then
      -- Instruction Cache Miss: IF and ID-Stage must be stalled
      -- because of Branch-Instructions, the rest of the pipeline
      -- may continue to resolve data dependencies.
      -- ic_ready = '0' => stall = '1'
      
      stall <= '1';
    else
      case id_opcode_class is
        when BRANCH | MOVEI2S =>
          if (    id_ex_opcode_class = LOAD
               or id_ex_opcode_class = RR_ALU
               or id_ex_opcode_class = IM_ALU 
               or id_ex_opcode_class = MOVES2I ) 
             and id_ir_rs1 = id_ex_reg_rd 
          then
            stall <= '1';
          end if;
          if (    ex_mem_opcode_class = LOAD
               or ex_mem_opcode_class = MOVES2I ) 
             and id_ir_rs1 = ex_mem_reg_rd
          then
            stall <= '1';
          end if;
          
        
        -- =================================================
        -- Your code goes here (LOAD, STORE, RR_ALU, IM_ALU)
        -- =================================================

        when LOAD => --LOAD
          if (    id_ex_opcode_class = LOAD
             and id_ir_rs1 = id_ex_reg_rd )
          then
            stall <= '1';
          end if;
          if (    ex_mem_opcode_class = LOAD
             and id_ir_rs1 = ex_mem_reg_rd)
          then
            stall <= '1';
          end if;  

        when STORE => --STORE
          if (    id_ex_opcode_class = LOAD
             and (id_ir_rs1 = id_ex_reg_rd
             or   id_ir_rs2  = id_ex_reg_rd ))
          then
            stall <= '1';
          end if;
          if (    ex_mem_opcode_class = LOAD
             and (id_ir_rs1 = ex_mem_reg_rd
             or   id_ir_rs2 = ex_mem_reg_rd))
          then
            stall <= '1';
          end if;  


        when RR_ALU => --RR_ALU
          if (    id_ex_opcode_class = LOAD
               or id_ex_opcode_class = MOVES2I ) 
             and (id_ir_rs1 = id_ex_reg_rd or id_ir_rs2 = id_ex_reg_rd) 
          then
            stall <= '1';
          end if;
          if (    ex_mem_opcode_class = LOAD
               or ex_mem_opcode_class = MOVES2I ) 
             and (id_ir_rs1 = ex_mem_reg_rd or id_ir_rs2 = ex_mem_reg_rd)
          then
            stall <= '1';
          end if; 


        when IM_ALU => --IM_ALU
          if ((    id_ex_opcode_class = LOAD
               or id_ex_opcode_class = MOVES2I ) 
             and id_ir_rs1 = id_ex_reg_rd)
          then
            stall <= '1';
          end if;
          if ((    ex_mem_opcode_class = LOAD
               or ex_mem_opcode_class = MOVES2I ) 
             and id_ir_rs1 = ex_mem_reg_rd)
          then
            stall <= '1';
          end if; 

        when others =>
          -- Do Nothing
      end case;
    end if; -- if ic_ready = '1' then
  end process stall_ctrl;

  
  -- =================================================================
  -- Forwarding Control
  -- =================================================================
  pipe_ctrl : process (
                       id_opcode_class,     id_ex_opcode_class, 
                       id_ex_ir_rs1,        id_ex_ir_rs2,       id_ex_reg_rd,
                       id_ir_rs1,           id_ir_rs2,
                       ex_mem_opcode_class, ex_mem_reg_rd, 
                       mem_wb_opcode_class, mem_wb_reg_rd
                      )

  begin

    -- ==================================
    -- Default behaviour: no forwarding
    -- ==================================    
    id_a_fwd_sel    <= FWDSEL_NOFORW;
    ex_alu_opa_sel  <= FWDSEL_NOFORW;
    ex_alu_opb_sel  <= FWDSEL_NOFORW;
    ex_dm_data_sel  <= FWDSEL_NOFORW;        

    -- ======================================
    -- Forward EX/MEM -> ID (BRANCH/MOVEI2S)
    -- ======================================
    case id_opcode_class is
      when BRANCH | MOVEI2S =>
        if (    ex_mem_opcode_class = RR_ALU
             or ex_mem_opcode_class = IM_ALU ) 
           and id_ir_rs1 = ex_mem_reg_rd
        then
          id_a_fwd_sel <= FWDSEL_EX_MEM_ALU_OUT;
        end if;
        
      when others =>
        -- Do Nothing
    end case;
    
	 
    -- ===============================================
    -- Forward EX/MEM -> EX (LOAD/STORE/RR_ALU/IM_ALU)
    -- ===============================================
    case id_ex_opcode_class is
      -- ===============================
      -- Your code goes here
      -- ===============================
      when LOAD   => 
         if ((ex_mem_opcode_class = IM_ALU or ex_mem_opcode_class = RR_ALU) and id_ex_ir_rs1 = ex_mem_reg_rd  ) then
            ex_alu_opa_sel <= FWDSEL_EX_MEM_ALU_OUT;
         end if; 
			if ((mem_wb_opcode_class = IM_ALU or mem_wb_opcode_class = RR_ALU) and id_ex_ir_rs1 = mem_wb_reg_rd  ) then
            ex_alu_opa_sel <= FWDSEL_MEM_WB_DATA;
         end if; 

      when STORE  =>
         if ((ex_mem_opcode_class = IM_ALU or ex_mem_opcode_class = RR_ALU) and id_ex_ir_rs1 = ex_mem_reg_rd  ) then
            ex_alu_opa_sel <= FWDSEL_EX_MEM_ALU_OUT;
         end if; 
         if ((ex_mem_opcode_class = IM_ALU or ex_mem_opcode_class = RR_ALU) and id_ex_reg_rd = ex_mem_reg_rd  ) then
            ex_dm_data_sel <= FWDSEL_EX_MEM_ALU_OUT;
         end if; 
			if ((mem_wb_opcode_class = IM_ALU or mem_wb_opcode_class = RR_ALU) and id_ex_ir_rs1 = mem_wb_reg_rd  ) then
            ex_alu_opa_sel <= FWDSEL_MEM_WB_DATA;
         end if; 

      when RR_ALU =>
         if ((ex_mem_opcode_class = IM_ALU or ex_mem_opcode_class = RR_ALU) and id_ex_ir_rs1 = ex_mem_reg_rd  ) then
            ex_alu_opa_sel <= FWDSEL_EX_MEM_ALU_OUT;
         end if; 
         if ((ex_mem_opcode_class = IM_ALU or ex_mem_opcode_class = RR_ALU) and id_ex_ir_rs2 = ex_mem_reg_rd) then
            ex_alu_opb_sel <= FWDSEL_EX_MEM_ALU_OUT;
         end if;
         if ((mem_wb_opcode_class = IM_ALU or mem_wb_opcode_class = RR_ALU) and id_ex_ir_rs1 = mem_wb_reg_rd  ) then
            ex_alu_opa_sel <= FWDSEL_MEM_WB_DATA;
         end if; 
         if ((mem_wb_opcode_class = IM_ALU or mem_wb_opcode_class = RR_ALU) and id_ex_ir_rs2 = mem_wb_reg_rd) then
            ex_alu_opb_sel <= FWDSEL_MEM_WB_DATA;
         end if;

      when IM_ALU =>
         if ((ex_mem_opcode_class = IM_ALU or ex_mem_opcode_class = RR_ALU) and id_ex_ir_rs1 = ex_mem_reg_rd  ) then
            ex_alu_opa_sel <= FWDSEL_EX_MEM_ALU_OUT;
         end if; 
         if ((mem_wb_opcode_class = IM_ALU or mem_wb_opcode_class = RR_ALU) and id_ex_ir_rs1 = mem_wb_reg_rd  ) then
            ex_alu_opa_sel <= FWDSEL_MEM_WB_DATA;
         end if;  

      when others =>
        -- Do Nothing
    end case;
 
    -- =============================
    -- Forward MEM/WB -> MEM (STORE)
    -- =============================
    case ex_mem_opcode_class is
      when STORE =>
        case mem_wb_opcode_class is
          when LOAD =>
            if ex_mem_reg_rd = mem_wb_reg_rd then
              ex_dm_data_sel <= FWDSEL_MEM_WB_DATA;
            end if;
          when others =>
        end case;

      when others =>
        -- Do Nothing
    end case;

  end process pipe_ctrl;

end behavior;
 
