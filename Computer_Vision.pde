color[] backImage;



// BEGINS CAPTURE (DOESN'T ACTUALLY DO ANYTHING)
void setupVideo(){
  video = new Capture(this, width, height);
  video.start();
  backImage = new color[width*height];
}

// GETS AN INVISIBLE ARRAY OF PIXELS, "video.pixels"
// && if displaying pixels is on, it updates the pixels on the screen
void getVideo(){
  if (video.available()) {
    video.read();
    video.loadPixels();
    loadPixels();
    if(displayingPixels){
      pushMatrix();
        scale(-1,1);
        translate(-video.width, 0);
        image(video, 0, 0);
      popMatrix();
      updatePixels();
    }
  }
}


void recordBackground(){
  System.arraycopy(video.pixels, 0, backImage, 0, backImage.length );
}


float colorDiffRGB (color a, color b){
    return abs(red(a)-red(b)) + abs(green(a)-green(b)) + abs(blue(a)-blue(b));
}

color averageColorRGB (color a, color b){
    return color((red(a) + red(b))/2, (green(a) + green(b))/2, (blue(a) + blue(b))/2);
}


// returns the average color of the square around a point defined by "length"
color averageColorSquare (int centerX, int centerY, int length){
    int redSum = 0;
    int blueSum = 0;
    int greenSum = 0;
    // sum respectve pixel color traits
    for(int x = centerX - length/2; x < centerX + 1 + length/2; x++){
        for(int y = centerY - length/2; y < centerY + 1 + length/2; y++){
          if(x > 0  &&  x < video.width  &&  y > 0  &&  y < video.height){
              redSum += red(video.pixels[x + y*video.width]);
              greenSum += green(video.pixels[x + y*video.width]);
              blueSum += blue(video.pixels[x + y*video.width]);
          }
        }
    }    
    // return average
    return color(redSum/sq(length), greenSum/sq(length), blueSum/sq(length));
}




int totalBrightness(){
  float sum = 0;
  for(int i = 0; i < video.pixels.length; i++){
    sum += brightness(video.pixels[i]);
  }
  return int(sum);
}
