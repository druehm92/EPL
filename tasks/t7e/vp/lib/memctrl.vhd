-- ===================================================================
-- (C)opyright 2001, 2002, 2012
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
--           Stefan Weithoffer
-- 
-- ===================================================================
-- 
-- Projekt: Mikroelektronisches Praktikum
--          SS 2002
-- 
-- ===================================================================
-- 
-- Modul:
-- DCache-Interface to Memory Controller.
--
-- Asynchronous ram module for cache memory
--
-- ===================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cache_support.all;

entity memctrl is
  port(
    clk          : in  std_logic;
    rst          : in  std_logic;
    
    dc_addr      : in  address;
    dc_wdata     : in  word;
    dc_enable    : in  std_logic;
    dc_write     : in  std_logic;
    dc_width     : in  Mem_width;
    dc_ready     : in  std_logic;

    cache_line   : out std_logic_vector( 0 to bw_cacheline-1 );
    dc_update    : out std_logic := '0';
    memctrl_busy : out std_logic;

    mem_addr     : out address;
    mem_enable   : out std_logic;
    mem_ready    : in  std_logic;
    mem_rdata    : in  word;
    mem_wdata    : out word;
    mem_write    : out std_logic;
    mem_width    : out Mem_width
  );
end memctrl;


-- ===================================================================
architecture behavior of memctrl is

  -- Cache Update Control ------------------------------------------------------
  type states is (ready, update_start, update_word_0, update_word_1,
                  update_word_2, update_word_3, update_write );

  signal mem_addr_r     : address;
  signal dmem_read_addr : address; 
  signal cache_sel      : std_logic; 
  signal state          : states;
  signal line_reg       : std_logic_vector( 0 to bw_cacheline-1 );

begin
  -- =================================================================
  -- Concurrent Output Signals
  -- =================================================================
  address_register:
    mem_addr   <= mem_addr_r;
    
  cacheline_register:
    cache_line <= line_reg;


  -- =================================================================
  -- Starting Memory Address of Cachelines
  -- =================================================================
  dc_line_addr :
    dmem_read_addr <= 
      ( 31 downto address_width => '0')
      & dc_addr(address_width-1 downto address_width-bw_dc_tag-bw_dc_offset) 
      & (address_width-bw_dc_tag-bw_dc_offset-1 downto 0 => '0');


  -- =================================================================
  -- Cache-Update-Access (getaktet!)
  -- =================================================================
  mem_read_write_ctrl : process( clk )
  begin
    if clk'event and clk = '1' then
      if rst = '1' then
        -- initial values
        memctrl_busy <= '1';
        dc_update    <= '0';
        mem_enable   <= '0';
        mem_write    <= '0';
        state        <= ready;
      else
        -- default values
        memctrl_busy <= '1';
        dc_update    <= '0';
        mem_enable   <= '0';
        mem_write    <= '0';
        mem_wdata    <= (others => '-');
        mem_width    <= (others => '-');
        case state is
          when ready =>
            memctrl_busy <= '0';
            if dc_enable = '1' and dc_write = '1' then
              -- Data Cache Memory Write
              memctrl_busy <= '1';
              mem_addr_r <= dc_addr;
              mem_enable <= '1';
              mem_write  <= '1';
              mem_wdata  <= dc_wdata;
              mem_width  <= dc_width;
            elsif dc_enable = '1' and dc_write = '0' and dc_ready = '0' then
              -- Data Cache Read Miss
              cache_sel <= '0';
              state     <= update_start;     
            end if;

          when update_start =>
            mem_enable <= '1';
            mem_addr_r <= dmem_read_addr;
            state <= update_word_0;

          when update_word_0 =>
            mem_enable <= '0';
            if mem_ready = '1' then
              mem_enable <= '1';
              mem_addr_r          <= address( unsigned(mem_addr_r) + 4 );
              line_reg( 0 to  31) <= mem_rdata;
              state               <= update_word_1;
            end if;

          when update_word_1 =>
            mem_enable <= '0';
            if mem_ready = '1' then
              mem_enable <= '1';
              mem_addr_r          <= address( unsigned(mem_addr_r) + 4 );
              line_reg(32 to  63) <= mem_rdata;
              state               <= update_word_2;
            end if;
        
          when update_word_2 =>
            mem_enable <= '0';
            if mem_ready = '1' then
              mem_enable <= '1';
              mem_addr_r          <= address( unsigned(mem_addr_r) + 4 );
              line_reg(64 to  95) <= mem_rdata;
              state               <= update_word_3;
            end if;

          when update_word_3 =>
            mem_enable          <= '0';
            if mem_ready = '1' then
              line_reg(96 to 127) <= mem_rdata;
              dc_update <= '1';
              state <= update_write;
            end if;

          when update_write =>
            memctrl_busy <= '0';
            state        <= ready;
        
        end case;
      end if;  -- rst
    end if;  -- clk
  end process mem_read_write_ctrl;


end behavior;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity cache_memory is
  generic(
    bit_width  : natural;
    addr_width : natural
  );
  port(
    -- algemeine Signal
    clk :       in  std_logic;
    
    addr :      in  std_logic_vector(addr_width-1 downto 0);
    write :     in  std_logic;
    data_out :  out std_logic_vector(0 to bit_width-1);
    data_in :   in  std_logic_vector(0 to bit_width-1)
  ); 
end cache_memory;


-- ===================================================================
architecture sim of cache_memory is

  type ram_array is array(0 to 2**addr_width-1) 
                      of std_logic_vector(0 to  bit_width-1);
                      
  constant all_zero : std_logic_vector(0 to bit_width-1) := (others => '0');
  
begin

  mem : process
    variable ram : ram_array := (others => all_zero);
  begin
    wait on clk, addr;
    
    -- write synchronously
    -- =======================
    if clk'event and clk = '1' then
      if is_X( write ) then
        assert false
          report "Cache-Memory Steuersignale enthalten 'X'"
          severity error;
      elsif write = '1' then
        ram(to_integer(unsigned(addr))) := data_in;
      end if;

    end if;

    -- read asynchronously
    -- =======================
    if is_X( addr ) then
      data_out <= (others => 'X');
    else
      data_out <= ram( to_integer( unsigned( addr ) ) );
    end if;
  end process mem;  
  
end sim;

