// NeoPixel Ring simple sketch (c) 2013 Shae Erisson
// released under the GPLv3 license to match the rest of the AdaFruit NeoPixel library

#include <Adafruit_NeoPixel.h>
#ifdef __AVR__
  #include <avr/power.h>
#endif

// Which pin on the Arduino is connected to the NeoPixels?
#define PIN            6

// How many NeoPixels are attached to the Arduino?
#define NUMPIXELS      6


// When we setup the NeoPixel library, we tell it how many pixels, and which pin to use to send signals.
// Note that for older NeoPixel strips you might need to change the third parameter--see the strandtest
// example for more information on possible values.
Adafruit_NeoPixel pixels = Adafruit_NeoPixel(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);

int delayval = 500; // delay for half a second

//store whether 3 bytes: R, G and B have been received
boolean receiveComplete = false;
 
char inChar = 'e';

//array to store the RGB values received over serial 
byte rgb_vals[] = {0,255,0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255, 0};
//index to that array
int index = 0;

void setup() {

  Serial.begin(9600);
  Serial.println("setup Arduino");
  pixels.begin(); // This initializes the NeoPixel library.
  // send ready signal to Processing
  Serial.print('r');
  pixels.clear();
  pixels.show();
  
}

void loop() {

    if (receiveComplete) {
//        receiveComplete = false;


          pixels.setPixelColor(0, pixels.Color(rgb_vals[0], rgb_vals[1], rgb_vals[2])); //input
          pixels.setPixelColor(1, pixels.Color(rgb_vals[3], rgb_vals[4], rgb_vals[5])); //input
          pixels.setPixelColor(2, pixels.Color(rgb_vals[6], rgb_vals[7], rgb_vals[8])); //input
          pixels.setPixelColor(3, pixels.Color(rgb_vals[9], rgb_vals[10], rgb_vals[11])); //input
          pixels.setPixelColor(4, pixels.Color(rgb_vals[12], rgb_vals[13], rgb_vals[14])); //input
          pixels.setPixelColor(5, pixels.Color(rgb_vals[15], rgb_vals[16], rgb_vals[17])); //input
          
//          pixels.setPixelColor(0, pixels.Color(70,116,80)); //green
//          pixels.setPixelColor(1, pixels.Color(15,119,40)); //green

//          pixels.setPixelColor(0, pixels.Color(243,12,205)); //pink
//          pixels.setPixelColor(1, pixels.Color(243,12,205)); //pink
//          pixels.setPixelColor(2, pixels.Color(243,12,205)); //pink
//          pixels.setPixelColor(3, pixels.Color(243,12,205)); //pink
//          pixels.setPixelColor(4, pixels.Color(243,12,205)); //pink
//          pixels.setPixelColor(5, pixels.Color(243,12,205)); //pink
        
        
      
        pixels.show(); // This sends the updated pixel color to the hardware.
        delay(20);
        receiveComplete = false;
        Serial.print('r');
    }
    
//    else{
//      pixels.clear();
//      pixels.show();
//    }
//    delay(500);
        

    

  
}

void serialEvent() {
    while (Serial.available()) {
        // get the new byte:
        inChar = Serial.read();
        
        // add it to the inputString:
        rgb_vals[index] = inChar;
        index++;
        
        // if the incoming character is a newline, set a flag
        // so the main loop can do something about it:
        if (inChar == '\n') {
          receiveComplete = true;
          // resent index of byte array so that it starts over next time data is received
          index = 0;
        }
  //      stringComplete = true;
    }
}



