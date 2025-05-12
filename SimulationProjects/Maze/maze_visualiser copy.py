import pygame
from PIL import Image, ImageDraw
import random

from collections import deque

# BS game_loop, 1, "SAVE memdump.bin r0,r1+2; _sleep_(1000/30)"
def decode_byte(byte_str):
    """
    Converts a two-character hex string (byte) to its decimal value.
    
    Args:
        byte_str (str): A two-character hex string (e.g., "1A").
    
    Returns:
        int: The decimal representation of the byte, or None if invalid.
    """
    try:
        if len(byte_str) != 2:
            raise ValueError("Input must be a two-character hex string representing a byte.")
        return int(byte_str, 16)
    except Exception as e:
        # print("Error decoding byte:", e)
        return None

def decode_word(word_str):
    """
    Converts a four-character hex string (word) to its decimal value.
    
    Args:
        word_str (str): A four-character hex string (e.g., "1A2B") representing a word.
    
    Returns:
        int: The decimal representation of the word, or None if invalid.
    """
    try:
        if len(word_str) != 4:
            raise ValueError("Input must be a four-character hex string representing a word.")
        return int(word_str, 16)
    except Exception as e:
        # print("Error decoding word:", e)
        return None


def parse_hex386(file_path):
    memory_dict = {}  # Dictionary to store memory address -> byte mappings
    try:
        with open(file_path, 'r') as hex_file:
            for line in hex_file:
                if not line.startswith(':'):
                    continue  # Skip invalid lines
                
                # Parse fields
                byte_count = int(line[1:3], 16)
                address = int(line[3:7], 16)
                record_type = int(line[7:9], 16)
                data = line[9:9 + byte_count * 2]
                
                # Process data records
                if record_type == 0x00:  # Data record
                    # Split data into bytes and reverse
                    bytes_list = [data[i:i + 2] for i in range(0, len(data), 2)]
                    # bytes_list.reverse()
                    
                    # Assign each byte to its memory address in the dictionary
                    for i, byte in enumerate(bytes_list):
                        memory_address = address + i
                        memory_dict[memory_address] = byte
                
                    
        return memory_dict
    
    except FileNotFoundError:
        print(f"File not found: {file_path}")
        return {}
    except Exception as e:
        print(f"Error reading HEX file: {e}")
        return {}


def join_dict_values_in_range(memory_dict, start_addr, end_addr):
    """
    Joins the values of a dictionary for keys within a specified range.
    
    Args:
        memory_dict (dict): Dictionary with integer keys (memory addresses) and
                           string values (two-character hex bytes, e.g., '1A').
        start_addr (int): Starting address of the range (inclusive).
        end_addr (int): Ending address of the range (inclusive).
    
    Returns:
        str: Concatenated string of values for keys in the range [start_addr, end_addr],
             in order of increasing keys. Returns empty string if no keys in range.
    """
    # Ensure start_addr <= end_addr
    if start_addr > end_addr:
        return ""
    
    # Get all keys in the dictionary within the range
    keys_in_range = sorted([k for k in memory_dict.keys() if start_addr <= k <= end_addr])
    keys_in_range.reverse()
    # Join the values for those keys
    return "".join(memory_dict[k] for k in (keys_in_range))

def decode_rgb565(rgb565_hex):
    """
    Converts a 4-character hex string representing an RGB565 color to an (r, g, b) tuple.
    Each component is scaled to the range 0-255.
    
    Args:
        rgb565_hex (str): A 4-character hex string (e.g., "1A2B").
    
    Returns:
        tuple: (r, g, b) where r, g, b are integers in the range 0-255, or None if invalid.
    """
    try:
        if len(rgb565_hex) != 4:
            raise ValueError("Input must be a 4-character hex string for RGB565.")
        value = int(rgb565_hex, 16)
        r = (value >> 11) & 0x1F  # 5 bits for red
        g = (value >> 5) & 0x3F   # 6 bits for green
        b = value & 0x1F          # 5 bits for blue

        # Scale the 5-bit and 6-bit values to 8 bits (0-255)
        r = round(r * 255 / 31)
        g = round(g * 255 / 63)
        b = round(b * 255 / 31)

        return (r, g, b)
    except Exception as e:
        # print("Error decoding RGB565:", e)
        return None


# Example usage
file_path = "./memdump.bin"  # Replace with the path to your .bin file
memory = parse_hex386(file_path)
print(memory)
cell_size = 10  # 3.5 inches width ≈ 336 pixels (assuming 96 DPI), 336/37 ≈ 9.1 → 9 pixels per cell
running = True

pygame.init()
screen = pygame.display.set_mode((37 * cell_size, 31 * cell_size))
pygame.display.set_caption("Maze Visualiser")
clock = pygame.time.Clock()

while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
            running = False

    # Each frame, parse the file again to update the memory and maze.
    memory = parse_hex386(file_path)
    maze = []
    for i in range(31):
        row = []
        for j in range(37):
            # Get the hex value from memory in a safe way.
            hex_val = memory.get(i * 37 + j, "00")
            # Use full hex value if it has two characters; otherwise take first char.
            
            row.append(hex_val)
            
        maze.append(row)
    
    # Solve maze from start (1,1) to end (35,29)
    # solution = solve_maze(maze, (1, 1), (35, 29))
    
    screen.fill((255, 255, 255))
    # Draw maze cells.
    for y, row in enumerate(maze):
        for x, cell in enumerate(row):
            if cell == "01":
                rect = pygame.Rect(x * cell_size, y * cell_size, cell_size, cell_size)
                pygame.draw.rect(screen, (0, 0, 0), rect)
            elif cell == "02":
                rect = pygame.Rect(x * cell_size, y * cell_size, cell_size, cell_size)
                pygame.draw.rect(screen, (0, 0, 255), rect)
            elif cell == "11":
                rect = pygame.Rect(x * cell_size, y * cell_size, cell_size, cell_size)
                pygame.draw.rect(screen, (255, 0, 0), rect)
    
    # Draw the solution path in green.
    # for (x, y) in solution:
    #     rect = pygame.Rect(x * cell_size, y * cell_size, cell_size, cell_size)
    #     pygame.draw.rect(screen, (0, 255, 0), rect)
    pygame.display.flip()
    clock.tick(30)

pygame.quit()




# maze = ["1" * 40 for _ in range(30)]
# def generate_maze():
#     global maze
#     rows = len(maze)
#     cols = len(maze[0]) if rows > 0 else 0
#     grid = [list(row) for row in maze]

#     def in_bounds(r, c):
#         return 0 <= r < rows and 0 <= c < cols

#     def dfs(r, c):
#         directions = [(2, 0), (-2, 0), (0, 2), (0, -2)]
#         random.shuffle(directions)
#         for dr, dc in directions:
#             nr, nc = r + dr, c + dc
#             if in_bounds(nr, nc) and grid[nr][nc] == "1":
#                 # Remove wall between cells
#                 grid[r + dr // 2][c + dc // 2] = "0"
#                 grid[nr][nc] = "0"
#                 dfs(nr, nc)

#     # Start DFS from an odd-indexed cell (adjust if necessary)
#     grid[1][1] = "0"
#     dfs(1, 1)
#     maze = [''.join(row) for row in grid]

# generate_maze()
