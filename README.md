# Reference Voltage Generator
- [Initiating Serial Communication](#initiating-serial-communication)
- [Entering Voltage Values](#entering-voltage-values)
- [SPI Communication](#spi-communication)
- [How to Clone the Repository](#how-to-clone-the-repository)
- [How to Run the GUI on Windows](#how-to-run-the-gui-on-windows)
- [How to Compile Natively on Linux](#how-to-compile-natively-on-linux)
- [How to Cross-Compile on Linux](#how-to-cross-compile-on-linux)
- [How to Upload Sketch to Adafruit Feather](#how-to-upload-sketch-to-adafruit-feather)
- [How to Upload Sketch to Arduino Nano](#how-to-upload-sketch-to-arduino-nano)

Reference Voltage Generator is a set of programs in which a user can enter voltage values to a graphical user interface (GUI) and a microcontroller responds to GUI events by sending those voltage values to digital-to-analog converters (DACs). The GUI application in Figure 1 was developed on Linux in C using GTK4. It can be cross-compiled to Windows using Linux as the host machine. The precompiled Windows executable is also available. The GUI was designed to communicate with an Adafruit Feather ESP32-S3 Reverse TFT. The Feather application parses commands received from the GUI and determines if the command intends to send a voltage value to one of the DACs via I2C, or if the command is meant to send bytes to another microcontroller via SPI.

![Graphical user interface](images/figure1.png)
*Figure 1. Graphical user interface.*

## Initiating Serial Communication
[Jump to Top](#reference-voltage-generator)

![Dropdown menus for COM port, baud rate, and initiating connection](images/figure2.png)
*Figure 2. Dropdown menus for COM port, baud rate, and initiating connection.*

The user begins by selecting a serial communication port from the COM Port dropdown menu in Figure 2. The listed ports are COM1–8, USB0–1, and ACM0. Users on Windows operating systems should select from COM1–8. Users on other operating systems should select from USB0–1 or ACM0. Command-line utilities such as lsusb on Linux may help the user figure out which serial communication ports are available on their computer and which particular port their target device (e.g. a microcontroller) is connected to.

The user can also select a baud rate from the next dropdown menu. Available baud rates are 1200, 2400, 4800, 9600,19200, 38400, 57600, 115200, 230400, 460800, and 921600. The user should select the appropriate baud rate for their target device by reading their device’s datasheet.

After the user selects a COM Port and Baud Rate and clicks the Connect button, the application will attempt to connect to the target device with the selected settings. The user should troubleshoot by verifying that their COM Port and Baud Rate selections are correct, disconnecting and reconnecting their device to the port, and checking if their cable is “charge-only.” A cable designed only for charging battery is not the same as a cable meant for data transfer, which is the type of cable required for serial communication.

## Entering Voltage Values
[Jump to Top](#reference-voltage-generator)

The user can enter values for twelve channels, numbered Channels 0–11. Figure 3 shows Channels 0–1. The user can enter voltage values within the range of 0.0000 to 5.0000 volts. If the user tries to enter an out-of-bounds value, it will automatically be clamped within range. A value of –1 will be forced to 0 and a value of 5.9999 will be forced to 5.0000. The value can be increased or decreased by 100 microvolts at a time by clicking the Arrow-Up and Arrow-Down buttons next to the corresponding voltage entry.

![Channels 0-1](images/figure3.png)
*Figure 3. Channels 0-1.*

Figure 3 also shows ON/OFF and UPDATE buttons. The ON/OFF button is a two-state toggle that begins in state OFF. When the OFF state is toggled, the application sends a command to power off the corresponding DAC (e.g. Toggling Channel 0 OFF will power off DAC 0). When UPDATE is clicked, the application sends a command to the Feather containing the DAC number and voltage value, and the Feather applies the voltage value to the right DAC. When the ON state is toggled, the application sends a command to power on the same DAC with the last voltage value that was written to it.

![All OFF/ON/UPDATE buttons below Channel 11](images/figure4.png)
*Figure 4. All OFF/ON/UPDATE buttons below Channel 11.*

In Figure 4, below Channel 11, there are three buttons, All OFF, All ON, and All UPDATE. The first toggles the OFF state for each ON/OFF button and the second toggles the ON state. The application sends one command at a time to power off each DAC, starting from DAC 0.

## SPI Communication
[Jump to Top](#reference-voltage-generator)

In Figure 5, the user can enter three bytes of data in hexadecimal format. They can choose to send the first byte, the first and second byte, or all three bytes. The application was tested to send user-inputted bytes through the Feather to an Arduino Nano via SPI. It was also tested to receive bytes from the Nano, through the Feather, and display the received bytes on the application window. The text will read “Nothing received” until bytes arrive at the Feather’s serial port from the Nano.

![SPI section of the GUI where the user can send bytes and view received bytes](images/figure5.png)
*Figure 5. SPI section of the GUI where the user can send bytes and view received bytes.*

### How to Clone the Repository
[Jump to Top](#reference-voltage-generator)

### How to Run the GUI on Windows
[Jump to Top](#reference-voltage-generator)

### How to Compile Natively on Linux
[Jump to Top](#reference-voltage-generator)

### How to Cross-Compile on Linux
[Jump to Top](#reference-voltage-generator)

### How to Upload Sketch to Adafruit Feather
[Jump to Top](#reference-voltage-generator)

### How to Upload Sketch to Arduino Nano
[Jump to Top](#reference-voltage-generator)



