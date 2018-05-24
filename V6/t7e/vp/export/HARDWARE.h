#ifndef HARDWARE_H
#define HARDWARE_H

#ifndef SNPS_AUTO_PTR
#if __cplusplus >= 201103L
  #define SNPS_AUTO_PTR std::unique_ptr
#else
  #define SNPS_AUTO_PTR std::auto_ptr
#endif
#endif
#include "systemc.h"
#include "../lib/counter.h"
#include "../lib/display.h"
#include "SystemC/Common/include/ARM_COPROC/ARM_COPROC_TLM_Model.h"
#include "SystemC/IA_CoWare/include/ARM926EJS_TLM2_IA_CoWare/ARM926EJS_TCM_TLM2_Memory.h"
#include "SystemC/IA_CoWare/include/ARM926EJS_TLM2_IA_CoWare/LTCWR_ARM926EJS_TLM2_Model.h"
#include "amba_pv.h"
#include "tlm.h"
#include "cwr_sc_object_creator.h"
#include "cwr_sc_object_registry.h"

//-------------------------------

SC_MODULE(CwrModule_HARDWARE_BLFramework_BackBone)
{
  sc_in<bool> m_Clk_pin;
  sc_in<bool> m_Rst_pin;
  tlm::tlm_base_target_socket<32, tlm::tlm_fw_transport_if<tlm::tlm_base_protocol_types>, tlm::tlm_bw_transport_if<tlm::tlm_base_protocol_types>, 1, sc_core::SC_ONE_OR_MORE_BOUND> BB_C_11_s;
  tlm::tlm_base_target_socket<32, tlm::tlm_fw_transport_if<tlm::tlm_base_protocol_types>, tlm::tlm_bw_transport_if<tlm::tlm_base_protocol_types>, 1, sc_core::SC_ONE_OR_MORE_BOUND> BB_C_12_s;
  tlm::tlm_base_initiator_socket<32, tlm::tlm_fw_transport_if<tlm::tlm_base_protocol_types>, tlm::tlm_bw_transport_if<tlm::tlm_base_protocol_types>, 1, sc_core::SC_ONE_OR_MORE_BOUND> BB_C_13_m;
  tlm::tlm_base_initiator_socket<32, tlm::tlm_fw_transport_if<tlm::tlm_base_protocol_types>, tlm::tlm_bw_transport_if<tlm::tlm_base_protocol_types>, 1, sc_core::SC_ONE_OR_MORE_BOUND> BB_C_14_m;
  tlm::tlm_base_initiator_socket<32, tlm::tlm_fw_transport_if<tlm::tlm_base_protocol_types>, tlm::tlm_bw_transport_if<tlm::tlm_base_protocol_types>, 1, sc_core::SC_ONE_OR_MORE_BOUND> BB_C_15_m;
  tlm::tlm_base_initiator_socket<32, tlm::tlm_fw_transport_if<tlm::tlm_base_protocol_types>, tlm::tlm_bw_transport_if<tlm::tlm_base_protocol_types>, 1, sc_core::SC_ONE_OR_MORE_BOUND> BB_i_counter_targetSocket;
  tlm::tlm_base_initiator_socket<32, tlm::tlm_fw_transport_if<tlm::tlm_base_protocol_types>, tlm::tlm_bw_transport_if<tlm::tlm_base_protocol_types>, 1, sc_core::SC_ONE_OR_MORE_BOUND> BB_i_display_targetSocket;
  
  SNPS_AUTO_PTR<sc_core::sc_module> tlm2ftbus_genMS;
  
  CwrModule_HARDWARE_BLFramework_BackBone(sc_module_name _name) :
    sc_module(_name),
    m_Clk_pin("Clk_pin"),
    m_Rst_pin("Rst_pin"),
    BB_C_11_s("BB_C_11_s"),
    BB_C_12_s("BB_C_12_s"),
    BB_C_13_m("BB_C_13_m"),
    BB_C_14_m("BB_C_14_m"),
    BB_C_15_m("BB_C_15_m"),
    BB_i_counter_targetSocket("BB_i_counter_targetSocket"),
    BB_i_display_targetSocket("BB_i_display_targetSocket"),
    tlm2ftbus_genMS(dynamic_cast<sc_module*>(conf::cwr_sc_object_registry::inst().addObject(conf::ScObjectFactory::inst().create("tlm2FTBusRTGenerator","tlm2ftbus_genMS"))))
  {
    (*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createTargetSocketProxy(&BB_C_11_s)))((*conf::cwr_sc_object_registry::inst().getTargetSocket(name() + std::string(".tlm2ftbus_genMS.Bus_IPStage_BB_C_11_s_C_BB_C_11_s_s"))));
    add_portname_attr(BB_C_11_s, "BB_C_11_s");
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getTargetSocket(name() + std::string(".tlm2ftbus_genMS.Bus_IPStage_BB_C_11_s_C_BB_C_11_s_s"))).get_object(), "Bus_IPStage_BB_C_11_s_C_BB_C_11_s_s");
    (*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createTargetSocketProxy(&BB_C_12_s)))((*conf::cwr_sc_object_registry::inst().getTargetSocket(name() + std::string(".tlm2ftbus_genMS.Bus_IPStage_BB_C_12_s_C_BB_C_12_s_s"))));
    add_portname_attr(BB_C_12_s, "BB_C_12_s");
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getTargetSocket(name() + std::string(".tlm2ftbus_genMS.Bus_IPStage_BB_C_12_s_C_BB_C_12_s_s"))).get_object(), "Bus_IPStage_BB_C_12_s_C_BB_C_12_s_s");
    (*conf::cwr_sc_object_registry::inst().getInitiatorSocket(name() + std::string(".tlm2ftbus_genMS.Bus_OPStage_BB_C_13_m_C_BB_C_13_m_m")))((*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createInitiatorSocketProxy(&BB_C_13_m))));
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getInitiatorSocket(name() + std::string(".tlm2ftbus_genMS.Bus_OPStage_BB_C_13_m_C_BB_C_13_m_m"))).get_object(), "Bus_OPStage_BB_C_13_m_C_BB_C_13_m_m");
    add_portname_attr(BB_C_13_m, "BB_C_13_m");
    (*conf::cwr_sc_object_registry::inst().getInitiatorSocket(name() + std::string(".tlm2ftbus_genMS.Bus_OPStage_BB_C_14_m_C_BB_C_14_m_m")))((*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createInitiatorSocketProxy(&BB_C_14_m))));
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getInitiatorSocket(name() + std::string(".tlm2ftbus_genMS.Bus_OPStage_BB_C_14_m_C_BB_C_14_m_m"))).get_object(), "Bus_OPStage_BB_C_14_m_C_BB_C_14_m_m");
    add_portname_attr(BB_C_14_m, "BB_C_14_m");
    (*conf::cwr_sc_object_registry::inst().getInitiatorSocket(name() + std::string(".tlm2ftbus_genMS.Bus_OPStage_BB_C_15_m_C_BB_C_15_m_m")))((*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createInitiatorSocketProxy(&BB_C_15_m))));
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getInitiatorSocket(name() + std::string(".tlm2ftbus_genMS.Bus_OPStage_BB_C_15_m_C_BB_C_15_m_m"))).get_object(), "Bus_OPStage_BB_C_15_m_C_BB_C_15_m_m");
    add_portname_attr(BB_C_15_m, "BB_C_15_m");
    (*conf::cwr_sc_object_registry::inst().getInitiatorSocket(name() + std::string(".tlm2ftbus_genMS.Bus_OPStage_BB_i_counter_targetSocket_C_BB_i_counter_targetSocket_m")))((*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createInitiatorSocketProxy(&BB_i_counter_targetSocket))));
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getInitiatorSocket(name() + std::string(".tlm2ftbus_genMS.Bus_OPStage_BB_i_counter_targetSocket_C_BB_i_counter_targetSocket_m"))).get_object(), "Bus_OPStage_BB_i_counter_targetSocket_C_BB_i_counter_targetSocket_m");
    add_portname_attr(BB_i_counter_targetSocket, "BB_i_counter_targetSocket");
    (*conf::cwr_sc_object_registry::inst().getInitiatorSocket(name() + std::string(".tlm2ftbus_genMS.Bus_OPStage_BB_i_display_targetSocket_C_BB_i_display_targetSocket_m")))((*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createInitiatorSocketProxy(&BB_i_display_targetSocket))));
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getInitiatorSocket(name() + std::string(".tlm2ftbus_genMS.Bus_OPStage_BB_i_display_targetSocket_C_BB_i_display_targetSocket_m"))).get_object(), "Bus_OPStage_BB_i_display_targetSocket_C_BB_i_display_targetSocket_m");
    add_portname_attr(BB_i_display_targetSocket, "BB_i_display_targetSocket");
    (*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".tlm2ftbus_genMS.Bus_IPStage_BB_C_11_s_clk_pin")))((*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createPortProxy(&m_Clk_pin))));
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".tlm2ftbus_genMS.Bus_IPStage_BB_C_11_s_clk_pin"))).get_object(), "Bus_IPStage_BB_C_11_s_clk");
    add_portname_attr(m_Clk_pin, "Clk");
    (*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".tlm2ftbus_genMS.Bus_IPStage_BB_C_11_s_reset_pin")))((*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createPortProxy(&m_Rst_pin))));
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".tlm2ftbus_genMS.Bus_IPStage_BB_C_11_s_reset_pin"))).get_object(), "Bus_IPStage_BB_C_11_s_reset");
    add_portname_attr(m_Rst_pin, "Rst");
  }

  CwrModule_HARDWARE_BLFramework_BackBone* operator->() { return this; }

  virtual void add_portname_attr(sc_object& obj, const std::string& value) {
    obj.add_attribute(*new sc_core::sc_attribute<std::string>("pct-port-name", value));
  }
  virtual void add_stub_attr(sc_object& obj) {
    obj.add_attribute(*new sc_core::sc_attribute<bool>("pct-stub", true));
  }
};

//-------------------------------

SC_MODULE(CwrModule_HARDWARE_BLFramework)
{
  sc_in<bool> m_Clk_pin;
  sc_in<bool> m_Rst_pin;
  tlm::tlm_base_target_socket<32, tlm::tlm_fw_transport_if<amba_pv::amba_pv_protocol_types>, tlm::tlm_bw_transport_if<amba_pv::amba_pv_protocol_types>, 1, SC_ONE_OR_MORE_BOUND> C_11_s;
  tlm::tlm_base_target_socket<32, tlm::tlm_fw_transport_if<amba_pv::amba_pv_protocol_types>, tlm::tlm_bw_transport_if<amba_pv::amba_pv_protocol_types>, 1, SC_ONE_OR_MORE_BOUND> C_12_s;
  tlm::tlm_base_initiator_socket<32, tlm::tlm_fw_transport_if<tlm::tlm_base_protocol_types>, tlm::tlm_bw_transport_if<tlm::tlm_base_protocol_types>, 1, sc_core::SC_ONE_OR_MORE_BOUND> C_13_m;
  tlm::tlm_base_initiator_socket<32, tlm::tlm_fw_transport_if<tlm::tlm_base_protocol_types>, tlm::tlm_bw_transport_if<tlm::tlm_base_protocol_types>, 1, sc_core::SC_ONE_OR_MORE_BOUND> C_14_m;
  tlm::tlm_base_initiator_socket<32, tlm::tlm_fw_transport_if<tlm::tlm_base_protocol_types>, tlm::tlm_bw_transport_if<tlm::tlm_base_protocol_types>, 1, sc_core::SC_ONE_OR_MORE_BOUND> C_15_m;
  tlm::tlm_base_initiator_socket<32, tlm::tlm_fw_transport_if<tlm::tlm_base_protocol_types>, tlm::tlm_bw_transport_if<tlm::tlm_base_protocol_types>, 1, sc_core::SC_ONE_OR_MORE_BOUND> i_counter_targetSocket;
  tlm::tlm_base_initiator_socket<32, tlm::tlm_fw_transport_if<tlm::tlm_base_protocol_types>, tlm::tlm_bw_transport_if<tlm::tlm_base_protocol_types>, 1, sc_core::SC_ONE_OR_MORE_BOUND> i_display_targetSocket;
  
  CwrModule_HARDWARE_BLFramework_BackBone BackBone;
  SNPS_AUTO_PTR<sc_core::sc_module> C_11_s_TLM2AMBAToFT_1of1;
  SNPS_AUTO_PTR<sc_core::sc_module> C_12_s_TLM2AMBAToFT_1of1;
  
  CwrModule_HARDWARE_BLFramework(sc_module_name _name) :
    sc_module(_name),
    m_Clk_pin("Clk_pin"),
    m_Rst_pin("Rst_pin"),
    C_11_s("C_11_s"),
    C_12_s("C_12_s"),
    C_13_m("C_13_m"),
    C_14_m("C_14_m"),
    C_15_m("C_15_m"),
    i_counter_targetSocket("i_counter_targetSocket"),
    i_display_targetSocket("i_display_targetSocket"),
    BackBone("BackBone"),
    C_11_s_TLM2AMBAToFT_1of1(dynamic_cast<sc_module*>(conf::cwr_sc_object_registry::inst().addObject(conf::ScObjectFactory::inst().create("cwrambapv::amba_pv_to_ft_bridge0<32>","C_11_s|TLM2AMBAToFT|1of1")))),
    C_12_s_TLM2AMBAToFT_1of1(dynamic_cast<sc_module*>(conf::cwr_sc_object_registry::inst().addObject(conf::ScObjectFactory::inst().create("cwrambapv::amba_pv_to_ft_bridge0<32>","C_12_s|TLM2AMBAToFT|1of1"))))
  {
    BackBone.m_Clk_pin(m_Clk_pin);
    add_portname_attr(m_Clk_pin, "Clk");
    (*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".C_11_s|TLM2AMBAToFT|1of1.p_clk")))((*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createPortProxy(&m_Clk_pin))));
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".C_11_s|TLM2AMBAToFT|1of1.p_clk"))).get_object(), "p_clk");
    (*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".C_12_s|TLM2AMBAToFT|1of1.p_clk")))((*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createPortProxy(&m_Clk_pin))));
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".C_12_s|TLM2AMBAToFT|1of1.p_clk"))).get_object(), "p_clk");
    BackBone.m_Rst_pin(m_Rst_pin);
    add_portname_attr(m_Rst_pin, "Rst");
    (*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createTargetSocketProxy(&C_11_s)))((*conf::cwr_sc_object_registry::inst().getTargetSocket(name() + std::string(".C_11_s|TLM2AMBAToFT|1of1.amba_pv_s"))));
    add_portname_attr(C_11_s, "C_11_s");
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getTargetSocket(name() + std::string(".C_11_s|TLM2AMBAToFT|1of1.amba_pv_s"))).get_object(), "amba_pv_s");
    (*conf::cwr_sc_object_registry::inst().getInitiatorSocket(name() + std::string(".C_11_s|TLM2AMBAToFT|1of1.tlm_m")))((*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createTargetSocketProxy(&BackBone.BB_C_11_s))));
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getInitiatorSocket(name() + std::string(".C_11_s|TLM2AMBAToFT|1of1.tlm_m"))).get_object(), "tlm_m");
    (*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createTargetSocketProxy(&C_12_s)))((*conf::cwr_sc_object_registry::inst().getTargetSocket(name() + std::string(".C_12_s|TLM2AMBAToFT|1of1.amba_pv_s"))));
    add_portname_attr(C_12_s, "C_12_s");
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getTargetSocket(name() + std::string(".C_12_s|TLM2AMBAToFT|1of1.amba_pv_s"))).get_object(), "amba_pv_s");
    (*conf::cwr_sc_object_registry::inst().getInitiatorSocket(name() + std::string(".C_12_s|TLM2AMBAToFT|1of1.tlm_m")))((*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createTargetSocketProxy(&BackBone.BB_C_12_s))));
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getInitiatorSocket(name() + std::string(".C_12_s|TLM2AMBAToFT|1of1.tlm_m"))).get_object(), "tlm_m");
    BackBone.BB_C_13_m(C_13_m);
    add_portname_attr(C_13_m, "C_13_m");
    BackBone.BB_C_14_m(C_14_m);
    add_portname_attr(C_14_m, "C_14_m");
    BackBone.BB_C_15_m(C_15_m);
    add_portname_attr(C_15_m, "C_15_m");
    BackBone.BB_i_counter_targetSocket(i_counter_targetSocket);
    add_portname_attr(i_counter_targetSocket, "i_counter_targetSocket");
    BackBone.BB_i_display_targetSocket(i_display_targetSocket);
    add_portname_attr(i_display_targetSocket, "i_display_targetSocket");
  }

  CwrModule_HARDWARE_BLFramework* operator->() { return this; }

  virtual void add_portname_attr(sc_object& obj, const std::string& value) {
    obj.add_attribute(*new sc_core::sc_attribute<std::string>("pct-port-name", value));
  }
  virtual void add_stub_attr(sc_object& obj) {
    obj.add_attribute(*new sc_core::sc_attribute<bool>("pct-stub", true));
  }
};

//-------------------------------

SC_MODULE(CwrModule_HARDWARE)
{
  sc_signal<bool> c_RST_pin;
  sc_signal<sc_uint<4> > C_03_pin;
  sc_signal<sc_uint<4> > C_04_pin;
  sc_signal<bool> conn_ARM_nFIQ_pin;
  sc_signal<bool> conn_ARM_nIRQ_pin;
  sc_signal<bool> conn_ARM_BIGENDINIT_pin;
  sc_signal<bool> conn_ARM_INITRAM_pin;
  sc_signal<bool> conn_ARM_VINITHI_pin;
  sc_signal<bool> conn_ARM_STANDBYWFI_pin;
  sc_signal<bool> conn_ARM_CFGBIGEND_pin;
  
  SNPS_AUTO_PTR<sc_core::sc_module> CLOCK_GENERATOR;
  SNPS_AUTO_PTR<sc_core::sc_module> RESET_GENERATOR;
  SNPS_AUTO_PTR<sc_core::sc_module> ROM;
  SNPS_AUTO_PTR<sc_core::sc_module> RAM;
  SNPS_AUTO_PTR<sc_core::sc_module> TERMINAL;
  LTCWR_ARM926EJS_TLM2_Model ARM;
  ARM926EJS_TCM_TLM2_Memory ITCM;
  ARM926EJS_TCM_TLM2_Memory DTCM;
  sc_core::sc_attribute<std::string> m_cwr_module_kind;
  CwrModule_HARDWARE_BLFramework BLFramework;
  SNPS_AUTO_PTR<sc_core::sc_module> stub_ARM_nFIQ;
  SNPS_AUTO_PTR<sc_core::sc_module> stub_ARM_nIRQ;
  SNPS_AUTO_PTR<sc_core::sc_module> stub_ARM_BIGENDINIT;
  SNPS_AUTO_PTR<sc_core::sc_module> stub_ARM_INITRAM;
  SNPS_AUTO_PTR<sc_core::sc_module> stub_ARM_VINITHI;
  SNPS_AUTO_PTR<sc_core::sc_module> stub_ARM_STANDBYWFI;
  SNPS_AUTO_PTR<sc_core::sc_module> stub_ARM_CFGBIGEND;
  ARM_COPROC_TLM_Model<true> stub_ARM_COPROC;
  counter i_counter;
  display i_display;
  
  CwrModule_HARDWARE(sc_module_name _name) :
    sc_module(_name),
    c_RST_pin("c_RST_pin"),
    C_03_pin("C_03_pin"),
    C_04_pin("C_04_pin"),
    conn_ARM_nFIQ_pin("conn_ARM_nFIQ_pin"),
    conn_ARM_nIRQ_pin("conn_ARM_nIRQ_pin"),
    conn_ARM_BIGENDINIT_pin("conn_ARM_BIGENDINIT_pin"),
    conn_ARM_INITRAM_pin("conn_ARM_INITRAM_pin"),
    conn_ARM_VINITHI_pin("conn_ARM_VINITHI_pin"),
    conn_ARM_STANDBYWFI_pin("conn_ARM_STANDBYWFI_pin"),
    conn_ARM_CFGBIGEND_pin("conn_ARM_CFGBIGEND_pin"),
    CLOCK_GENERATOR(dynamic_cast<sc_module*>(conf::cwr_sc_object_registry::inst().addObject(conf::ScObjectFactory::inst().create("GIPL_CLK0","CLOCK_GENERATOR")))),
    RESET_GENERATOR(dynamic_cast<sc_module*>(conf::cwr_sc_object_registry::inst().addObject(conf::ScObjectFactory::inst().create("GIPL_RST0","RESET_GENERATOR")))),
    ROM(dynamic_cast<sc_module*>(conf::cwr_sc_object_registry::inst().addObject(conf::ScObjectFactory::inst().create("GIPL_MEM_TLM20<32>","ROM")))),
    RAM(dynamic_cast<sc_module*>(conf::cwr_sc_object_registry::inst().addObject(conf::ScObjectFactory::inst().create("GIPL_MEM_TLM20<32>","RAM")))),
    TERMINAL(dynamic_cast<sc_module*>(conf::cwr_sc_object_registry::inst().addObject(conf::ScObjectFactory::inst().create("GIPL_OUTPUT_TLM20<32>","TERMINAL")))),
    ARM("ARM"),
    ITCM("ITCM"),
    DTCM("DTCM"),
    m_cwr_module_kind("CWR_MODULE_KIND", "Bus Framework"),
    BLFramework("BLFramework"),
    stub_ARM_nFIQ(dynamic_cast<sc_module*>(conf::cwr_sc_object_registry::inst().addObject(conf::ScObjectFactory::inst().create("GIPL_PIN_DRIVE0","stub_ARM_nFIQ")))),
    stub_ARM_nIRQ(dynamic_cast<sc_module*>(conf::cwr_sc_object_registry::inst().addObject(conf::ScObjectFactory::inst().create("GIPL_PIN_DRIVE0","stub_ARM_nIRQ")))),
    stub_ARM_BIGENDINIT(dynamic_cast<sc_module*>(conf::cwr_sc_object_registry::inst().addObject(conf::ScObjectFactory::inst().create("GIPL_PIN_DRIVE0","stub_ARM_BIGENDINIT")))),
    stub_ARM_INITRAM(dynamic_cast<sc_module*>(conf::cwr_sc_object_registry::inst().addObject(conf::ScObjectFactory::inst().create("GIPL_PIN_DRIVE0","stub_ARM_INITRAM")))),
    stub_ARM_VINITHI(dynamic_cast<sc_module*>(conf::cwr_sc_object_registry::inst().addObject(conf::ScObjectFactory::inst().create("GIPL_PIN_DRIVE0","stub_ARM_VINITHI")))),
    stub_ARM_STANDBYWFI(dynamic_cast<sc_module*>(conf::cwr_sc_object_registry::inst().addObject(conf::ScObjectFactory::inst().create("GIPL_PIN_STUB0","stub_ARM_STANDBYWFI")))),
    stub_ARM_CFGBIGEND(dynamic_cast<sc_module*>(conf::cwr_sc_object_registry::inst().addObject(conf::ScObjectFactory::inst().create("GIPL_PIN_STUB0","stub_ARM_CFGBIGEND")))),
    stub_ARM_COPROC("stub_ARM_COPROC", 0),
    i_counter("i_counter"),
    i_display("i_display")
  {
    (*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createPortProxy(&ARM.p_CLK)))((*conf::cwr_sc_object_registry::inst().getExport(name() + std::string(".CLOCK_GENERATOR.p_CLK"))));
    add_portname_attr(ARM.p_CLK, "CLK");
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getExport(name() + std::string(".CLOCK_GENERATOR.p_CLK"))).get_object(), "CLK");
    (*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createPortProxy(&BLFramework.m_Clk_pin)))((*conf::cwr_sc_object_registry::inst().getExport(name() + std::string(".CLOCK_GENERATOR.p_CLK"))));
    (*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createPortProxy(&i_counter.clk)))((*conf::cwr_sc_object_registry::inst().getExport(name() + std::string(".CLOCK_GENERATOR.p_CLK"))));
    add_portname_attr(i_counter.clk, "clk");
    (*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".RESET_GENERATOR.p_RST")))(c_RST_pin);
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".RESET_GENERATOR.p_RST"))).get_object(), "RST");
    ARM.p_nRESET(c_RST_pin);
    add_portname_attr(ARM.p_nRESET, "nHRESET");
    BLFramework.m_Rst_pin(c_RST_pin);
    (*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".TERMINAL.p_RST")))(c_RST_pin);
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".TERMINAL.p_RST"))).get_object(), "RST");
    i_counter.rst(c_RST_pin);
    add_portname_attr(i_counter.rst, "rst");
    ARM.p_iTCM(ITCM.p_DATA);
    add_portname_attr(ARM.p_iTCM, "ITCM_DATA");
    add_portname_attr(ITCM.p_DATA, "DATA");
    ARM.p_dTCM(DTCM.p_DATA);
    add_portname_attr(ARM.p_dTCM, "DTCM_DATA");
    add_portname_attr(DTCM.p_DATA, "DATA");
    ITCM.p_SIZE(C_03_pin);
    add_portname_attr(ITCM.p_SIZE, "SIZE");
    ARM.p_IRSIZE(C_03_pin);
    add_portname_attr(ARM.p_IRSIZE, "ITCM_SIZE");
    DTCM.p_SIZE(C_04_pin);
    add_portname_attr(DTCM.p_SIZE, "SIZE");
    ARM.p_DRSIZE(C_04_pin);
    add_portname_attr(ARM.p_DRSIZE, "DTCM_SIZE");
    ARM.p_iAHB(BLFramework.C_11_s);
    add_portname_attr(ARM.p_iAHB, "IAHB");
    ARM.p_dAHB(BLFramework.C_12_s);
    add_portname_attr(ARM.p_dAHB, "DAHB");
    (*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createInitiatorSocketProxy(&BLFramework.C_13_m)))((*conf::cwr_sc_object_registry::inst().getTargetSocket(name() + std::string(".ROM.p_MEM"))));
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getTargetSocket(name() + std::string(".ROM.p_MEM"))).get_object(), "MEM");
    (*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createInitiatorSocketProxy(&BLFramework.C_14_m)))((*conf::cwr_sc_object_registry::inst().getTargetSocket(name() + std::string(".RAM.p_MEM"))));
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getTargetSocket(name() + std::string(".RAM.p_MEM"))).get_object(), "MEM");
    (*cwr_sc_proxy_temp(conf::cwr_sc_object_registry::createInitiatorSocketProxy(&BLFramework.C_15_m)))((*conf::cwr_sc_object_registry::inst().getTargetSocket(name() + std::string(".TERMINAL.p_CTRL"))));
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getTargetSocket(name() + std::string(".TERMINAL.p_CTRL"))).get_object(), "CTRL");
    ARM.p_nFIQ(conn_ARM_nFIQ_pin);
    add_portname_attr(ARM.p_nFIQ, "nFIQ");
    add_stub_attr(ARM.p_nFIQ);
    (*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_nFIQ.p_STUB")))(conn_ARM_nFIQ_pin);
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_nFIQ.p_STUB"))).get_object(), "STUB");
    add_stub_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_nFIQ.p_STUB"))).get_object());
    ARM.p_nIRQ(conn_ARM_nIRQ_pin);
    add_portname_attr(ARM.p_nIRQ, "nIRQ");
    add_stub_attr(ARM.p_nIRQ);
    (*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_nIRQ.p_STUB")))(conn_ARM_nIRQ_pin);
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_nIRQ.p_STUB"))).get_object(), "STUB");
    add_stub_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_nIRQ.p_STUB"))).get_object());
    ARM.p_BIGENDINIT(conn_ARM_BIGENDINIT_pin);
    add_portname_attr(ARM.p_BIGENDINIT, "BIGENDINIT");
    add_stub_attr(ARM.p_BIGENDINIT);
    (*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_BIGENDINIT.p_STUB")))(conn_ARM_BIGENDINIT_pin);
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_BIGENDINIT.p_STUB"))).get_object(), "STUB");
    add_stub_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_BIGENDINIT.p_STUB"))).get_object());
    ARM.p_INITRAM(conn_ARM_INITRAM_pin);
    add_portname_attr(ARM.p_INITRAM, "INITRAM");
    add_stub_attr(ARM.p_INITRAM);
    (*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_INITRAM.p_STUB")))(conn_ARM_INITRAM_pin);
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_INITRAM.p_STUB"))).get_object(), "STUB");
    add_stub_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_INITRAM.p_STUB"))).get_object());
    ARM.p_VINITHI(conn_ARM_VINITHI_pin);
    add_portname_attr(ARM.p_VINITHI, "VINITHI");
    add_stub_attr(ARM.p_VINITHI);
    (*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_VINITHI.p_STUB")))(conn_ARM_VINITHI_pin);
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_VINITHI.p_STUB"))).get_object(), "STUB");
    add_stub_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_VINITHI.p_STUB"))).get_object());
    ARM.p_STANDBYWFI(conn_ARM_STANDBYWFI_pin);
    add_portname_attr(ARM.p_STANDBYWFI, "STANDBYWFI");
    add_stub_attr(ARM.p_STANDBYWFI);
    (*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_STANDBYWFI.p_STUB")))(conn_ARM_STANDBYWFI_pin);
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_STANDBYWFI.p_STUB"))).get_object(), "STUB");
    add_stub_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_STANDBYWFI.p_STUB"))).get_object());
    ARM.p_BIGENDOUT(conn_ARM_CFGBIGEND_pin);
    add_portname_attr(ARM.p_BIGENDOUT, "CFGBIGEND");
    add_stub_attr(ARM.p_BIGENDOUT);
    (*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_CFGBIGEND.p_STUB")))(conn_ARM_CFGBIGEND_pin);
    add_portname_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_CFGBIGEND.p_STUB"))).get_object(), "STUB");
    add_stub_attr(*(*conf::cwr_sc_object_registry::inst().getPort(name() + std::string(".stub_ARM_CFGBIGEND.p_STUB"))).get_object());
    stub_ARM_COPROC.p_COPROC(ARM.p_COPROC);
    add_portname_attr(stub_ARM_COPROC.p_COPROC, "COPROC");
    add_portname_attr(ARM.p_COPROC, "COPROC");
    add_stub_attr(stub_ARM_COPROC.p_COPROC);
    add_stub_attr(ARM.p_COPROC);
    BLFramework.i_counter_targetSocket(i_counter.targetSocket);
    add_portname_attr(i_counter.targetSocket, "targetSocket");
    BLFramework.i_display_targetSocket(i_display.targetSocket);
    add_portname_attr(i_display.targetSocket, "targetSocket");
    BLFramework.add_attribute(m_cwr_module_kind);
  }

  CwrModule_HARDWARE* operator->() { return this; }

  virtual void add_portname_attr(sc_object& obj, const std::string& value) {
    obj.add_attribute(*new sc_core::sc_attribute<std::string>("pct-port-name", value));
  }
  virtual void add_stub_attr(sc_object& obj) {
    obj.add_attribute(*new sc_core::sc_attribute<bool>("pct-stub", true));
  }
};

//-------------------------------

#endif // HARDWARE_H
