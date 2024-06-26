#!/usr/bin/env python3

from subprocess import run, CompletedProcess
from os import remove, makedirs, path
from shutil import rmtree
from typing import Callable
import argparse

RESULT_DIR = "test_results"


def run_bench(
    name: str, cleanup: Callable[[], None], success_cond: Callable[[str], bool]
) -> None:
    """Runs a particular testbench

    'name': used in the command `make {name}`
    'cleanup': function to delete testbench output of the previous run
    'success_cond': takes in the stdout of running a testbench
                    returns whether the run was successful
    """
    print(f"Running make {name}: ", end="")
    cleanup()
    proc = run(["make", name], capture_output=True)
    stdout = proc.stdout.decode("utf-8")
    stderr = proc.stderr.decode("utf-8")
    with open(path.join(RESULT_DIR, f'{name.split("/")[-1]}.out'), "w") as fout:
        fout.write(stdout)
    with open(path.join(RESULT_DIR, f'{name.split("/")[-1]}.err'), "w") as ferr:
        ferr.write(stderr)
    if not success_cond(stdout):
        print(f"Failed")
        print("stdout:")
        print(stdout)
        print("stderr:")
        print(stderr)
        print(f"See {RESULT_DIR} for logs")
        exit(1)
    else:
        print("Passed")


def cleanup_isa_tests() -> None:
    rmtree("vsim/isa", ignore_errors=True)


def cleanup_c_tests() -> None:
    rmtree("vsim/c_tests", ignore_errors=True)


def get_grep_output(proc: CompletedProcess) -> str:
    stdout = proc.stdout.decode("utf-8").strip()
    return stdout.split("\n")


def isa_test_success_cond(_: str) -> bool:
    proc_failed = run(
        'grep -r -i "failed" vsim/isa/*.log', shell=True, capture_output=True
    )
    proc_timout = run(
        'grep -r -i "timeout" vsim/isa/*.log', shell=True, capture_output=True
    )
    tests_failed = get_grep_output(proc_failed) + get_grep_output(proc_timout)
    filtered_tests = list(
        filter(lambda l: ("fence_i" not in l) and l != "", tests_failed)
    )
    if filtered_tests:
        return False
    return True


def c_test_success_cond(_: str) -> bool:
    proc_failed = run(
        'grep -r -i "failed" vsim/c_tests/*.log', shell=True, capture_output=True
    )
    proc_timout = run(
        'grep -r -i "timeout" vsim/c_tests/*.log', shell=True, capture_output=True
    )
    tests_failed = get_grep_output(proc_failed) + get_grep_output(proc_timout)
    filtered_tests = list(filter(lambda l: l != "", tests_failed))
    if filtered_tests:
        return False
    return True


def silent_remove_factory(testbench: str, simulator: str) -> Callable[[], None]:
    def foo():
        try:
            if simulator == "vcs":
                remove(f"vsim/{testbench}.tb")
                remove(f"vsim/{testbench}.vpd")
                rmtree(f"vsim/{testbench}.tb.daidir")
            else:
                remove(f"vsim/{testbench}.tbi")
                remove(f"vsim/{testbench}.fst")
            remove(f"vsim/{testbench}.log")
        except OSError:
            pass

    return foo


def main():
    makedirs(RESULT_DIR, exist_ok=True)
    parser = argparse.ArgumentParser(description="Run all RTL simulations and perform checks")
    parser.add_argument("--simulator", type=str, choices=["vcs", "iverilog"], default="iverilog", help="The RTL simulator to use")
    args = parser.parse_args()
    waveform_suffix = "vpd" if args.simulator == "vcs" else "fst"
    run_bench(
        f"vsim/asm_tb.{waveform_suffix}",
        silent_remove_factory("asm_tb", args.simulator),
        lambda stdout: "ALL ASSEMBLY TESTS PASSED!" in stdout,
    )
    run_bench(
        f"vsim/cpu_tb.{waveform_suffix}",
        silent_remove_factory("cpu_tb", args.simulator),
        lambda stdout: "All tests passed!" in stdout,
    )
    run_bench("isa-tests", cleanup_isa_tests, isa_test_success_cond)
    run_bench("c-tests", cleanup_c_tests, c_test_success_cond)
    run_bench(
        f"vsim/uart_parse_tb.{waveform_suffix}",
        silent_remove_factory("uart_parse_tb", args.simulator),
        lambda stdout: "CSR test PASSED! Strings matched." in stdout,
    )
    run_bench(
        f"vsim/echo_tb.{waveform_suffix}",
        silent_remove_factory("echo_tb", args.simulator),
        lambda stdout: "Test passed!" in stdout,
    )
    run_bench(
        f"vsim/bios_tb.{waveform_suffix}",
        silent_remove_factory("bios_tb", args.simulator),
        lambda stdout: "BIOS testbench done! Num failed tests:          0" in stdout,
    )
    print("All tests passed!")


if __name__ == "__main__":
    main()
