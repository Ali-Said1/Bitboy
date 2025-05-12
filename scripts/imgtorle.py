# ACknowledgements: This file was created by Eng. Peter M. Ayad. TA at Fcaulty of Engineering, Cairo University.
from dataclasses import dataclass
from PIL import Image
import os
from collections import deque
import sys

@dataclass
class RLEObject:
    color:str
    count:int



def image_to_arm_asm(image_path, output_file):
    file_name = os.path.basename(image_path)
    var_name = os.path.splitext(file_name)[0]

    img = Image.open(image_path).convert("RGB")
    width, height = img.size

    # Convert image to RGB565 format (5 bits Red, 6 bits Green, 5 bits Blue)
    #  or BGR565 format (5 bits Blue, 6 bits Green, 5 bits Red)
    pixel_data = []
    for y in range(height):
        for x in range(width):
            r, g, b = img.getpixel((x, y))
            rgb565 = ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3)
            pixel_data.append(rgb565)
            

    runLengthList:list[RLEObject] = []

    for pixel in pixel_data:
        if len(runLengthList) == 0:
            runLengthList.append(RLEObject(color=pixel, count = 1))
            continue
        if runLengthList[-1].color == pixel:
            runLengthList[-1].count += 1
        else:
            runLengthList.append(RLEObject(color=pixel, count = 1))
    
    
    

    with open(output_file, "w") as f:
        f.write(f"    AREA MYIMAGE, DATA, READONLY\n")
        f.write(f"    EXPORT {var_name}\n\n")

        f.write(f"{var_name}\n")
        f.write(f"    DCW {len(runLengthList)}\n")
        f.write(f"    DCW {width}\n")
        f.write(f"    DCW {height}\n")  # Image width and height

        for i, colorRun in enumerate(runLengthList):
            f.write(f"    DCW {colorRun.count}, 0x{colorRun.color:04X}\n")
            

        f.write(f"\n    END\n")

    print(f"Assembly file {output_file} generated successfully.")


script_dir = os.path.dirname(os.path.abspath(__file__))


# Choose BGR or RGB depending on hardware
#  or just try both

# ADD DIRECTORY TO IMAGE HERE
image_to_arm_asm(image_path=os.path.join(script_dir, f'../assets/SnakeLadder.png'),
                 output_file=os.path.join(script_dir, "RLEOutput.s"))