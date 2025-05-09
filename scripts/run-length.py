# Python script to perform run-length encoding of DCW binary data
def rle_convert(input_filename: str, output_filename: str):
    """
    Reads a file with lines like 'DCW 0bXXXXXXXXYYYYYYYY', 
    extracts all bits, performs run-length encoding, and writes
    directives:
        DCW <count>
        DCW <bit>
    for each run.
    """
    bits = []
    with open(input_filename, 'r') as infile:
        for line in infile:
            line = line.strip()
            if not line.startswith("DCW"):
                continue
            # Extract binary string after '0b'
            if '0b' not in line:
                continue
            bin_part = line.split('0b', 1)[1]
            # Remove any non-binary suffix
            bin_str = ''.join(c for c in bin_part)
            if len(bin_str) != 16:
                raise ValueError(f"Unexpected bit length ({len(bin_str)}) in line: {line}")
            bits.extend(bin_str)

    # Run-length encode
    if not bits:
        return

    runs = []
    current_bit = bits[0]
    count = 1
    for b in bits[1:]:
        if b == current_bit:
            count += 1
        else:
            runs.append((current_bit, count))
            current_bit = b
            count = 1
    runs.append((current_bit, count))

    # Write output
    with open(output_filename, 'w') as outfile:
        for bit, cnt in runs:
            outfile.write(f'DCW {cnt}\n')
            outfile.write(f'DCW {bit}\n')

# Example usage:
rle_convert("snakecompressed.s", "snakecomp.s")
