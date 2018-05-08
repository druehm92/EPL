-- Generated from THDL++ code. See http://visualhdl.sysprogs.org/ for more information on THDL++.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- MEL/AUT-Lab packages
use work.cache_support.all;

-- CacheController
entity Cache_Controller is
	Port (
		clk : in std_logic; -- clk : 0 reads, 0 writes
		reset : in std_logic; -- reset : 1 reads, 0 writes
		CPUAddr : in std_logic_vector(19 downto 0); -- CPUAddr : 1 reads, 0 writes
		CPUDataIn : in std_logic_vector(31 downto 0); -- CPUDataIn : 1 reads, 0 writes
		CPUDataOut : out std_logic_vector(31 downto 0); -- CPUDataOut : 0 reads, 1 writes
		CPUEnable : in std_logic; -- CPUEnable : 1 reads, 0 writes
		CPUWrite : in std_logic; -- CPUWrite : 1 reads, 0 writes
		CPUDone : out std_logic; -- CPUDone : 0 reads, 3 writes
		CPUMemwidth : in std_logic_vector(1 downto 0);
		MEMAddr : out std_logic_vector(31 downto 0); -- MEMAddr : 0 reads, 1 writes
		MEMDataIn : out std_logic_vector(31 downto 0); -- MEMDataIn : 0 reads, 1 writes
		MEMDataOut : in std_logic_vector(31 downto 0); -- MEMDataOut : 1 reads, 0 writes
		MEMEnable : out std_logic; -- MEMEnable : 0 reads, 1 writes
		MEMWrite : out std_logic; -- MEMWrite : 0 reads, 1 writes
		MEMDone : in std_logic -- MEMDone : 1 reads, 0 writes
	);
	
end entity Cache_Controller;




architecture Behavioral of Cache_Controller is

	component dcache 
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
	end component dcache;

	component memctrl 
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
	    dc_update    : out std_logic;
	    memctrl_busy : out std_logic;

	    mem_addr     : out address;
	    mem_enable   : out std_logic;
	    mem_ready    : in  std_logic;
	    mem_rdata    : in  word;
	    mem_wdata    : out word;
	    mem_write    : out std_logic;
	    mem_width    : out Mem_width
	  );
	end component memctrl;



	signal sig_dc_addr      : address;
	signal sig_dc_wdata     : word;
	signal sig_dc_enable    : std_logic;
	signal sig_dc_write     : std_logic;
	signal sig_dc_width     : Mem_width;
	signal sig_dc_ready     : std_logic;

	signal sig_cache_line   : std_logic_vector( 0 to bw_cacheline-1 );
	
	signal sig_dc_update    : std_logic;
	signal sig_memctrl_busy : std_logic;

	
	begin

	cache: component dcache 
	  port map(
	    clk          =>  clk,
	    rst          =>  reset,
	    
	    dc_rdata     =>  CPUDataOut,

	    dc_addr      =>  sig_dc_addr  ,
	    dc_wdata     =>  sig_dc_wdata ,
	    dc_enable    =>  sig_dc_enable,
	    dc_write     =>  sig_dc_write ,
	    dc_width     =>  sig_dc_width ,
	    dc_ready     =>  sig_dc_ready ,
	    
	    cache_line   =>  sig_cache_line,
	    dc_update    =>  sig_dc_update,
	    memctrl_busy =>  sig_memctrl_busy
	  );

	memcontroler: component memctrl 
	  port map(
	    clk          =>  clk,
	    rst          =>  reset,
	    
	    dc_addr      =>  sig_dc_addr  ,
	    dc_wdata     =>  sig_dc_wdata ,
	    dc_enable    =>  sig_dc_enable,
	    dc_write     =>  sig_dc_write ,
	    dc_width     =>  sig_dc_width ,
	    dc_ready     =>  sig_dc_ready ,

	    cache_line   =>  sig_cache_line,
	    dc_update    =>  sig_dc_update,
	    memctrl_busy =>  sig_memctrl_busy,

	    mem_addr     =>  MEMAddr,
	    mem_enable   =>  MEMEnable,
	    mem_ready    =>  MEMDone,
	    mem_rdata    =>  MEMDataOut,
	    mem_wdata    =>  MEMDataIn,
	    mem_write    =>  MEMWrite,
	    mem_width    =>  open
	  );


	-- concurrent assigments:

	sig_dc_addr   <= "000000000000" & CPUAddr;
	sig_dc_wdata  <= CPUDataIn;
	sig_dc_enable <= CPUEnable;
	sig_dc_write  <= CPUWrite;
	sig_dc_width  <= CPUMemwidth;
	CPUDone       <=  sig_dc_ready;



end architecture Behavioral;

