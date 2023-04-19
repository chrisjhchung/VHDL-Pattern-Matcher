def insn_16_to_20(in_hex: str):
    in_int = int(in_hex, 16)
    in_bin = bin(in_int)[2:].zfill(16)
    bin_list = list(in_bin)
    insn_values = 4
    for i in range(insn_values):
        bin_list.insert(i * 5, "0")
    out_bin = "".join(bin_list).zfill(20)
    out_int = int(out_bin, 2)
    out_hex = hex(out_int)[2:].zfill(5)
    return out_hex, " ".join([out_bin[i*5:(i+1)*5] for i in range(insn_values)])


if __name__ == "__main__":
    in_hex = None
    while (in_hex != ""):
        in_hex = input("In hex:  ")
        out_hex, out_bin = insn_16_to_20(in_hex)
        print(f"Out hex: {out_hex}")
        print(f"Out bin: {out_bin}\n")
