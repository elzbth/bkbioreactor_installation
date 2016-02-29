/**
 * Elizabeth Henaff
 * elizabeth.m.henaff@gmail.com
 * projection mapping / interactive LED sketch for BK BioReactor installation at Site:Brooklyn, Feb 2016
 *
 * Usage: 
 * 'c' to enable config mode 
     drag the corners of the CornerPinSurface so that they
     match the physical surface's corners.
   'i' to initialize the position of the LED pixels. Will start sending data to Arduino when all are initialized
   'b' to set position of brightness switch at current mouse position
   'r' to reset the brightness switch to off mode
   '>' increase saturation of LEDs
   '<' decrease saturation of LEDs
 */

// for surface mapping
import deadpixel.keystone.*;
import processing.video.*;

// for arduino
import processing.serial.*;

// variables for surface mapping
Movie mapMovie;
Movie textMovie;

//for debug
PImage map_image;


// for mapping 
Keystone ks;
CornerPinSurface surface1;
CornerPinSurface surface2;

PGraphics offscreen1;
PGraphics offscreen2;

//coordinates of LED pixels
int num_LEDs = 6; // *************************************** TO CHANGE
int[] led_x = new int[num_LEDs];
int[] led_y = new int[num_LEDs];
int[] preset_x = {696, 847, 626, 415, 258, 101};
int[] preset_y = {310, 582, 397, 337, 389, 482};

boolean setupLEDs = false;
int led_counter = 0;
boolean save_LED_position = false;
boolean calibrate_mode = false;

color[] led_pixel_colors = new color[num_LEDs]; 
color pixel_color;
color sat_pixel_color;

float set_saturation = 200; // ***********************************
float brightness_adjust = 1.0;
boolean set_brightness_switch; 
int brightness_x = -1;
int brightness_y = -1;
int preset_brightness_x = 851;
int preset_brightness_y = 260;

int mapW = 1280;  // ***********************************
int mapH = 720;  // ***********************************

int textW = 1280;  // ***********************************
int textH = 720;  // ***********************************


// The serial port to send data to the Arduino:
Serial myPort;
char inByte = 'w';    // Incoming serial data


void setup() {
  // set up display size
  size(1280, 720, P3D);

  // set up surfaces 
  ks = new Keystone(this);
  surface1 = ks.createCornerPinSurface(mapW, mapH, 20);
  surface2 = ks.createCornerPinSurface(textW, textH, 20);

  // set up offscreen buffers to write to, which will then be rendered on the surfaces
  offscreen1 = createGraphics(mapW, mapH, P3D);
  offscreen2 = createGraphics(textW, textH, P3D);

  // open the movies for each surface
  mapMovie = new Movie(this, "canal7.mp4");
  mapMovie.loop();

  //for debug
  // map_image = loadImage("map.jpg");

  textMovie = new Movie(this, "map7.mp4");
  textMovie.loop();


  // setup serial port
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[2], 9600); 
  println("done opening port");

  delay(1000);

}

void draw() {
  
  // myPort.write("looping Processing\n");
  // delay(3000);


  // Convert the mouse coordinate into surface coordinates
  // this will allow you to use mouse events inside the 
  // surface from your screen. 
  //PVector surfaceMouse = surface1.getTransformedMouse();

  // Draw the map, offscreen
  offscreen1.beginDraw();
  // offscreen1.image(map_image, 0, 0);
  offscreen1.image(mapMovie, 0, 0);
  offscreen1.endDraw();

  //draw the text, offscreen
  offscreen2.beginDraw();
  offscreen2.image(textMovie, 0, 0);
  // colorMode(HSB);
  //   pushMatrix();
  //  translate(256,256);
  //  smooth();
  //  noStroke();
  //  saturationChanger(128,256);
  //  popMatrix();

  offscreen2.endDraw();

  // most likely, you'll want a black background to minimize
  // bleeding around your projection area
  background(0);
 
  // render the scene, transformed using the corner pin surface
  surface1.render(offscreen1);
  surface2.render(offscreen2);

  loadPixels();

  if(brightness_x > -1){
    pixel_color = pixels[brightness_y * width + brightness_x];
    float scaled_brightness = brightness(pixel_color) / 255.0;
    brightness_adjust = 1.0 - scaled_brightness;
    // println(brightness(pixel_color), brightness_adjust);
  }


  for(int i = 0; i < led_counter; i++){
       // pixel_color = get(led_x[i], led_y[i]);
       pixel_color = pixels[led_y[i] * width + led_x[i]];
       // colorMode(HSB);
       float h = hue(pixel_color);
       float s = saturation(pixel_color);
       float b = brightness(pixel_color);

       // println(h, s, b);

       colorMode(HSB);
      sat_pixel_color = color(h, set_saturation, b * brightness_adjust);
      led_pixel_colors[i] = sat_pixel_color;
      colorMode(RGB, 255, 255, 255);
    }

  if (setupLEDs || calibrate_mode) {

    //get pixel value at mouse and draw a circle there
    color c = get(mouseX, mouseY);
    fill(c);
    noStroke();
    ellipse(mouseX, mouseY, 50, 50);
    fill(0);
    text( "               " + str(red(c)) + ", " + str(green(c)) + ", " + str(blue(c)) + "          " , mouseX, mouseY);



    if (save_LED_position){
      if (led_counter > num_LEDs - 1){
        led_counter = 0;
      }
      led_x[led_counter] = mouseX;
      led_y[led_counter] = mouseY;
      println("LED", led_counter, led_x[led_counter], led_y[led_counter]);
      save_LED_position = false;
      led_counter += 1;
    }

    if (set_brightness_switch){
      
      brightness_x = mouseX;
      brightness_y = mouseY;
      println("brightness", brightness_x, brightness_y);
      set_brightness_switch = false;
    }


    // draw little circles with saturated color value around LED marks
    for(int i = 0; i < led_counter; i++){
      
      stroke(0);
      fill(pixels[led_y[i] * width + led_x[i]]);
      ellipse(led_x[i], led_y[i], 30, 30);
      fill(led_pixel_colors[i]);
      colorMode(RGB, 255, 255, 255);
      stroke(0);
      ellipse(led_x[i], led_y[i], 10, 10);
      textAlign(RIGHT);
      text(str(i), led_x[i], led_y[i]);
    }


  }



  // get pixel value at mouse position



  
  // color pixel_color;

  

  if(inByte == 'r' && led_counter == num_LEDs){
    for (int i = 0; i < led_counter; i++){
      // // pixel_color = get(led_x[i], led_y[i]);
      // pixel_color = pixels[led_y[i] * width + led_x[i]];
      // HERE SEND IT TO ARDUINO VIA SERIAL
      myPort.write( int( red(led_pixel_colors[i])) );
      myPort.write( int( green(led_pixel_colors[i])) );
      myPort.write( int( blue(led_pixel_colors[i])) );
      // println(pixel_color);
    }
    //write newline to serial to show that data is done being sent
    myPort.write("\n");
    // println("sent colors");
    inByte = 'w';
  }
  else{
    // println("loop no send colors");
  }

}


// Called every time a new frame is available to read
void movieEvent(Movie m) {

  m.read();
}

void serialEvent(Serial myPort) {
  inByte = char(myPort.read());
}


void keyPressed() {
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    calibrate_mode = !calibrate_mode;
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    led_x = preset_x;
    led_y = preset_y;
    brightness_x = preset_brightness_x;
    brightness_y = preset_brightness_y;
    //set_brightness_switch = true;
    led_counter = 6;
    
    break;

  case 's':
    // saves the layout
    ks.save();
    break;
  case 'i':
    //initialize LED postion
    save_LED_position = true;
    break;
  case '>':
    //increase saturation
    if(set_saturation <= 250){
      set_saturation += 5;
    }
    println("increment saturation: "+ set_saturation);
     break;
  case '<':
    //decrease saturation
    if (set_saturation >= 5){
      set_saturation -= 5;
    }
    println("decrement saturation: " + set_saturation);
    break;
    case 'b':
    //decrease saturation
    set_brightness_switch = true;
    println("brightness switch on");
    break;
    case 'r':
    //reset switch
    brightness_x = -1;
    brightness_y = -1;
    println("brightness switch off");
    break;
  }


}

///// for testing colors


void saturationChanger(int i, int initial){
 if(i > 0){
  colorTriangle(256,0,initial,initial);
  saturationChanger(i-1, initial-2);
 }
}
void colorTriangle(int iteration, int h, int s,int height){
 if(iteration > 0){
  fill(h%256,s,256);
  triangle(0,0,128*tan(radians(5.625/4)),height,-128*tan(radians(5.625/4)),height);
  rotate(radians(5.625/4));
  colorTriangle(iteration-1, h+1, s, height);
 }
}