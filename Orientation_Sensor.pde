class Orientation_Sensor{
  
  boolean tracking, continuouslyCalibrating, displaying;
  PVector center, orientation, previousOrientation;  // average location and direction
  float angle, refLength;       // rotation relative to verticle
  Point_Tracker TL, TR, BL, BR; // trackers at the corners of the square
  
  Orientation_Sensor (){
    center = new PVector(0,0);
    orientation = new PVector(0,0);
    previousOrientation = new PVector(0,0);
    // initialize each tracker (topLeft, topRight, bottomLeft, bottomRight)
    TL = new Point_Tracker();
    TR = new Point_Tracker();
    BL = new Point_Tracker();
    BR = new Point_Tracker();
  }
  
  void run(){
    if(tracking){
      // tell each tracker to track
      TL.track(); TR.track();
      BL.track(); BR.track();
      // get current orientation
      getOrientation();
      if(continuouslyCalibrating){
        // tell each tracker to calibrate
        TL.calibrate(); TR.calibrate();
        BL.calibrate(); BR.calibrate();
      }
    }
    // show everything
    if(displaying){
      display();
    }
  }
  
 
 
 // ORIENTATION CALCULATOR:
 // - gets (x, y) orientation from perspective changes in length 
 // - rotates that vector according to th change in angle relative to the norm
 void getOrientation(){
   // set center to average location of trackers
   center.set(TL.x, TL.y, 0); center.add(TR.x, TR.y, 0); center.add(BR.x, BR.y, 0); center.add(BL.x, BL.y, 0); center.div(4);
   // set orientation based on differences in side length
   previousOrientation.set(orientation);
   
//   ORIENTATION USING MATH 
//
//   orientation.set(  5*acos( dist( (TR.x + BR.x)/2, (TR.y + BR.y)/2, (TL.x + BL.x)/2, (TL.y + BL.y)/2 )/refLength ),
//                     5*acos( dist( (TR.x + TL.x)/2, (TR.y + TL.y)/2, (BL.x + BR.x)/2, (BL.y + BR.y)/2 )/refLength ),
//                     0 );
//   if ( dist(TL.x, TL.y, BL.x, BL.y) > dist(TR.x, TR.y, BR.x, BR.y) ){
//     orientation.x = abs(orientation.x);
//   } else{
//     orientation.x = -abs(orientation.x);
//   }
//   if( dist(TR.x, TR.y, TL.x, TL.y) > dist(BR.x, BR.y, BL.x, BL.y) ){
//     orientation.y = abs(orientation.y);
//   } else{
//     orientation.y = -abs(orientation.y);
//   }
//   if(orientation.mag() > 500){
//     orientation.set(0,0,0);
//   }
   
   // STUPID ORIENTATION FINDER
   orientation.set( dist(TL.x, TL.y, BL.x, BL.y) - dist(TR.x, TR.y, BR.x, BR.y), 
                   dist(TR.x, TR.y, TL.x, TL.y) - dist(BR.x, BR.y, BL.x, BL.y), 0);
   orientation.set(vectorAverage(orientation, previousOrientation));                 
   // set angle according to the original top-middle location compared to the current                
   angle = (atan2((TR.y + TL.y)/2 - center.y, (TR.x + TL.x)/2 - center.x + 2*PI)%(2*PI) - 3*PI/2);
   // rotate accordingly
   rotate2D(orientation, angle);
 }
 
 
 
 
 
 
  void display(){
    // draw "square"
    fill(150,150,210,170);
    noStroke();
    beginShape();
    vertex(TL.x, TL.y); vertex(TR.x, TR.y); 
    vertex(BR.x, BR.y); vertex(BL.x, BL.y); 
    endShape();
    // display individual trackers
    TL.display(); TR.display();
    BL.display(); BR.display();
    stroke(50,200,50);
    strokeWeight(5);
    // draw direction
    line(center.x, center.y, center.x + 40*orientation.x, center.y + 40*orientation.y);
    ellipse(center.x, center.y, 20, 20);
  }
  
  
  
  
  // Concise functions to set all booleans to true/false
  void activate(){
    tracking = true;
    continuouslyCalibrating = true;
    displaying = true;
  }
  void deactivate(){
    tracking = false;
    continuouslyCalibrating = false;
    displaying = false;
  }
  
  void setReach(int newReach){
    TR.reach = newReach;
    TL.reach = newReach;
    BR.reach = newReach;
    BL.reach = newReach;
  }
  
  
  // to calibrate the tracker, press 1, 2, 3, 4 on the different dots in a clockwise fashion
  // ex: topRight = 1  ->  bottomRight -> 2  ->  bottomLeft -> 3  topLeft -> 4
  void calibrateTracker(int x, int y, char tracker){
    switch(tracker){
      case '1':   TR.calibrate(x, y);
                  break;
      case '2':   BR.calibrate(x, y);
                  break;
      case '3':   BL.calibrate(x, y);
                  break;
      case '4':   TL.calibrate(x, y);
                  break;
    }
    refLength = (dist(TR.x, TR.y, TL.x, TL.y) + 
                 dist(TR.x, TR.y, BR.x, BR.y) +
                 dist(BL.x, BL.y, BR.x, BR.y) +
                 dist(BL.x, BL.y, TL.x, TL.y) )/4;
  }
}
