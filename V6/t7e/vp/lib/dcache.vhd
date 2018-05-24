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
-- Modul:
-- Data Cache Modul for 16-Bit RAM-Adresses.
-- Cacheline 128 Bit (4 Words a 32Bit) 
-- 2x32 Lines 2-way associative Cache.
-- ^^^^       ^^^^^^^^^^^^^^^^^
-- 
-- Addr-Bits: 111111
--            5432109876543210
--            ----------------
--            _______
--              Tag  _____
--                  Offset__
--                        Word
--                          __
--                          Byte
-- ===================================================================


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cache_support.all;


entity dcache is
  port(
    clk          : in  std_logic;
    rst          : in  std_logic;
    
    dc_addr      : in  address;
    dc_rdata     : out word;
    dc_wdata     : in  word;
    dc_enable    : in  std_logic;
    dc_write     : in  std_logic;
    dc_width     : in  Mem_width;
    dc_ready     : out std_logic;
    
    cache_line   : in  std_logic_vector( 0 to bw_cacheline-1 );
    dc_update    : in  std_logic;
    memctrl_busy : in  std_logic
  );
end dcache;


-- ===================================================================
architecture behavior of dcache is


  -- Component Deklarationen
  -- =======================
  component cache_memory
    generic(
      bit_width  : natural;
      addr_width : natural
    );
    port(
      clk :       in  std_logic;
      addr :      in  std_logic_vector(addr_width-1 downto 0);
      write :     in  std_logic;
      data_out :  out std_logic_vector(0 to  bit_width-1);
      data_in :   in  std_logic_vector(0 to  bit_width-1)
    ); 
  end component;

  
  -- Signale zur Ansteuerung der Cache RAMs-------------------------------------
  signal setX_in     :  std_logic_vector( 0 to bw_cacheline + bw_dc_tag );
  signal set0_out    :  std_logic_vector( 0 to bw_cacheline + bw_dc_tag );
  signal set1_out    :  std_logic_vector( 0 to bw_cacheline + bw_dc_tag );
  signal set0_write  :  std_logic := '0';
  signal set1_write  :  std_logic := '0';

  -- Signale zur Aufsplittung der Cache-RAM-Ausgänge ---------------------------
  signal set0_tag    :  std_logic_vector( bw_dc_tag - 1 downto 0 );
  signal set0_line   :  std_logic_vector( 0 to bw_cacheline - 1 );
  signal set0_valid  :  std_logic;
  signal set1_tag    :  std_logic_vector( bw_dc_tag-1 downto 0 );
  signal set1_line   :  std_logic_vector( 0 to bw_cacheline - 1 );
  signal set1_valid  :  std_logic;

  -- Signale zur Aufsplittung der Daten-Adresse --------------------------------
  signal addr_tag    :  std_logic_vector( bw_dc_tag - 1 downto 0 );
  signal addr_offset :  std_logic_vector( bw_dc_offset - 1 downto 0 );
  signal addr_word   :  std_logic_vector( 1 downto 0 );
  signal addr_byte   :  std_logic_vector( 1 downto 0 );

  -- algemeine Signale ---------------------------------------------------------
  signal set0_hit    :  std_logic;
  signal set1_hit    :  std_logic;

  -- LFSR for random-Bit Generation --------------------------------------------
  signal lfsr        :  std_logic_vector( 7 downto 0 );
  signal rand_bit    :  std_logic := '0';

begin


  -- =================================================================
  -- Instanziierung der Cache-RAMs (fuer Tag, Cache-Line u. Vaild-Bit)
  -- =================================================================
  
  
  set0_ram : cache_memory
    generic map(
      bit_width   => bw_cacheline+bw_dc_tag+1,
      addr_width  => bw_dc_offset
    )
    port map(
      clk       => clk,  
      addr      => addr_offset,
      data_out  => set0_out,
      write     => set0_write,  
      data_in   => setX_in
    );

  set1_ram : cache_memory
    generic map(
      bit_width   => bw_cacheline+bw_dc_tag+1,
      addr_width  => bw_dc_offset
    )
    port map(
      clk       => clk,  
      addr      => addr_offset,
      data_out  => set1_out,
      write     => set1_write,  
      data_in   => setX_in
    );


  -- =================================================================
  -- Aufsplittung der Cache-RAM-Ausgänge (Tag, Line u. Vaild-Bit)
  -- =================================================================
  
  
  set0_valid  <= set0_out( 0 );
  set0_tag    <= set0_out( 1 to bw_dc_tag );
  set0_line   <= set0_out( bw_dc_tag + 1 to bw_cacheline + bw_dc_tag );
  set1_valid  <= set1_out( 0 );
  set1_tag    <= set1_out( 1 to bw_dc_tag );
  set1_line   <= set1_out( bw_dc_tag + 1 to bw_cacheline + bw_dc_tag );


  -- =================================================================
  -- Aufsplittung der Daten-Adresse (Tag, Offset, Word, Byte)
  -- =================================================================
  
  
  addr_tag    <= dc_addr( address_width - 1 downto address_width - bw_dc_tag );
  addr_offset <= dc_addr( address_width - bw_dc_tag - 1 downto 4 );
  addr_word   <= dc_addr( 3 downto 2 );
  addr_byte   <= dc_addr( 1 downto 0 );


  -- =================================================================
  -- Cache-Read-Access (nicht getaktet!)
  -- =================================================================
  
  
  cache_read : process( set0_valid, set1_valid, set0_tag, set1_tag, set0_line, 
                        set1_line, addr_tag, addr_word, addr_byte, dc_width )
  begin
  
  -- Insert your code here:

  end process cache_read;

  
  -- =================================================================
  -- Cache-Update-Access (nicht getaktet!)
  -- =================================================================
  
  
  cache_update : process( set0_valid, set1_valid, set0_tag, set1_tag, 
                          set0_line, set1_line, set0_hit, set1_hit, 
                          addr_tag, addr_word, addr_byte, cache_line,
                          dc_update, dc_enable, dc_write, dc_width )
  begin

  -- Insert your code here:

  end process cache_update;


  -- =================================================================
  -- Cache-Read/Write-Access completed (nicht getaktet!)
  -- =================================================================
  
  
  completed : process( dc_write, memctrl_busy, set0_hit, set1_hit )
  begin
    -- Cache Access Completed	
   if (dc_write='1' and memctrl_busy ='0')
       or (dc_write='0' and (set0_hit='1' or set1_hit='1')) 
    then
      dc_ready <= '1';
    else
      dc_ready <= '0';
    end if;
  end process completed;


  -- =================================================================
  -- Linear Feedback Shift Register, LFSR (getaktet!)
  -- =================================================================
  rand_bit <= lfsr(0);
  
  lfsr_reg : process( clk )
  begin

  -- Insert your code here:

  end process lfsr_reg;
      

end behavior;
