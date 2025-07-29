# Verilog Alarm Clock
This project implements a digital clock with alarm functionality. The clock displays the current time, and the user can set the alarm time. When the alarm time matches the current time, an alarm is triggered, and a light is turned on. The alarm is sensitive to motion. It turns off as soon as motion is detected. The clock has functionality for displaying the weather (sunny, cloudy, rainy, stormy) in one character format.

## Files

The project consists of the following files:

1. `alarm.v`: This file contains the logic for the alarm module. It controls the alarm functionality based on the current time and the user-defined alarm time.

2. `counter2.v`: This file contains the logic for the counter module. It increments the time counters for seconds, minutes, and hours.

3. `light.v`: This file contains the logic for the light module. It controls the state of the light based on the alarm trigger.

4. `main.v`: This file contains the main module of the digital clock. It instantiates the counter, alarm, light, weather and motion modules and connects them together.

5. `memory.v`: This file contains the memory module that defines addr and data relation and gives the user option to control the current time and alarm time using these signals.

6. `motion.v`: This file contains the logic for the motion detection module. It detects motion and triggers an event to enable/disable the alarm functionality.

7. `weather.v`: This file contains the logic for the weather module. It retrieves weather information and updates the display accordingly.

8. `test2.sv`: This file is the SystemVerilog test bench for the digital clock. It instantiates the main module and provides stimulus to test the functionality of the clock.

## Running the Project

To run and simulate the project using Xcelium simulator, follow these steps:

1. Install Xcelium simulator on your system if it is not already installed.

2. Open a terminal and navigate to the project directory.

3. Compile the source files using the following command:

   <pre>xrun test2.sv main.v alarm.v weather.v light.v counter2.v motion.v memory.v</pre>

4. Run the simulation using the following command:
   
   <pre>xrun test2.sv main.v alarm.v weather.v light.v counter2.v motion.v memory.v -clean -gui -access +rwc</pre>

5. Observe the simulation output to verify the functionality of the digital clock.

Feel free to modify the test bench or any of the source files to customize the behavior of the clock or add additional features.
