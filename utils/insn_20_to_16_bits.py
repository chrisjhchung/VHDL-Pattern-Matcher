def insn_20_to_16(in_hex: str):
    in_int = int(in_hex, 16)
    in_bin = bin(in_int)[2:].zfill(20)
    bin_list = list(in_bin)
    insn_values = 4
    for i in range(insn_values):
        popped_item = bin_list.pop(i * 4)
        if popped_item != "0":
            print(f"WARNING! Removed non-zero binary from part {i} at binary index {i * 4}")
    out_bin = "".join(bin_list).zfill(16)
    out_int = int(out_bin, 2)
    out_hex = hex(out_int)[2:].zfill(4)
    return out_hex, " ".join([out_bin[i*4:(i+1)*4] for i in range(insn_values)])


if __name__ == "__main__":
    in_hex = None
    while (in_hex != ""):
        in_hex = input("In hex:  ")
        out_hex, out_bin = insn_20_to_16(in_hex)
        print(f"Out hex: {out_hex}")
        print(f"Out bin: {out_bin}\n")