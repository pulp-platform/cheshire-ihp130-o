# Open Synthesis Flow

## Goal
This directory should contain all things needed to go from a list of files (from `bender sources`) to a synthesized netlist

## Flow
```mermaid
graph LR;
	Bender-->Morty;
	Morty-->svase;
	svase-->sv2v;
	sv2v-->yosys;
```
1. Bender provides a list of files
2. These files are pickled into one using Morty
3. The pickled file is simplified using svase
4. The simplified SystemVerilog code is run through sv2v
5. This gives us synthesizable Verilog (hopefully) which is then loaded into yosys
6. In yosys the Verilog RTL goes through various passes and is mapped to the technology cells
7. The synthesized netlist is the final product

## Todo
### Morty
- [ ] `REGBUS` not copied properly

### svase
- [X] Whatever this bug is:
```
terminate called after throwing an instance of 'slang::assert::AssertionException'
  what():  Assertion 'T::isKind(kind)' failed
  in file /scratch/janniss/Documents/svase/deps/install/include/slang/ast/Symbol.h, line 201
  function: decltype(auto) slang::ast::Symbol::as() [with T = slang::ast::InstanceSymbol]
```

### sv2v 


### yosys
```
ERROR: 2nd expression of procedural for-loop is not constant!
```

```
for (int i=0; i<byte_idx_q; i++)
    data_buffer_d.strb[i]='0;
```
'solved' via sed to `data_buffer_d.strb[byte_idx_q-1:0]='0;`


---


```
ERROR: 2nd expression of procedural for-loop is not constant!
```

```
for (i = 0; i < advance; i = i + 1)
	begin
		// Trace: opensynth/build/iguana.svase.sv:17867:9
		rand_number = ((A * rand_number) + C) % M;
	end
```


---


```
// Trace: opensynth/build/iguana.svase.sv:17847:12
for (i = 0; i < InpWidth; i = i + 1)
	begin
		// Trace: opensynth/build/iguana.svase.sv:17848:9
		indices[r][i] = i;
	end
```

```
opensynth/build/iguana.sv2v.v:20913: ERROR: Unsupported expression on dynamic range select on signal `\get_permutations$func$opensynth/build/iguana.sv2v.v:20956$54193.indices'!
```

---

```
ERROR: Multiple edge sensitive events found for this signal!
```

```
always_ff @(negedge ddr_rcv_clk_i, negedge rst_ni) ddr_q <= !rst_ni ? '0 : ddr_i;
```

Apparently yosys does it according to IEEE 1364.1 and we should change our source
[yosys-issue](https://github.com/YosysHQ/yosys/issues/3292#issuecomment-1114819303)