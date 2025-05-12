import pygame
import win32gui
import win32con

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
        return "0000"


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

file_path = "./memdump.bin"  # Replace with the path to your .bin file


pygame.init()
screen = pygame.display.set_mode((480, 320))
pygame.display.set_caption("Snake Visualizer")

memory = parse_hex386(file_path)
print(memory)

DINO_X = decode_word(join_dict_values_in_range(memory, 2, 3))
DINO_Y = decode_word(join_dict_values_in_range(memory, 4, 5))
DINO_W = decode_word(join_dict_values_in_range(memory, 6, 7))
DINO_H = decode_word(join_dict_values_in_range(memory, 8, 9))

OBJ1_ACTIVE = decode_byte(memory.get(17, "00"))
OBJ1_X = decode_word(join_dict_values_in_range(memory, 18, 19))
OBJ1_Y = decode_word(join_dict_values_in_range(memory, 20, 21))
OBJ1_W = decode_word(join_dict_values_in_range(memory, 22, 23))
OBJ1_H = decode_word(join_dict_values_in_range(memory, 24, 25))


OBJ2_ACTIVE = decode_byte(memory.get(27, "00"))
OBJ2_X = decode_word(join_dict_values_in_range(memory, 28, 29))
OBJ2_Y = decode_word(join_dict_values_in_range(memory, 30, 31))
OBJ2_W = decode_word(join_dict_values_in_range(memory, 32, 33))
OBJ2_H = decode_word(join_dict_values_in_range(memory, 34, 35))


OBJ3_ACTIVE = decode_byte(memory.get(37, "00"))
OBJ3_X = decode_word(join_dict_values_in_range(memory, 38, 39))
OBJ3_Y = decode_word(join_dict_values_in_range(memory, 40, 41))
OBJ3_W = decode_word(join_dict_values_in_range(memory, 42, 43))
OBJ3_H = decode_word(join_dict_values_in_range(memory, 44, 45))

clock = pygame.time.Clock()
running = True
hwnd = win32gui.GetForegroundWindow()

win32gui.SetWindowPos(hwnd, win32con.HWND_TOPMOST, 100, 100, 0, 0, win32con.SWP_NOSIZE)
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    screen.fill((0, 0, 0))
    try:
        memory = parse_hex386(file_path)

        DINO_X = decode_word(join_dict_values_in_range(memory, 2, 3))
        DINO_Y = decode_word(join_dict_values_in_range(memory, 4, 5))
        DINO_W = decode_word(join_dict_values_in_range(memory, 6, 7))
        DINO_H = decode_word(join_dict_values_in_range(memory, 8, 9))

        # Check if OBJ1 is active and render
        OBJ1_ACTIVE = decode_byte(memory.get(17, "00"))
        if OBJ1_ACTIVE:
            OBJ1_X = decode_word(join_dict_values_in_range(memory, 18, 19))
            OBJ1_Y = decode_word(join_dict_values_in_range(memory, 20, 21))
            OBJ1_W = decode_word(join_dict_values_in_range(memory, 22, 23))
            # print(join_dict_values_in_range(memory, 22, 23))
            OBJ1_H = decode_word(join_dict_values_in_range(memory, 24, 25))
            pygame.draw.rect(screen, (255, 0, 0), (OBJ1_X, OBJ1_Y, OBJ1_W, OBJ1_H))

        # Check if OBJ2 is active and render
        OBJ2_ACTIVE = decode_byte(memory.get(27, "00"))
        if OBJ2_ACTIVE:
            OBJ2_X = decode_word(join_dict_values_in_range(memory, 28, 29))
            OBJ2_Y = decode_word(join_dict_values_in_range(memory, 30, 31))
            OBJ2_W = decode_word(join_dict_values_in_range(memory, 32, 33))
            OBJ2_H = decode_word(join_dict_values_in_range(memory, 34, 35))
            pygame.draw.rect(screen, (0, 255, 0), (OBJ2_X, OBJ2_Y, OBJ2_W, OBJ2_H))

        # Check if OBJ3 is active and render
        OBJ3_ACTIVE = decode_byte(memory.get(37, "00"))
        if OBJ3_ACTIVE:
            OBJ3_X = decode_word(join_dict_values_in_range(memory, 38, 39))
            OBJ3_Y = decode_word(join_dict_values_in_range(memory, 40, 41))
            OBJ3_W = decode_word(join_dict_values_in_range(memory, 42, 43))
            OBJ3_H = decode_word(join_dict_values_in_range(memory, 44, 45))
            pygame.draw.rect(screen, (0, 0, 255), (OBJ3_X, OBJ3_Y, OBJ3_W, OBJ3_H))
        
        # Draw the rectangle representing the dino
        pygame.draw.rect(screen, (255, 255, 255), (DINO_X, DINO_Y, DINO_W, DINO_H))
    except Exception as e:
        print(f"Error during rendering: {e}")

    

    pygame.display.flip()
    clock.tick(30)

pygame.quit()


