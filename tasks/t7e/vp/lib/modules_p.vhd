-- Copyright (C) 1996-2010 Synopsys, Inc.
-- All rights reserved worldwide

library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package modules is

component Cache_Controller 
port (
	clk : in std_logic; -- clk : 0 reads, 0 writes
        reset : in std_logic; -- reset : 0 reads, 0 writes
        CPUAddr : in std_logic_vector(19 downto 0); -- CPUAddr : 1 reads, 0 writes
        CPUDataIn : in std_logic_vector(31 downto 0); -- CPUDataIn : 1 reads, 0 writes
        CPUDataOut : out std_logic_vector(31 downto 0); -- CPUDataOut : 0 reads, 1 writes
        CPUEnable : in std_logic; -- CPUEnable : 1 reads, 0 writes
        CPUWrite : in std_logic; -- CPUWrite : 1 reads, 0 writes
        CPUDone : out std_logic; -- CPUDone : 0 reads, 1 writes
	CPUMemwidth : in std_logic_vector(1 downto 0);
        MEMAddr : out std_logic_vector(31 downto 0); -- MEMAddr : 0 reads, 1 writes
        MEMDataIn : out std_logic_vector(31 downto 0); -- MEMDataIn : 0 reads, 1 writes
        MEMDataOut : in std_logic_vector(31 downto 0); -- MEMDataOut : 1 reads, 0 writes
        MEMEnable : out std_logic; -- MEMEnable : 0 reads, 1 writes
        MEMWrite : out std_logic; -- MEMWrite : 0 reads, 1 writes
        MEMDone : in std_logic -- MEMDone : 1 reads, 0 writes

    );
end component;

end modules;
