def rle_sum(input_filename: str) -> int:
    # (Same parsing as before)
    bit_stream = []
    with open(input_filename, 'r') as infile:
        for line in infile:
            line = line.strip()
            if not line.startswith("DCW") or "0b" not in line:
                continue
            bin_str = ''.join(c for c in line.split('0b',1)[1])
            bit_stream.extend(bin_str)

    # Build runs
    runs = []
    current = bit_stream[0]
    count = 1
    for b in bit_stream[1:]:
        if b == current:
            count += 1
        else:
            runs.append(count)
            current = b
            count = 1
    print(count);
    runs.append(count)

    return sum(runs)


if __name__ == "__main__":
    total = rle_sum("snakecompressed.s")
    print("Total bits (sum of all DCW counts):", total)
