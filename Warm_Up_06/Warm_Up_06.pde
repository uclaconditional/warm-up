//

int secondsBetweenCaptures = 20;  //60 // Seconds between image captures
int countTickTock = 5;  //50 // Starts to speak "tick, tock" at this second
int nextGroup = 12; // Number of captures before the group changes
int imageCountStart = 0;  // Keep the images in order, # after the time stamp
boolean saveFrames = true;
boolean loadPriorFrames = false;
int totalFrames = 120;

int FAST = 1;
int SLOW = 2;
int mode = SLOW; // FAST is 30 fps, SLOW is 1 fps

String s1 = "image acquired. ";
String s2 = s1 + "next group... that was your final count down... quickly! there's not much time.";

// TODO: 
// x Thread for saving the file
// x Array for loading the images into the timelapse
// Check for last "totalFrames" images on start up and seed the array

boolean useThread = true;

import codeanticode.syphon.*;
import java.util.*;

PGraphics canvas;
SyphonClient client;

int voiceIndex = 0;
int voiceSpeed = 200;

int count = 0;

int lastSecond = 0;

PImage[] captures;
PImage currentImage;

int masterCount = 0;  // Count every image taken since the software started

int currentCapture = 0;
int displayCapture = 0;



public void setup() {
  fullScreen(P2D);
  //size(1920, 1080, P2D);
  
  String path = sketchPath() + "/captures";
  //String path = sketchPath() + "/captures_few";

  println("Listing all filenames in a directory: ");
  String[] filenames = listFileNames(path);
  printArray(filenames);

  captures = new PImage[totalFrames];
  
  if (loadPriorFrames == true) {
    if (filenames.length < totalFrames) {
      for (int i = 0; i < filenames.length; i++) {
        captures[filenames.length-i-1] = loadImage("captures/" + filenames[filenames.length-i-1]);  
        masterCount = filenames.length;
      }
    } else {
      for (int i = 0; i < captures.length; i++) {
        captures[captures.length-i-1] = loadImage("captures/" + filenames[filenames.length-i-1]);  
        masterCount = totalFrames;
      }
    }
  }

  canvas = createGraphics(1920, 1080, P2D);
  captures[displayCapture] = canvas.get();

  //println("Available Syphon servers:");
  //println(SyphonClient.listServers());
  client = new SyphonClient(this);

  voiceIndex = int(random(voices.length));
  background(0);
  lastSecond = second();
  
  noCursor();
}

public void draw() {  
  background(0);
  if (client.newFrame()) {
    canvas = client.getGraphics(canvas);

    if (mode == FAST) {
      if (masterCount >= 2) {
        displayCapture++;
        if (displayCapture >= masterCount - 1 || displayCapture >= totalFrames) {
          displayCapture = 0;
        }
      }
    }
  } 



  if (second() != lastSecond) {
    lastSecond = second();

    if (mode == SLOW) {
      if (masterCount >= 2) {
        displayCapture++;
        if (displayCapture >= masterCount - 1 || displayCapture >= totalFrames) {
          displayCapture = 0;
        }
      }
    }

    countDown();
    count++;

    if (count > secondsBetweenCaptures) {
      if (saveFrames) {
        if (useThread) {
          thread("saveThatImage");  // ERROR, the thread isn't working
          currentImage = canvas.get();
        } else {
          Date ts = new java.util.Date();
          canvas.save("captures/" + ts.getTime() + "_" + nf(masterCount, 6) + ".png");
        }
      }
      captures[currentCapture] = canvas.get();
      currentCapture = masterCount % totalFrames;
      println(masterCount % totalFrames);
      count = 0;  // Count seconds between frames, return to 0
      masterCount++;  // Count number of images captured
    }
  }

  image(captures[displayCapture], 0, 0, width, height);
  image(canvas, width/2 - width/8, height/2 - height/8, width/4, height/4);

  //textSize(60);
  //text(displayCapture, width/2, height/8);
}

void speak(String script, String voice, int speed) {
  try {
    Runtime.getRuntime().exec(new String[] {"say", "-v", voice, "[[rate " + speed + "]]" + script});
  }
  catch (IOException e) {
    System.err.println("IOException");
  }
}

void countDown() {
  /*
  if (count == 3 && masterCount % nextGroup == 0 && masterCount > 0) {
   speak(s2, voices[voiceIndex], 200);
   }
   */

  if (count == secondsBetweenCaptures - 10) {
    speak("10", voices[voiceIndex], 300);
  } else if (count == secondsBetweenCaptures - 9) {
    speak("9", voices[voiceIndex], 300);
  } else if (count == secondsBetweenCaptures - 8) {
    speak("8", voices[voiceIndex], 300);
  } else if (count == secondsBetweenCaptures - 7) {
    speak("7", voices[voiceIndex], 300);
  } else if (count == secondsBetweenCaptures - 6) {
    speak("6", voices[voiceIndex], 300);
  } else if (count == secondsBetweenCaptures - 5) {
    speak("5", voices[voiceIndex], 300);
  } else if (count == secondsBetweenCaptures - 4) {
    speak("4", voices[voiceIndex], 300);
  } else if (count == secondsBetweenCaptures - 3) {
    speak("3", voices[voiceIndex], 300);
  } else if (count == secondsBetweenCaptures - 2) {
    speak("2", voices[voiceIndex], 300);
  } else if (count == secondsBetweenCaptures - 1) {
    speak("1", voices[voiceIndex], 300);
  } else if (count == secondsBetweenCaptures) {
    // The image was captured
    if (masterCount % nextGroup == 0 && masterCount > 0) {
      speak(s2, voices[voiceIndex], 150);
      println("hey!");
    } else {
      speak(s1, voices[voiceIndex], 150);
    }
    voiceIndex = int(random(voices.length));
  } else if (second() % 2 == 0 && count > countTickTock) {
    //speak("tick", voices[voiceIndex], 300);
  } else if (count > countTickTock) {
    //speak("tock", voices[voiceIndex], 300);
  }
}

void saveThatImage() {
  println("saveThatImage . . . ");
  //Date ts = new Date();
  //Date ts = new java.util.Date();
  //canvas.save("captures/" + ts.getTime() + nf(masterCount, 10) + ".png");
  //PImage pg = canvas.get();
  //println("got the canvas");
  Date ts = new java.util.Date();
  //println("defined the time");
  currentImage.save("captures/" + ts.getTime() + "_" + nf(masterCount, 6) + ".png");
  //println("end");
}

void mousePressed() {
}

void keyPressed() {
}