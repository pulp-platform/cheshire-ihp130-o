# Preprocessing
Since yosys does not understand SystemVerilog natively and existing parsers still have numerous problems, 
we decided to preprocess our SystemVerilog code and convert it into simpler Verilog before giving it to yosys.

This is done in a few steps:
1. Bender, the dependancy manager, generates a list of all used SystemVerilog files
2. Morty copies all files into one, while doing so it does the preprocessing and skips deactivated code
3. SVase simplifies the written SystemVerilog to a point where
4. SV2V converts the simplified SystemVerilog to Verilog

After the hardware is configured (in root of repo), the command `run-pickle` can be executed to perform this preprocessing.

## RTL Patches
A few RTL patches are necessary to help the tools with some edge-cases.

### Before Morty
The `<< riscv::XLEN-2` in `àriane_pkg.sv` causes a parsing error in morty.  
Adding the parenthesis prevents it (fix is in `pickle.mk`).

### After Morty
#### clic_implicit_enum_cast.patch
SVase wants an explict cast otherwise it throws:
```
error: value of type 'logic[1:0]' cannot be assigned to type 'priv_lvl_t'
    .irq_priv_o     ( clic_irq_priv  ),
```

#### hyperbus_w2phy_forloops.patch
Yosys can't handle variable length for-loops.

#### intr_routed_indexing.patch
Prevents sv2v from blowing up with the error:
```
sv2v: can't determine the type of intr_routed[1][56:0] 
because the inner type struct packed {...} can't be indexed, within scope cheshire_soc...
```

#### reg_bus_interface_dropin.append
For some reason Morty does not copy in this interface when pickling, so we add it manually.

#### wt_axi_adapter.patch
This fixes a synthesis (or more accurate frontend) issue in yosys.  
For some reason the partial assignments in this switch-case make it so
yosys ignores the default assignments above it for the non-assigned portions in the switch-case.
So it acts as if there were `X` (nothing) assigned to the remaining bits.


### After SVase
#### protocol_e_axi_renaming.patch
sv2v cannot distinguish the different things named `ÀXI` (from interface and from enum-element)  
The now local enum element is renamed to avoid this.

### SlinkMaxClkDiv_renaming.patch
Same problem with `SlinkMaxClkDiv` except here the parameter is not used so we just remove it.

#### svase.sed
We elaborate `RegOut.num_out` to avoid the following error in yosys:
`ERROR: syntax error, unexpected '.'` (the `.num_out`)
```verilog
function automatic [cf_math_pkg_idx_width(sv2v_cast_81F05(9062'h420c41461c8...).num_out) - 1:0] sv2v_cast_94EB4;
    input reg [cf_math_pkg_idx_width(sv2v_cast_81F05(9062'h420c41461c8...).num_out) - 1:0] inp;
    sv2v_cast_94EB4 = inp;
endfunction
```


### After SV2V
#### sv2v.sed
Fix for Yosys not being able to handle variable length for-loops.
```
s|for \(i = 0; i < advance; i = i \+ 1\);|for \(i = 0; i < 0; i = i \+ 1\);|g
```

Avoids issues with non-existant(?) cross boundary optimization in yosys.  
```
s|rst_addr_q <= boot_addr_i;|rst_addr_q <= 64'h0000000002000000;|g
```