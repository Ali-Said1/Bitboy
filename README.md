
<a id="readme-top"></a>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
    </li>
    <li><a href="#hardware">Hardware Components</a></li>
    <li><a href="#games">Games</a></li>
    <li><a href="#references">References</a></li>
    
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project


The BitBoy project is a custom-built handheld gaming console powered by the STM32F103C8T6 microcontroller. Designed to emulate the charm of retro gaming. It features a collection of classic games developed entirely in ARM assembly. The project showcases advanced programming techniques, efficient hardware utilization, and creative problem-solving to overcome the constraints of embedded systems.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<a id="hardware"></a>

## Main Hardware Components

* [STM32F103C8T6](https://www.st.com/en/microcontrollers-microprocessors/stm32f103c8.html)
* ST-Link V2 Programmer
* [LCD TFT 3.5 inch](https://www.ram-e-shop.com/shop/kit-lcd-tft3-5-touch-lcd-tft-3-5-inch-touch-display-for-arduino-uno-mega2560-7438)



<a id="games"></a>


<!-- Games -->
## Games

The BitBoy console includes a library of retro-style games, all developed in ARM assembly:
### Pong  
**Main Features and Challenges:**  
- Dynamic Ball Bounce Physics.
- Singleplayer and multiplayer mode.
- Efficient drawing to avoid LCD-TFT from flickering.
- Collision checks.


### Snake  
**Main Features and Challenges:**  
- Snake body Memory representation.


### Dino Game  
**Main Features and Challenges:**  
- Gravity Simulation using [Euler's method](https://en.wikipedia.org/wiki/Euler_method) for velocity and position updates.
- TFT drawing multiple moving objects.


### Maze Game  
**Main Features and Challenges:**  
- Recursive Backtracker in ARM assembly.
- Very limited stack size on the STM32F103 which lead us to use a custom-made more effiecient stack tailored for our use case.

### Aim Trainer  
**Main Features and Challenges:**  
- Joystick Configuration (**ADC**)
- Accurate crosshair velocity modeling using [Euler's method](https://en.wikipedia.org/wiki/Euler_method) position updates.

### Tic Tac Toe  
**Main Features and Challengess:**  
- Win detection for horizontal, vertical, or diagonal lines.

### Snake and Ladder Game (Not implemented on the TFT)
**Main Features and Challenges:**  
- Board memory representation.
- Implementing game logic for player movement across the board.


### Memory Game (Not implemented on the TFT)
**Main Features:**  
- Level progression as sequences grow longer.  

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<a id="simulation"></a>

<!-- References -->
## Simulation
In order to test and simulate each game without requiring the physical TFT, we developed several Python-based renderers. These renderers utilize Keil's debugger to extract the game's memory and effectively "simulate" a TFT display. This approach allowed us to validate the game's logic before deploying it to the actual hardware. It also simplified debugging, as software issues could be identified and resolved prior to involving hardware.

### Simulation Projects
The simulation projects can be found in the `SimulationProjects` directory within the repository. Each game has its own dedicated Python renderer, designed to replicate the behavior of the TFT.

### Setup
To run the simulation projects, follow these steps:
1. Ensure you have Python 3.9+ installed on your system.
2. Install the required dependencies by running:
    ```bash
    pip install pygame
    pip install win32gui
    pip install pywin32
    pip install PIL
    ```
3. Each keil project should have a .ini file which is used as an initialization file for keil's debug mode.
4. Inside Keil:
    - Make sure you installed the required package for STM32F103C8 from the Pack Installer (Keil::STM32F1xx_DFP)
    - Create a new project and make sure to only select `CMSIS => Core` in the software components when prompted by keil.
    - Inside the new project's settings, on the `Debug` tab change debug mode to `Use Simulator` , add the provided .ini file as the initialization file, and go to the `Linker` tab then uncheck the `Use Memory Layout from Target Dialog` box then clear the `scatter file` section.
5. Now, you can run the provided code in debug mode and use the function inside the .ini file to dump the memory.
6. Run the corresponding Python renderer for the game.
7. You should now see a pygame render of the game's memory.



<p align="right">(<a href="#readme-top">back to top</a>)</p>


<a id="references"></a>

<!-- References -->
## References

* [Wikipedia - Maze Generation using the Recursive Backtracker method](https://en.wikipedia.org/wiki/Maze_generation_algorithm#Recursive:~:text=exit%2C%20are%20removed.-,Randomized%20depth%2Dfirst%20search,-%5Bedit%5D)
* [JamisBuck - Maze Generation Algorithms](https://www.jamisbuck.org/presentations/rubyconf2011/index.html)
* [Wikipedia - Euler's method](https://en.wikipedia.org/wiki/Euler_method)
* [Reducible - Collisions](https://www.youtube.com/watch?v=eED4bSkYCB8&t=1075s)


<p align="right">(<a href="#readme-top">back to top</a>)</p>
