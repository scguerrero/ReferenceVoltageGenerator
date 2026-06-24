#include <SPI.h>

volatile byte receivedData = 0;
volatile bool dataReady = false;

// idx will be incremented to a max of 3 inside ISR and then reset to 0
int idx = 0;

// The Nano will alternate sending 3 bytes
// Receives 1st byte from Feather, back sends arr[0]
// Receives 2nd byte, sends arr[1]
// Receives 3rd byte, sends arr[2]
uint8_t arr[3] = {0x11, 0x05, 0x01};

// Pins
#define MISO 12
#define MOSI 11
#define SCK 13
#define SS 10

void setup() {
  Serial.begin(115200);

  // Set MISO (D12) as OUTPUT so the Nano can send data back if needed
  pinMode(MISO, OUTPUT);
  
  // Set MOSI (D11), SCK (D13), and SS (D10) as INPUTs (Automatic via hardware, but good practice)
  pinMode(MOSI, INPUT);
  pinMode(SCK, INPUT);
  pinMode(SS, INPUT);

  // Turn on SPI in Slave Mode by modifying the SPI Control Register (SPCR)
  SPCR |= _BV(SPE);

  // Respond to the Feather by sending 0xF1
  //SPDR = 0xF1; // preloading SPI Data Register

  // Turn on SPI interrupts so we don't miss data while doing other tasks
  SPI.attachInterrupt();
}

// SPI Interrupt Service Routine (ISR) - executes instantly when a byte is received
ISR(SPI_STC_vect) {  
  if (idx == 3) idx = 0; // reset idx to avoid out-of-bounds error
  SPDR = arr[idx];
  receivedData = SPDR; // Read the byte from the SPI Data Register
  dataReady = true; // Set flag to process it in the main loop
  idx++;
  delay(1000);
}

void loop() {

  // Send bytes to the Feather
  // End loop when 3 bytes have been entered
  // for (int i=0; i<3; i++) {
  //   String hexStr = Serial.readStringUntil('\n');
  //   uint8_t value = (uint8_t)strtoul(hexStr.c_str(), NULL, 16);
  //   arr[i] = value;
  // }

  // Check if a new byte has arrived
  if (dataReady) {
    Serial.print("Received from Feather: 0x");
    Serial.println(receivedData, HEX);

    dataReady = false;  // Reset the flag
  }
}

