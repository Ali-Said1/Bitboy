

r, g, b = 0xB7, 0xB1, 0xF2

rgb565 = ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3)
print(f"RGB565: 0x{rgb565:04X}")