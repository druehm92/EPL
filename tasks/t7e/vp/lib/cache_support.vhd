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
-- Align:
-- ------
-- * Selects the right BYTE/HALFWORD/WORD out of a Cacheline.
-- 
-- Update:
-- -------
-- * Updates the right BYTE/HALFWORD/WORD in a Cacheline.
-- 
-- ===================================================================


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ===================================================================
package cache_support is


  -- ========================================================
  -- Subtypes
  -- ========================================================
 

  subtype address    is std_logic_vector ( 31 downto 0 );
  subtype word       is std_logic_vector ( 0  to 31 );

  subtype Mem_width      is std_logic_vector( 1 downto 0);


  -- ===========================================================================
  -- Constants
  -- ===========================================================================
  
  
  constant ADDRESS_WIDTH       : natural    := 16;
  
  constant MEM_WIDTH_WORD      : Mem_width     := "00";
  constant MEM_WIDTH_HALFWORD  : Mem_width     := "10";
  constant MEM_WIDTH_BYTE      : Mem_width     := "01";

  -- Bitbreiten fuer Adressen (Tag u. Offset) fuer DCache
  constant bw_dc_offset : integer :=   5;
  constant bw_dc_tag    : integer :=   7;

  -- Bitbreite einer Cacheline, fest 4x32 Bit = 128 Bit
  -- Die Bitbreite hat Konsequenzen auf die gesamte
  -- Cache Architektur und kann nicht geaendert werden !!!
  constant bw_cacheline : integer := 128;

  
  -- ===========================================================================
  -- Functions
  -- ===========================================================================
  
  
  function align ( 
    line_in     : in std_logic_vector( 0 to bw_cacheline-1 );
    line_select : in std_logic_vector( 1 downto 0 );
    word_select : in std_logic_vector( 1 downto 0 );
    data_width  : in Mem_width
  ) return word;
  

  function update ( 
    line_in     : in std_logic_vector( 0 to bw_cacheline-1 );
    word_in     : in word;
    line_select : in std_logic_vector( 1 downto 0 );
    word_select : in std_logic_vector( 1 downto 0 );
    data_width  : in Mem_width
  ) return std_logic_vector;
  
end cache_support;


-- ===================================================================
package body cache_support is

  function align ( 
    line_in     : in std_logic_vector( 0 to bw_cacheline-1 );
    line_select : in std_logic_vector( 1 downto 0 );
    word_select : in std_logic_vector( 1 downto 0 );
    data_width  : in Mem_width
  ) return word is

    variable word, result : word;  
  begin
    case line_select is
      when "11" =>   word := line_in(96 to 127);
      when "10" =>   word := line_in(64 to  95);
      when "01" =>   word := line_in(32 to  63);
      when others => word := line_in( 0 to  31);
    end case;
    result := (others => '-');
    case data_width is
      when MEM_WIDTH_HALFWORD => 
        if word_select(1) = '0' then
          result(16 to 31) := word(16 to 31);
        else
          result(16 to 31) := word(0 to 15);            
        end if;
      when MEM_WIDTH_BYTE => 
        case word_select is
          when "00" =>
            result(24 to 31) := word( 24 to  31);
          when "01" =>
            result(24 to 31) := word( 16 to 23);
          when "10" =>
            result(24 to 31) := word(8 to 15);
          when others =>
            result(24 to 31) := word(0 to 7);
        end case;
      when others => 
        result := word;
    end case;
    return result;
  end align;


  function update ( 
    line_in     : in std_logic_vector( 0 to bw_cacheline-1 );
    word_in     : in word;
    line_select : in std_logic_vector( 1 downto 0 );
    word_select : in std_logic_vector( 1 downto 0 );
    data_width  : in Mem_width
  ) return std_logic_vector is

    variable result : std_logic_vector( 0 to bw_cacheline-1 );  

  begin
    result := line_in;
    case line_select is
      when "11" =>   
        case data_width is
          when MEM_WIDTH_HALFWORD => 
            if word_select(1) = '1' then
              result(96 to 111) := word_in(16 to 31);            
            else
              result(112 to 127 ) := word_in(16 to 31);
            end if;
          when MEM_WIDTH_BYTE => 
            case word_select is
              when "11" =>
                result(96 to 103) := word_in(24 to 31);
              when "10" =>
                result(104 to 111) := word_in(24 to 31);
              when "01" =>
                result(112 to 119) := word_in(24 to 31);
              when others =>
                result( 120 to 127) := word_in(24 to 31);
            end case;
          when others => 
            result(96 to 127) := word_in;
        end case;

      when "10" =>   
        case data_width is
          when MEM_WIDTH_HALFWORD => 
            if word_select(1) = '1' then
              result(64 to 79) := word_in(16 to 31);            
            else
              result(80 to 95) := word_in(16 to 31);
            end if;
          when MEM_WIDTH_BYTE => 
            case word_select is
              when "11" =>
                result(64 to 71) := word_in(24 to 31);
              when "10" =>
                result(72 to 79) := word_in(24 to 31);
              when "01" =>
                result(80 to 87) := word_in(24 to 31);
              when others =>
                result(88 to 95) := word_in(24 to 31);
            end case;
          when others => 
            result(64 to 95) := word_in;
        end case;
        
      when "01" =>   
        case data_width is
          when MEM_WIDTH_HALFWORD => 
            if word_select(1) = '1' then
              result(32 to 47) := word_in(16 to 31);            
            else
              result(48 to 63) := word_in(16 to 31);
            end if;
          when MEM_WIDTH_BYTE => 
            case word_select is
              when "11" =>
                result(32 to 39) := word_in(24 to 31);
              when "10" =>
                result(40 to 47) := word_in(24 to 31);
              when "01" =>
                result(48 to 55) := word_in(24 to 31);
              when others =>
                result(56 to 63) := word_in(24 to 31);
            end case;
          when others => 
            result(32 to 63) := word_in;
        end case;

      when others =>   
        case data_width is
          when MEM_WIDTH_HALFWORD => 
            if word_select(1) = '0' then
              result( 0 to 15) := word_in(16 to 31);            
            else
              result(16 to 31) := word_in(16 to 31);
            end if;
          when MEM_WIDTH_BYTE => 
            case word_select is
              when "11" =>
                result(0 to 7) := word_in(24 to 31);
              when "10" =>
                result( 8 to 15) := word_in(24 to 31);
              when "01" =>
                result(16 to 23) := word_in(24 to 31);
              when others =>
                result(24 to 31) := word_in(24 to 31);
            end case;
          when others => 
            result( 0 to 31) := word_in;
        end case;

    end case;
    return result;
  end update;


end cache_support;