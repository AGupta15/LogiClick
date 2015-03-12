int threshold = 670;

class Point_Tracker{
  
    color referenceColor;
    int reach, x, y;

    Point_Tracker (){
        x = width/2; y = height/2;      // start off position at the center
        referenceColor = color(0,0,0);  // start off color as black
        
        // we should automate these at some point... they're super annoying
        reach = 25;      // change this number to fit trackers snugly around circles
    }
    
    
    float value, sumX, sumY, count;
    
    // MAIN TRACKER FUNCTION:
    // - checks to make sure it's in bounds
    // - finds center of color
    // - moves to the center of color
    void track(){
        checkBounds(); // if out of bounds,move toward middle to prevent memory errors
        sumX = 0;      
        sumY = 0;
        value = 0;
        count = 0;
        // loop through pixels within the square that encapsilates the tracker 
        for(int i = x - reach; i < x + reach; i++){
            for(int j = y - reach; j < y + reach; j++){
                value = 750 - colorDiffRGB(referenceColor, video.pixels[width - i + j*width]);
                if(value > threshold){
                    count += value;
                    sumX += i*value;
                    sumY += j*value;
                }
            }
        }
        // to prevent dividing by zero...
        if(count > 5){
          // set position of tracker to center of reference color
          x = int(x + sumX/count)/2;  y = int(y + sumY/count)/2;
        }
    }
    
    
    void display(){
        // draw a fill-less circle around the tracker
        stroke(referenceColor);
        strokeWeight(10);
        noFill();
        ellipse(x, y, reach*2, reach*2);
    }
    
    void checkBounds(){
        // if out of bounds, move to the center of the screen
        if(abs(x - width/2) > width/2 - reach  ||  abs(y - height/2) > height/2 - reach){
            x = width/2;  y = height/2;
        }
    }
    
    // CALIBRATE COLOR AND LOCATION
    void calibrate (int newX, int newY){
      x = newX;  y = newY;
      referenceColor = get(x, y);
    }
    
    // CALIBRATE COLOR ONLY
    void calibrate(){
      // to prevent errors, get an average color of a few pixels, instead of just one
      referenceColor =  averageColorRGB(averageColorSquare (width - x, y, 3), referenceColor);
    }
}
