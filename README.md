# EPL

This repo contains the code files for the  *Embedded Processor Lab*.

Folder structure and hierarchy:

* **tasks** <br>
contains the original files without any modifications

* **V4**: <br>
contains the files for the DLX pipeline without forwarding (dlx_pipe_ctrl.vhd/dlx_pipe_id.vhd)

* **V5**: <br>
contains three subfolders with different implementations of the forwarding unit. Folder *forwarding_v3.0* contains the current and working implementation files.

* **V6**: <br>
contains the necessary files for working with SystemC, TLM and the Platform Creator. Furthermore, it contains under /t7e two files *main_new.cpp*  *main_old.cpp*, where former is the current implementation of the median filter with the insertionSort algorithm. The file *runtimes* lists the simulation runtimes with and without compiler optimization of the implemented median filter.

 
