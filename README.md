# Iguana

Iguana is an end-to-end open source Linux-capable SoC targeting IHP's [130nm BiCMOS Open Source PDK](https://github.com/IHP-GmbH/IHP-Open-PDK). It is based on our Linux-capable toolkit called [Cheshire](https://github.com/pulp-platform/cheshire). Iguana is part of the [PULP (Parallel Ultra-Low-Power) platform](https://pulp-platform.org/).

Iguana is currently being developed further as Basilisk. The RTL is based on a newer version of Cheshire, otherwise it is the same. The main difference are the physical dimension of the chip.

The top-level design is called `ìguana_chip`, the current project name (and with it the file names) is `basilisk`.


## Disclaimer

This project is still under active development; some parts may not yet be fully functional, and existing interfaces, toolflows, and conventions may be broken without prior notice. We target a stable release as soon as possible.


## License

Unless specified otherwise in the respective file headers, all code checked into this repository is made available under a permissive license. All hardware sources and tool scripts are licensed under the Solderpad Hardware License 0.51 (see `LICENSE`). All software sources are licensed under Apache 2.0.



## Tools

### Docker

As long as you do not want to tinker with the tools, the easiest setup is with the docker image.

1. [Install Docker](https://docs.docker.com/engine/install/)
   1. Optional but recommended: [Docker as non-root user](https://docs.docker.com/engine/install/linux-postinstall/)
2. [Install docker-compose](https://docs.docker.com/compose/install/)
3. clone repository
4. in the repo-root, execute `./use-docker.sh`

### Local install

Make sure the following tools are installed.
Then check `tools.mk`, it contains the paths to all tools. They either need to be in the `PATH` or set directly.

- [Bender](https://github.com/pulp-platform/bender#installation): Dependency manager
- [Morty](https://github.com/pulp-platform/morty#install): SystemVerilog pickler
- [SVase](https://github.com/pulp-platform/svase#install--build): SystemVerilog pre-elaborator
- [SV2V](https://github.com/zachjs/sv2v#installation): SystemVerilog to Verilog
- [Yosys](https://github.com/YosysHQ/yosys#building-from-source): Synthesis tool; The used version must be **newer than v0.35+7**, more specifically [PR-3883](https://github.com/YosysHQ/yosys/pull/3883) is necessary. At time of writing this means it must be built from source as there is no newer release version.
- [OpenRoad](https://github.com/The-OpenROAD-Project/OpenROAD/blob/master/docs/user/Build.md): Backend tool

The following tools are only required to build software and simulate the design:
- riscv64-unknown-elf-gcc
- Modelsim

Additionally the following python packages are required:
```bash
# requirement from register_interface
pip3 install hjson Mako PyYAML setuptools tabulate

# memory and cpu profiler (optional)
pip3 install procpath
```



## Quick Start

More documentation specifically for Iguana/Basilisk is currently not available.
However, the [Cheshire Documentation](https://pulp-platform.github.io/cheshire/) gives a good overview of this project as well.

```bash
# download RTL, generate register-files, configure units
make ig-hw-all
# pickle to Verilog
make pickle-all
# Yosys synthesis (~4-5h)
make synth-all
# OpenRoad backend (>24h)
make backend-all

# build Cheshire test software
make ig-sw-all
# prepare for simulation
make ig-sim-all
# run simulation, select one in [...] and optinally add -gui
make ig-sim-[rtl/sv2v/synth](-gui)
```

## Flow
```mermaid
graph LR;
	Bender-->Morty;
	Morty-->SVase;
	SVase-->SV2V;
	SV2V-->yosys;
	yosys-->OpenRoad;
```
1. Bender provides a list of SystemVerilog files
2. These files are pickled into one context using Morty
3. The pickled file is simplified using SVase
4. The simplified SystemVerilog code is run through SV2V
5. This gives us synthesizable Verilog which is then loaded into yosys
6. In yosys the Verilog RTL goes through various passes and is mapped to the technology cells
7. The netlist, constraints and floorplan are loaded into OpenRoad for Place&Route