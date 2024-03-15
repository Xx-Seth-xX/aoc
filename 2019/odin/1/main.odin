package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

main :: proc() {

    filename := "input.txt"
    data, ok := os.read_entire_file(filename)
    if !ok {
        panic("Failed to read file")
    }
    s1 := first_problem(data)
    s2 := second_problem(data)
    fmt.printf("Solution to 1: %i\n", s1)
    fmt.printf("Solution to 2: %i\n", s2)
}

first_problem :: proc(data: []byte) -> int {
    it := string(data)
    sum : int = 0

    for line in strings.split_lines_iterator(&it) {
        num, ok := strconv.parse_int(line)
        if !ok {
            fmt.printf("Error parsing `%s` as number\n", line)
            os.exit(1)
        }
        sum += num / 3 - 2
    }
    return sum
}
second_problem :: proc(data: []byte) -> int {
    it := string(data)
    sum : int = 0
    for line in strings.split_lines_iterator(&it) {
        num, ok := strconv.parse_int(line)
        if !ok {
            fmt.printf("Error parsing `%s` as number\n", line)
            os.exit(1)
        }
        num = num / 3 - 2
        for num > 0 {
            sum += num
            num = num / 3 - 2
        }
    }
    return sum
}
