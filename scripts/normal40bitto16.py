

r, g, b = 0x32, 0x8E, 0x6E

rgb565 = ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3)
print(f"RGB565: 0x{rgb565:04X}")