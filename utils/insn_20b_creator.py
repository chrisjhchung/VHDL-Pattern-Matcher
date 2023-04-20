def insn_str_to_tup(insn_str: str) -> (int, int, int, int):
    insn_str_split = insn_str.strip().split(" ")
    if len(insn_str_split) != 4:
        print(f"ERROR! Decimal count differs: {len(insn_str_split)} != {4}")
        return None

    try:
        insn_int_list = tuple(map(int, insn_str_split))
    except:
        print("ERROR! Cannot convert the string to integers")
        return None

    if any(not (-16 <= num <= 31) for num in insn_int_list):
        print("ERROR! A decimal is not within the range -16..=31")
        return None

    return insn_int_list


def insn_20b_creator(instructions: (int, int, int, int)) -> (str, str):
    bin_list = []
    for insn_entry in instructions:
        if insn_entry >= 0:
            bin_list.append(bin(insn_entry)[2:].zfill(5))
        else:
            binary = bin(insn_entry & 0b11111)[2:].zfill(5)
            bin_list.append(binary)

    insn_bin = "".join(bin_list)
    insn_values = 4
    out_int = int(insn_bin, 2)
    out_hex = hex(out_int)[2:].zfill(5)
    return out_hex, " ".join([insn_bin[i*5:(i+1)*5] for i in range(insn_values)])


if __name__ == "__main__":
    in_hex = None
    print("Insert instruction using decimals (-16 - 31), in the following format:\n\tFormat:  insn a1 a2 a3\n\tExample: 26 2 12 -2\n")
    while (in_hex != ""):
        insn_str = input("Instruction: ")
        insn_tup = insn_str_to_tup(insn_str)
        if insn_tup is None:
            print()
            continue
        out_hex, out_bin = insn_20b_creator(insn_tup)
        print(f"Out hex: {out_hex}")
        print(f"Out bin: {out_bin}\n")
