::namespace eval ::pct::build {
    proc add_vpsim_path { fromPath toPath } {
        while { [string first "\\" "$fromPath"] >= 0 } {
            set idx [string first "\\" "$fromPath"]
            set fromPath [string replace "$fromPath" $idx $idx "/" ]
        }
        if {[file isdirectory "$fromPath"]} {
            foreach childPath [glob -nocomplain -directory "$fromPath" "*"] {
                set newToPath "$toPath/[file tail $fromPath]"
                ::file mkdir "$newToPath"
                add_vpsim_path "$childPath" "$newToPath"
            }
        } else {
            if {![file isdirectory "$toPath"] && \
                [file dirname "$toPath"] != "."} then {
              ::file mkdir [file dirname "$toPath"]
            }
            ::file copy -force -- "$fromPath" "$toPath"
        }
    }
    proc add_vppack_path { fromPath toPath } {
        while { [string first "\\" "$fromPath"] >= 0 } {
            set idx [string first "\\" "$fromPath"]
            set fromPath [string replace "$fromPath" $idx $idx "/" ]
        }
        if {[file isdirectory "$fromPath"]} {
            foreach childPath [glob -nocomplain -directory "$fromPath" "*"] {
                add_vppack_path "$childPath" "$toPath/[file tail $fromPath]"
            }
        } else {
            ::scsh::vp::add_file_to_package "$fromPath" "$toPath"
        }
    }
  proc callback {args} {
    ::scsh::cwr_add_ip_load_library_dir "[::subst -nobackslashes -nocommands {./simulation/FastBuild/AMBA_TLM2_BL/gcc-5.2.0-64}]"
    [namespace current]::add_vppack_path "[::subst -nobackslashes -nocommands {/net/software/r1/Linux/software/Synopsys_CoWare/N-2017.12/VPProducts/IP/GenericIPlib/SystemC/lib/linux.gcc-5.2.0-64/libClockGenerator.so}]" "[::subst -nobackslashes -nocommands {simulation/FastBuild/GenericIPlib}]"
    [namespace current]::add_vppack_path "[::subst -nobackslashes -nocommands {/net/software/r1/Linux/software/Synopsys_CoWare/N-2017.12/VPProducts/IP/GenericIPlib/SystemC/lib/linux.gcc-5.2.0-64/libMemory_tlm2.so}]" "[::subst -nobackslashes -nocommands {simulation/FastBuild/GenericIPlib}]"
    [namespace current]::add_vppack_path "[::subst -nobackslashes -nocommands {/net/software/r1/Linux/software/Synopsys_CoWare/N-2017.12/VPProducts/IP/GenericIPlib/SystemC/lib/linux.gcc-5.2.0-64/libOutputDevice_tlm2.so}]" "[::subst -nobackslashes -nocommands {simulation/FastBuild/GenericIPlib}]"
    [namespace current]::add_vppack_path "[::subst -nobackslashes -nocommands {/net/software/r1/Linux/software/Synopsys_CoWare/N-2017.12/VPProducts/IP/GenericIPlib/SystemC/lib/linux.gcc-5.2.0-64/libPin_drive.so}]" "[::subst -nobackslashes -nocommands {simulation/FastBuild/GenericIPlib}]"
    [namespace current]::add_vppack_path "[::subst -nobackslashes -nocommands {/net/software/r1/Linux/software/Synopsys_CoWare/N-2017.12/VPProducts/IP/GenericIPlib/SystemC/lib/linux.gcc-5.2.0-64/libPin_stub.so}]" "[::subst -nobackslashes -nocommands {simulation/FastBuild/GenericIPlib}]"
    [namespace current]::add_vppack_path "[::subst -nobackslashes -nocommands {/net/software/r1/Linux/software/Synopsys_CoWare/N-2017.12/VPProducts/IP/GenericIPlib/SystemC/lib/linux.gcc-5.2.0-64/librst.so}]" "[::subst -nobackslashes -nocommands {simulation/FastBuild/GenericIPlib}]"
    [namespace current]::add_vppack_path "[::subst -nobackslashes -nocommands {/net/software/r1/Linux/software/Synopsys_CoWare/N-2017.12/VPProducts/IP/SBLTLM2FT_BL/SystemC/lib/linux.gcc-5.2.0-64/libftbus.so}]" "[::subst -nobackslashes -nocommands {simulation/FastBuild/SBLTLM2FT_BL}]"
    [namespace current]::add_vppack_path "[::subst -nobackslashes -nocommands {/net/software/r1/Linux/software/Synopsys_CoWare/N-2017.12/VPProducts/SLS/linux/IP_common/AMBA_TLM2_BL/lib/linux/gcc-5.2.0-64/libamba_pv_to_ft_bridge.so}]" "[::subst -nobackslashes -nocommands {simulation/FastBuild/AMBA_TLM2_BL/gcc-5.2.0-64}]"
    [namespace current]::add_vppack_path "[::subst -nobackslashes -nocommands {/net/user/r1/unix/mep_04/tasks/t7e/vp/export/parameters/HARDWARE.unevald.parameters}]" "[::subst -nobackslashes -nocommands {simulation/parameters}]"
  }
  ::scsh::add_build_callback [::namespace current]::callback
}
