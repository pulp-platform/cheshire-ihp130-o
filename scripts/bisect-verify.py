import verify

# SVASE_FILE = "target/ihp13/pickle/iguana_chip.svase.sim.sv"
# SV2V_FILE = "target/ihp13/pickle/out/iguana_chip.sv2v.v"
SVASE_FILE = "target/ihp13/pickle/out/iguana_chip.sv2v.v"
SV2V_FILE = "target/ihp13/yosys/build/iguana_chip_yosys.v"

def extract_modules(lines):
    modules = {}
    module_name = ""
    module_lines = []
    other_lines = []
    LAST_LINES_STORED = 4
    last_lines = ["" for i in range(LAST_LINES_STORED)]
    for line in lines:
        if line.startswith("module ") or line.startswith("(* no_ungroup *) (* no_boundary_optimization *) module"):
            module_name = line.split(" ")[1]
            if line.startswith("(* no_ungroup *) (* no_boundary_optimization *) module"):
                module_name = line.split(" ")[7]
            print("module_name", module_name)
            module_name = module_name.split("(")[0].strip()
            other_lines = other_lines + module_lines
            module_lines = []
            # if last_three_line start with a (*
            for i in range(LAST_LINES_STORED):
                if last_lines[i].startswith("(*"):
                    module_lines.append(last_lines[i])
            module_lines.append(line)
        elif line.startswith("endmodule"):
            module_lines.append(line)
            modules[module_name] = module_lines
            module_lines = []
        else:
            module_lines.append(line)
        last_lines = last_lines[1:] + [line]
    return modules, other_lines

def get_module_string(module_lines):
    module_string = ""
    for line in module_lines:
        module_string += line
    return module_string

def create_bisected_str(sv2v_sel, svase_sel, sv2v_modules, svase_modules, base_selection_sv2v):
    total_str = ""
    for module_name in sv2v_sel:
        total_str += get_module_string(sv2v_modules[module_name])
    total_str += "\n"
    for module_name in base_selection_sv2v:
        total_str += get_module_string(sv2v_modules[module_name])
    total_str += "\n"
    for module_name in svase_sel:
        total_str += get_module_string(svase_modules[module_name])
    return total_str

def write_bisected_str(context, bisected_str, filename):
    with open(filename, "w") as f:
        f.write(context)
        f.write(bisected_str)

def main():
    # read in the files
    with open(SVASE_FILE, "r") as f:
        svase = f.readlines()
    with open(SV2V_FILE, "r") as f:
        sv2v = f.readlines()

    print("SVASE: ", len(svase))
    print("SV2V: ", len(sv2v))

    # extract modules with their contents
    svase_modules, svase_context = extract_modules(svase)
    sv2v_modules,_ = extract_modules(sv2v)

    context = ""
    for line in svase_context:
        context += line
    
    with open("target/ihp13/pickle/out/iguana_chip.context.sv", "w") as f:
        f.write(context)

    # compare the modules
    for module_name in sv2v_modules:
        if module_name not in svase_modules:
            print("Module {} not in svase".format(module_name))

    # compare the other way
    for module_name in svase_modules:
        if module_name not in sv2v_modules:
            print("Module {} not in sv2v".format(module_name))

    # total number of modules
    print("Total number of modules: ", len(sv2v_modules))

    # print the first model
    keys = list(sv2v_modules.keys())
    print(get_module_string(sv2v_modules[keys[2]]))

    # bisection selection of the modules
    # start with full sv2v_modules
    all_modules = list(sv2v_modules.keys())
    top_level = "iguana_chip"
    all_modules.remove(top_level)
    base_selection_sv2v = [top_level]

    known_good_sv2v = []
    modules_sel_sv2v = all_modules
    modules_sel_svase = []

    with open("target/ihp13/pickle/out/iguana_chip.bisect.log", "w") as f:
        f.write("Starting bisect...\n")

    final_start = 603
    final_end = 604

    # bisection test
    if True:
        start_index = 0
        end_index = len(all_modules)
        iteration = 0

        for i in range(12):
            modules_sel_sv2v = all_modules[:start_index] + all_modules[end_index:]
            modules_sel_svase = all_modules[start_index:end_index]
            # create the bisected string
            bisected_str = create_bisected_str(modules_sel_sv2v, modules_sel_svase, sv2v_modules, svase_modules, base_selection_sv2v)

            # write the bisected string
            write_bisected_str(context, bisected_str, "target/ihp13/pickle/out/iguana_chip.bisect.sv")

            COMPILE_EXT = "bisect"
            results = verify.run_test(COMPILE_EXT=COMPILE_EXT)
            result = "FAIL"
            if results[0] == 0:
                result = "PASS"
            print(result)
            print("start_index: ", start_index)
            print("end_index: ", end_index)
            # write progress to log file
            with open("target/ihp13/pickle/out/iguana_chip.bisect.log", "a") as f:
                f.write("iteration: {}\n".format(iteration))
                f.write("start_index: {}\n".format(start_index))
                f.write("end_index: {}\n".format(end_index))
                f.write("sv2v:0-{} & {}-{}\n".format(start_index, end_index, len(all_modules)-1))
                f.write("svase:{}-{}\n".format(start_index, end_index))
                f.write("result: {}\n\n".format(result))

            if results[0] == 0:
                # passed
                final_start = start_index
                final_end = end_index
                end_index = start_index + (end_index - start_index) // 2
            else:
                # failed
                offset = (end_index - start_index + 1)  // 2
                start_index = end_index
                end_index = end_index + offset
            iteration += 1
        print("Bisection done")
        with open("target/ihp13/pickle/out/iguana_chip.bisect.log", "a") as f:
            for i in range(final_start, final_end+1):
                f.write("candidate module[{}]: {}\n\n\n".format(i, all_modules[i]))

    print(all_modules[final_start:final_end+1])

    # single module test
    if True:
        for i in range(final_start-3,final_end+3):
            modules_sel_sv2v = all_modules[:i] + all_modules[i+1:]
            modules_sel_svase = [all_modules[i]]
            # create the bisected string
            bisected_str = create_bisected_str(modules_sel_sv2v, modules_sel_svase, sv2v_modules, svase_modules, base_selection_sv2v)

            # write the bisected string
            write_bisected_str(context, bisected_str, "target/ihp13/pickle/out/iguana_chip.bisect.sv")

            COMPILE_EXT = "bisect"
            results = verify.run_test(COMPILE_EXT=COMPILE_EXT)
            result = "FAIL"
            if results[0] == 0:
                result = "PASS"
                write_bisected_str(context, bisected_str, "target/ihp13/pickle/out/iguana_chip.bisect.passed.sv")
            with open("target/ihp13/pickle/out/iguana_chip.bisect.log", "a") as f:
                f.write("testing without sv2v module[{}]: {}\n".format(i, all_modules[i]))
                f.write("result: {}\n\n".format(result))
            print(result)

if __name__ == "__main__":
    main()

# ['sub_per_hash__1898454097102328077', 'sub_per_hash__2413030449931794156']
