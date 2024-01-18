# pylint: disable=invalid-name, missing-module-docstring, broad-exception-raised, missing-function-docstring
import subprocess
from multiprocessing import Pool
import tempfile

# We only need this script because gitlab-runner exec shell does not support
# the extend keyword.....

def run_command(cmd: str, print_all: bool = True):
    # pylint: disable=subprocess-run-check
    process = subprocess.Popen(
        [cmd], stdout=subprocess.PIPE, shell=True, executable="/bin/bash"
    )
    output_str_list = []
    total_output_str = ""
    for line in iter(process.stdout.readline, b""):  # type: ignore[union-attr]
        decoded = line.decode("utf-8")
        output_str_list.append(decoded)
        total_output_str += decoded + "\n"
        if print_all:
            print(decoded, end="")
    return_code = process.wait()
    print(f"Return code: {return_code}")
    if return_code != 0:
        print("Output:")
        for line in output_str_list[-50:]:
            print(line, end="")
    else:
        print("Command succeeded")
    return [return_code, output_str_list[-50:]]

def run_test(BM=0, PM=0, TEST = "helloworld.spm", COMPILE_EXT=""):
    print(f"Running test with BM={BM}, PM={PM}, TEST={TEST}, COMPILE_EXT={COMPILE_EXT}")
    # pylint: disable=anomalous-backslash-in-string
    # defaults
    VSIM = "questa-2022.3 vsim"
    USTR = "Hello World!"
    TARGET = "sim"
    IMG = ""
    BIN = ""
    if BM == 0:
        BIN = f"../../../../sw/tests/{TEST}.elf"
    else:
        IMG = f"../../../../sw/tests/{TEST}.memh"
    base_command = ""
    if COMPILE_EXT == "bisect":
        base_command += "make ig-sim-clean && make ig-sim-bisect-prep && "

    # create a tmp folder and copy to it
    with tempfile.TemporaryDirectory(dir=f"target/{TARGET}/vsim") as tempDir:
        base_command += f"""
        cd {tempDir} && \
        pwd && \
        cp ../start.iguana.tcl . && \
        cp ../compile.ihp13.{COMPILE_EXT}.tcl . && \
        cp -r ../../models ../models && \
        {VSIM} -c -do "set PRELMODE {PM}; set BOOTMODE {BM}; set IMAGE {IMG}; set BINARY {BIN}; source compile.ihp13.{COMPILE_EXT}.tcl; source start.iguana.tcl; run -all" && \
        grep "] SUCCESS" transcript && \
        grep " \[UART\] {USTR}" transcript && \
        """
        base_command += """
        sed -i -E '/# \*\* Error: \$width\( negedge SCL:\[0-9\]+ ns, :\[0-9\]+ ns, 500 ns \);/{N;/\\n#    Time: \[0-9\]+ ns  Iteration: \[0-9\]+  Process: .*?\/#Width# File: .*?\/24FC1025.v Line: 660/d}' transcript && \
        ! grep -n "Error:" transcript
        """
        results = run_command(base_command)
        print(f"Finished test with BM={BM}, PM={PM}, TEST={TEST}, COMPILE_EXT={COMPILE_EXT}")
        return results

TESTS = [
  # BM, PM, TEST
  (0, 0, "helloworld.spm"),
  # (0, 1, "helloworld.spm"),
  # (0, 2, "helloworld.spm"),
  # (2, 0, "helloworld.rom"),
  # (2, 0, "helloworld.gpt"),
  # (3, 0, "helloworld.gpt"),
  # [0, 1, "helloworld.spm"],
  # (0, 1, "helloworld.dram")
]

def create_test_matrix(COMPILE_EXT=""):
    tests_with_ext = [x + (COMPILE_EXT,) for x in TESTS]
    return tests_with_ext

COMPILE_EXTs = [
    # "",
    "_svase_open",
    "_sv2v_open",
    "_yosys_hybrid_open",
    "_svase_close",
    "_sv2v_close",
    "_yosys_hybrid_close",
]

def run_tests():
    all_tests = []
    for COMPILE_EXT in COMPILE_EXTs:
        all_tests.append(create_test_matrix(COMPILE_EXT))
    all_tests = [item for sublist in all_tests for item in sublist]
    with Pool(8) as p:
        results = p.starmap(run_test, all_tests)
        simple_overview = []
        for result in zip(results, all_tests):
            row = ["FAILED" if result[0][0] else "PASSED", result[1]]
            simple_overview.append(row)
            if result[0][0] != 0:
                with open(f"target/sim/vsim/transscript_failed_{result[1][0]}_{result[1][1]}_{result[1][2]}_{result[1][3]}.txt", "w") as f:
                    f.writelines(result[0][1])
        print("Simple overview:")
        for row in simple_overview:
            print(row)

if __name__ == "__main__":
    run_tests()
