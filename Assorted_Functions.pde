// ROTATES THE GIVEN VECTOR
void rotate2D(PVector v, float theta) {
  float xTemp = v.x;
  v.x = v.x*cos(theta) - v.y*sin(theta);
  v.y = xTemp*sin(theta) + v.y*cos(theta);
}

PVector PVWA (PVector a, int aw, PVector b, int bw){
  a.mult(aw);
  b.mult(bw);
  a.add(b);
  a.div(aw + bw);
  return a;
}


// RETURNS THE AVERAGE OF THE TWO GIVEN VECTORS
PVector vectorAverage(PVector v1, PVector v2){
  PVector temp = new PVector((v1.x+v2.x)/2, (v1.y+v2.y)/2, 0);
  return temp;
}

// RETURNS THE DISTANCE BETWEEN COORDINATES
float vectorDistance(PVector v1, PVector v2){
  return sqrt(sq(v1.x-v2.x)+sq(v1.y-v2.y));
}


PVector expMap(PVector input, float maxIN, float maxOUT){
  PVector output = new PVector(0,0,0);
  output.set(input);
  float a = maxOUT / sq( maxIN );
  output.setMag(a*sq(input.mag()));
  return output;
}




float sideLength(PVector[] corn){
  
  // store lengths
  float[] lengths = new float[16];
  int c = 0;
  for(int i = 0; i < 4; i++){
    for(int j = 0; j < 4; j++){
      if(i != j){
        lengths[c] = corn[i].dist(corn[j]);
        c++;
      }
    }
  }
  
  float[] ordLengths = new float[16];
  for(int i = 0; i < 16; i++){
    float min = min(lengths);
    for(int j = 0; j < 16; j++){
      if(lengths[j] == min){
        lengths[j] = 234235345;
        break;
      }
    }
    ordLengths[i] = min;
  }
  
  // get avg side length
  float avg = 0;
  int i = 0;
  c = 0;
  while(c < 4  &&  i < 16){
    if(ordLengths[i] != 0){
      c++;
      avg += ordLengths[i];
    }
    i++;
  }
  avg /= 4;
  
  if(1 - (abs(sqrt(2)*avg - ordLengths[15]) + abs(sqrt(2)*avg - ordLengths[13]))/(2*avg) > .85){
    return avg;
  }
  return -1;
}
