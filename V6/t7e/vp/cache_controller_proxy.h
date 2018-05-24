#ifndef _HPG_cache_controller_proxy_h_H_
#define _HPG_cache_controller_proxy_h_H_

#include "systemc.h"

SC_HDL_MODULE( cache_controller) {
    sc_in<bool> CLK;
    sc_in<bool> RESET;
    sc_in<sc_uint<20> > CPUADDR;
    sc_in<sc_uint<32> > CPUDATAIN;
    sc_out<sc_uint<32> > CPUDATAOUT;
    sc_in<bool> CPUENABLE;
    sc_in<bool> CPUWRITE;
    sc_out<bool> CPUDONE;
    sc_in<sc_uint<2> > CPUMEMWIDTH;
    sc_out<sc_uint<32> > MEMADDR;
    sc_out<sc_uint<32> > MEMDATAIN;
    sc_in<sc_uint<32> > MEMDATAOUT;
    sc_out<bool> MEMENABLE;
    sc_out<bool> MEMWRITE;
    sc_in<bool> MEMDONE;

    std::string hpg_log_lib;
    std::string hpg_module_name;
    std::string hpg_hdl_src_path;
    std::string vhdl_arch_name;

    std::string libraryName() { return hpg_log_lib; }

    std::string moduleName() { return hpg_module_name; }

    
    std::string vhdlComponentListPackageName() { return "modules"; }

    void setVhdlArchitectureName( const char* name) { vhdl_arch_name = name; }

    std::string vhdlArchitectureName() { return vhdl_arch_name; }

    cwr_hdlLangType hdl_language_type() { return cwr_vhdl; }

    void getVhdlSourceFiles(std::vector<std::string>& vhdl_files) {
        vhdl_files.push_back(hpg_hdl_src_path + std::string("../lib/cache_support.vhd"));
        vhdl_files.push_back(hpg_hdl_src_path + std::string("../lib/memctrl.vhd"));
        vhdl_files.push_back(hpg_hdl_src_path + std::string("../lib/dcache.vhd"));
        vhdl_files.push_back(hpg_hdl_src_path + std::string("../lib/cache.vhd"));
        vhdl_files.push_back(hpg_hdl_src_path + std::string("../lib/modules_p.vhd"));
    }

    cache_controller(sc_module_name name, const char* hdlSrcPath="") : 
        sc_hdl_module(name), hpg_log_lib("cwr_hdl_work"), hpg_module_name("cache_controller"), hpg_hdl_src_path()
        , CLK("CLK"), RESET("RESET"), CPUADDR("CPUADDR"), CPUDATAIN("CPUDATAIN")
        , CPUDATAOUT("CPUDATAOUT"), CPUENABLE("CPUENABLE"), CPUWRITE("CPUWRITE")
        , CPUDONE("CPUDONE"), CPUMEMWIDTH("CPUMEMWIDTH"), MEMADDR("MEMADDR"), MEMDATAIN("MEMDATAIN")
        , MEMDATAOUT("MEMDATAOUT"), MEMENABLE("MEMENABLE"), MEMWRITE("MEMWRITE")
        , MEMDONE("MEMDONE"), vhdl_arch_name() {

        if (hdlSrcPath != 0 && strlen(hdlSrcPath) != 0) {
          hpg_hdl_src_path = std::string(hdlSrcPath) + "/";
        }


    }
};

#endif
