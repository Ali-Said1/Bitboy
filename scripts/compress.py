# Python script to convert DCW lines of 8-bit values into 16-bit binary DCW lines

def convert_dcw_file(input_filename: str, output_filename: str):
    # Read and clean lines
    with open(input_filename, 'r') as infile:
        raw_lines = [line.strip() for line in infile if line.strip()]

    # Extract 8-bit strings from each DCW line
    bit_lines = []
    for line in raw_lines:
        if not line.startswith("DCW"):
            continue
        # Remove 'DCW' and split the eight values
        parts = line[len("DCW"):].split(',')
        if len(parts) != 8:
            raise ValueError(f"Line does not contain 8 values: {line}")
        # Convert each part to a single bit
        bits = ''.join(part.strip() for part in parts)
        if len(bits) != 8:
            raise ValueError(f"Parsed bits not length 8: {bits}")
        bit_lines.append(bits)

    # Ensure an even number of lines for pairing
    if len(bit_lines) % 2 != 0:
        raise ValueError("Input contains an odd number of 8-bit DCW lines.")

    # Write paired lines as 16-bit binary DCW directives
    with open(output_filename, 'w') as outfile:
        for i in range(0, len(bit_lines), 2):
            first, second = bit_lines[i], bit_lines[i+1]
            outfile.write(f"DCW 0b{first}{second}\n")

# Example usage:
convert_dcw_file("snaketoconv.s", "snakecompressed.s")

