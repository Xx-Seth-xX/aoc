package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:os"
import "core:slice"

main :: proc() {
    filename := "input.txt"
    raw_data, ok := os.read_entire_file_from_filename(filename)
    defer delete(raw_data)
    if !ok {
        panic("Error reading input file")
    }
    it := string(raw_data)

    data := make([dynamic]int)
    defer delete(data)

    for n in strings.split_by_byte_iterator(&it, ',') {
        n := strings.trim_space(n)
        num, ok := strconv.parse_int(n)
        if !ok {
            fmt.printf("Error trying to parse `%s` as number.\n", n)
            os.exit(1)
        }
        append(&data, num)    
    }
    s1 := solve1(data[:])
    fmt.printf("Solution to 1: %i\n", s1)
    s2 := solve2(data[:])
    fmt.printf("Solution to 2: %i\n", s2)
}

execute_program :: proc(program: []int, noun: int, verb: int) -> int {
    program := slice.clone(program)
    defer delete(program)
    program[1] = noun
    program[2] = verb
    // fmt.printf("len(program) = %i \n", len(program))

    loop: for i := 0; i < len(program); i += 4 {
        // fmt.printf("%i: %i\n", i, program[i])
        x   := program[i+1]
        y   := program[i+2]
        dst := program[i+3]
        switch program[i] {
            // Halt
            case 99: break loop
            // Add src1, src2, dst
            case 1: program[dst] = program[x] + program[y] 
            // Mul src1, src2, dst
            case 2: program[dst] = program[x] * program[y] 
            case: {
                fmt.printf("Invalid opcode %i\n", program[i])
            }
        }
    } 
    return program[0]
}

solve1 :: proc(data: []int) -> int {
    return execute_program(data, 12, 2)
}

solve2 :: proc(data: []int) -> int {
    expected_output := 19690720
    noun : int
    verb : int
    success := false

    loop: for noun = 0; noun <= 99; noun += 1 {
        for verb = 0; verb <= 99; verb += 1 {
            output := execute_program(data, noun, verb)
            // fmt.printf("noun = %i, verb = %i: %i\n", noun, verb, output)
            if output == expected_output {
                success = true
                break loop
            }
        }
    }
    if success {
        return noun * 100 + verb
    } else {
        return -1
    }
}


