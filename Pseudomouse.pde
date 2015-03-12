//////////// - PSEUDOMOUSE
// 
// Adam Smith, Lambert Wang, Abhi Gupta
// Massachusetts Academy of Math and Science
// last editted:  11:10 pm, May 9, 2013



// Robot libraries
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.InputEvent;
Robot robot;
int active;

// Video Libraries
import processing.video.*;
Capture video;



PImage cursorImage;
boolean displayingPixels = true; // turn this off if you don't want to see video
Orientation_Sensor sensor;
PVector Pseudomouse;




void setup(){
  frame.setIconImage( getToolkit().getImage("icon.png") );
  size(1280, 720, P2D);
  setupVideo();
  active = -1;
  try{
      robot = new Robot();
    }
    catch (AWTException e){
      e.printStackTrace();
  }
  sensor = new Orientation_Sensor();
  Pseudomouse = new PVector(width/2, height/2, 0);
}




void draw(){
  getVideo();
  sensor.run();
  PVector move = new PVector(0,0,0);
  move.set(sensor.orientation);
  move.mult(4.5);
  Pseudomouse.add(move);
  //Pseudomouse.add(sensor.orientation);
  if(isInBounds() == false){
    //Pseudomouse.sub(sensor.orientation);
    Pseudomouse.sub(move);
  }
  drawPseudomouse();
  fill(250);
  textSize(50);
  if(keyPressed == true){
    if(key == 'c'){
      threshold = mouseX;
    }
  }
  if(active == 1){
    robot.mouseMove(int(Pseudomouse.x), int(Pseudomouse.y));
  }
  runMonitor();
}





boolean isInBounds(){
  if(Pseudomouse.x > 0  &&  Pseudomouse.x < width  &&  Pseudomouse.y > 0  &&  Pseudomouse.y < height){
    return true;
  } else{
    // if out of bounds, move to center
    //Pseudomouse.set(width/2, height/2, 0);
    return false;
  }
}

void drawPseudomouse(){
  fill(0); stroke(250); strokeWeight(3);
  ellipse(Pseudomouse.x, Pseudomouse.y, 10, 10);
}




// CONTROLS AND STUFF (important)
void keyPressed(){
  switch (key){
    // press 'a' to activate sensor
    case 'a':   sensor.activate();
                break;
                
    // press 'd' to deactivate sensor            
    case 'd':   sensor.deactivate();
                break;
                
    // press 'o' to toggle pixel displaying            
    case 'p':   if(displayingPixels){
                  displayingPixels = false;
                } else{ displayingPixels = true;}
                break;
                
    // press 't' to calibrate the threshold according to a predetermined formula    
    case 't':   threshold = int(-6*(totalBrightness())*pow(10, -6) + 1044.5);    
                break;
    
    // press 'q' to activate and deactivate the mouse
    case 'q':   active*=-1;
                break;
    
    case 'm':   searching = true;
                break;
                
    case 'b':   recordBackground();
                break;
                
    case 'c':   robot.mousePress (InputEvent.BUTTON1_MASK);
                robot.mouseRelease (InputEvent.BUTTON1_MASK);
                break;
                
    // otherwise, calibrate according to key pressed            
    default:    sensor.calibrateTracker(mouseX, mouseY, key);
                break;
  }
}





