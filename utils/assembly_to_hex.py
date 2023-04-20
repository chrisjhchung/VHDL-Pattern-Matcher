import sys

instructions = {
    "load":    0b00001,
    "store":   0b00011,
    "add":     0b01000,
    "syscall": 0b01111,
    "loadi":   0b00010,
    "bne":     0b00101,
    "addi":    0b00110
}


class InstructionLine:
    def __init__(self, line_number: int, instruction_str: str):
        self.line_number = line_number
        self.instruction_str = instruction_str

    @property
    def instruction_str_list_unsafe(self) -> [str]:
        return self.instruction_str.split()

    @property
    def instruction_str_list(self) -> [str]:
        str_list = self.instruction_str_list_unsafe
        if len(str_list) != 4:
            print(f"ERROR! Invalid length of current instruction: {len(str_list)} != 4.\n{str(self)}\n")
            return None
        return str_list

    @property
    def instruction_type_str(self) -> str:
        return self.instruction_str_list[0]

    def is_empty(self) -> bool:
        return len(self.instruction_str) == 0

    def get_instruction_type_int(self) -> int:
        insn_type_str = self.instruction_type_str
        insn_code = instructions.get(insn_type_str)
        if insn_code is None:
            print(f"ERROR! Cannot find instruction '{insn_type_str}'.\n{str(self)}\n")
            return None
        return insn_code

    def get_instruction_tuple(self) -> (int, int, int, int):
        try:
            insn_int_list = list(map(int, self.instruction_str_list[1:]))
        except:
            print(f"ERROR! Cannot convert the string to integers.\n{str(self)}\n")
            return None

        insn_int_list.insert(0, self.get_instruction_type_int())

        if any(not (-16 <= num <= 31) for num in insn_int_list):
            print(f"ERROR! A decimal is not within the range -16..=31.\n{str(self)}\n")
            return None

        return insn_int_list

    def binary(self):
        bin_list = []
        for insn_entry in self.get_instruction_tuple():
            if insn_entry >= 0:
                bin_list.append(bin(insn_entry)[2:].zfill(5))
            else:
                binary = bin(insn_entry & 0b11111)[2:].zfill(5)
                bin_list.append(binary)

        return "".join(bin_list)

    def binary_pretty(self):
        return " ".join([self.binary()[i * 5:(i + 1) * 5] for i in range(4)])

    def hex(self):
        out_int = int(self.binary(), 2)
        return hex(out_int)[2:].zfill(5)

    def hex_str(self):
        return f"{self.hex()}\n"

    def code_str(self, instruction_index: int, with_comment: bool = True) -> str:
        pre_spacing = "                "
        code_str = ""
        if with_comment:
            code_str += f"{pre_spacing}-- {self.instruction_str}\n"
        code_str += f'{pre_spacing}var_insn_mem({instruction_index}) := X"{self.hex()}";\n'
        return code_str

    def __str__(self):
        return f"  Line {str(self.line_number).rjust(3, ' ')}:\t{self.instruction_str}"


def read_file(filename: str) -> [InstructionLine]:
    instruction_lines = []
    with open(filename, "r") as f:
        for i, line in enumerate(f):
            line_stripped = line.strip().lower()
            if not line_stripped:
                continue
            instruction_lines.append(InstructionLine(i, line_stripped))
    return instruction_lines


if __name__ == "__main__":
    filepath_src = None
    filepath_dst = None
    start_index = None

    if len(sys.argv) > 1:
        filepath_src = sys.argv[1]
    else:
        print("Missing source file path.")

    if len(sys.argv) > 2:
        filepath_dst = sys.argv[2]
    else:
        print("Missing destination file path.")

    if len(sys.argv) > 3:
        try:
            start_index = int(sys.argv[3])
        except:
            print("Illegal start_index entered. Please enter a positive number.")
            filepath_dst = None

    if filepath_src is None or filepath_dst is None:
        print("Usage: python assembly_to_hex.py <source> <destination> [Optional: start_index]\n")
        exit(1)

    insn_lines = read_file(filepath_src)

    try:
        with open(filepath_dst, "w") as f:
            for i, insn_line in enumerate(insn_lines):
                if start_index is None:
                    f.write(insn_line.hex_str())
                else:
                    f.write(insn_line.code_str(i + start_index))
    except:
        print("An error occurred")
        exit(1)
