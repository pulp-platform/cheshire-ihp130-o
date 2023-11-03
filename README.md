# Iguana

Iguana is an end-to-end open source Linux-capable SoC targeting IHP's [130nm BiCMOS Open Source PDK](https://github.com/IHP-GmbH/IHP-Open-PDK). It is based on our Linux-capable toolkit called [Cheshire](https://github.com/pulp-platform/cheshire). Iguana is part of the [PULP (Parallel Ultra-Low-Power) platform](https://pulp-platform.org/).

## Disclaimer

This project is still under active development; some parts may not yet be fully functional, and existing interfaces, toolflows, and conventions may be broken without prior notice. We target a stable release as soon as possible.

## License

Unless specified otherwise in the respective file headers, all code checked into this repository is made available under a permissive license. All hardware sources and tool scripts are licensed under the Solderpad Hardware License 0.51 (see `LICENSE`). All software sources are licensed under Apache 2.0.

## Required Tools
### RTL to Netlist
Make sure the following tools are installed.
Also check `tools.mk` and ensure all tools are either in `PATH` or set directly.

- [Bender](https://github.com/pulp-platform/bender#installation)
- [Morty](https://github.com/pulp-platform/morty#install)
- [SVase](https://github.com/pulp-platform/svase#install--build)
- [SV2V](https://github.com/zachjs/sv2v#installation)
- Yosys: Until [PR#3833](https://github.com/YosysHQ/yosys/pull/3883) is merged, please use the branch `peepopt-shiftadd` from [phsauter/yosys](https://github.com/phsauter/yosys/tree/peepopt-shiftadd#building-from-source) and build from source

Additionally the following python packages are required:
```bash
# from register_interface
hjson
Mako
PyYAML
setuptools
tabulate
# memory and cpu profiler
procpath
```

### Netlist to Geometry
- [OpenRoad](https://github.com/The-OpenROAD-Project/OpenROAD/blob/master/docs/user/Build.md)

### Simulation
- riscv64-unknown-elf-gcc
- Modelsim
