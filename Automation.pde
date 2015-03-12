void runMonitor(){
  if(searching){
    continueSearch();
  } else{
    radiusCount = 0;
    radiusSum = 0;
  }
}




int radiusCount = 0;
float radiusSum = 0;

/////////  - CLUSTER FUNCTION
//
// - Groups the given set of points into four 
//
// - When complete, callibrates the orientation sensor
//
////////////////////////////////////////////////////////////////

void cluster(ArrayList <PVector> points){
  PVector[] ps = new PVector[4];
  for(int i = 0; i < 4; i++){
    ps[i] = new PVector(0,0,0);
  }
  float biggest = -1;
  int[] inds = new int[4];
  
  // find best square of points
  for(int a = 0; a < points.size(); a++){
    for(int b = 0; b < points.size(); b++){
      if(a != b){
        for(int c = 0; c < points.size(); c++){
          if(c != b  &&  c != a){
            for(int d = 0; d < points.size(); d++){
              if(d != c  &&  d != b  &&  d != a){
                ps[0].set( points.get(a));
                ps[1].set( points.get(b));
                ps[2].set( points.get(c));
                ps[3].set( points.get(d));
                float l = sideLength(ps);
                if( l > biggest){
                  biggest = l;
                  inds[0] = a;
                  inds[1] = b;
                  inds[2] = c;
                  inds[3] = d;
                }
              }
            }
          }
        }
      }
    }
  }
  
  PVector[] quad = new PVector[4];
  fill(250,0,0);
  for(int i = 0; i < 4; i++){
    quad[i] = new PVector(0,0,0);
    quad[i].set(points.get(inds[i]).x, points.get(inds[i]).y, 0);
    ellipse(points.get(inds[i]).x, points.get(inds[i]).y, 60, 60);
  }
  PVector center = new PVector(0,0,0);
  for(PVector t : quad){
    center.add(t);
  }
  center.div(4);
  for(int i = 0; i < 4; i++){
    quad[i] = PVWA(quad[i], 5, center, 1);
  }
  
  // order points correctly
  // inds 0 and 1 --> TR and BR
  int r1, r2;
  r1 = 0;  r2 = 0;
  for(int i = 0; i < 4; i++){
    if(quad[i].x > quad[r1].x){
      r2 = r1;
      r1 = i;
    } else{
      if(quad[i].x > quad[r2].x){
        r2 = i;
      }
    }
  }
  int TR = r1;
  int BR = r2;
  if(quad[r2].y < quad[TR].y){
    TR = r2;
    BR = r1;
  }
  int TL = 0;
  int BL = 0;
  while(TL == TR  ||  TL == BR){
    TL++;
  }
  while(BL == BR  ||  BL == TL  ||  BL == TR){
    BL++;
  }
  if(quad[BL].y > quad[TL].y){
    int t = BL;
    BL = TL;
    TL = t;
  }
  
  // calibrate
  sensor.setReach( int(radiusSum/radiusCount)+7 );
  sensor.calibrateTracker( video.width - int(quad[TR].x), int(quad[TR].y), '2' );
  sensor.calibrateTracker( video.width - int(quad[BR].x), int(quad[BR].y), '1' );
  sensor.calibrateTracker( video.width - int(quad[BL].x), int(quad[BL].y), '3' );
  sensor.calibrateTracker( video.width - int(quad[TL].x), int(quad[TL].y), '4' );
}



/////////  - SEARCH FUNCTION
//
// - Searches for circles over multiple frames
//
// - When complete, calls the cluster function
//   and sets "searching" to false
//
////////////////////////////////////////////////////////////////

boolean searching;
int searchCount;
ArrayList <PVector> newCircles = new ArrayList();
ArrayList <PVector> tempCircles = new ArrayList();

void continueSearch(){
  // GATHER DATA
  if(searchCount < 19){
    tempCircles.clear();
    tempCircles = getCircles();
    for(int i = 0; i < newCircles.size(); i++){
      for(int j = 0; j < tempCircles.size(); j++){
        if(newCircles.get(i).x == tempCircles.get(j).x){
          if(newCircles.get(i).y == tempCircles.get(j).y){
            newCircles.get(i).z += 1;
            tempCircles.remove(j);
          }
        }
      }
    }
    newCircles.addAll(tempCircles);
    searchCount++;
  }
  
  // CLEAN DATA
  else if(searchCount == 20){
    searchCount++;
    
    // delete circles that weren't detected often
    for(int i = 0; i < newCircles.size(); i++){
      if(newCircles.get(i).z < 15){
        newCircles.remove(i);
      }
    }
    
    // delete circles that are close to each other
    for(int i = 0; i < newCircles.size(); i++){
      for(int j = 0; j < newCircles.size(); j++){
        if(i != j){
          if(newCircles.get(i).dist(newCircles.get(j)) < 80){
            newCircles.remove(i);
          }
        }
      }
    }
  }
  
  else{
    searching = false;
    searchCount = 0;
    fill(250,0,0);
    cluster(newCircles);
    fill(250);
    for(PVector temp : newCircles){
      ellipse(temp.x, temp.y, 20, 20);
    }
    newCircles.clear();
  }
}




ArrayList <PVector> getCircles(){
  ArrayList <PVector> circles = new ArrayList();
  fill(100,100,200,125);
  for(int x = 150; x < width - 150; x += 30){
    for(int y = 150; y < height - 150; y += 30){
      if(colorDiffRGB(video.pixels[x + y*width], backImage[x + y*width]) > 100){
        if( isCircle(x, y, 30, 20, 50) ){
          circles.add( new PVector(x, y, 1) );
          //ellipse(x, y, 20, 20);
        }
      }
    }
  }
  return circles;
}












/////////  - CIRCLE CHECKER
//
// - returns true if the given position is within a circle with
//   a radius between Rmin and Rmax
//
////////////////////////////////////////////////////////////////

ArrayList <PVector> points = new ArrayList();
PVector center = new PVector(0,0,0);

boolean isCircle(int IX, int IY, int reach, int Rmin, int Rmax){
  color init = video.pixels[IX + IY*video.width];  // color to use as a reference while searching
  if(colorDiffRGB(init, color(250,250,250)) > 100){
    points.clear();  // clear the old point set
    
    ///////  - FIND POINTS ON THE SHAPE'S BORDER -
    //
    for(float theta = 0; theta < 2*PI; theta += .3){
      for(int i = 1; i < reach; i++){
        PVector temp = new PVector(IX + i*5*cos(theta), IY + i*5*sin(theta), 0);
        if(colorDiffRGB(init, video.pixels[int(temp.x) + video.width*int(temp.y)]) > 80){
          points.add( (PVector) temp);
          break;
        }
      }
    }
    
   
    ///////  STOP IF NOT ENOUGH POINTS
    //
    if(points.size() > 2){
      
      //////  - FIND GREATEST DISTANCE  (DIAMETER)
      //
      float best = 0;
      int bi = 0;
      int bj = 0;
      for(int i = 0; i < points.size(); i++){
        for(int j = 0; j < points.size(); j++){
          float dist = points.get(i).dist(points.get(j));
          if(dist > best){
            best = dist;
            bi = i;
            bj = j;
          }
        }
      }
      
      // CENTER IS AT CENTER OF DIAMETER
      center.set(points.get(bi));
      center.add(points.get(bj));
      center.div(2);
      //ellipse(center.x, center.y, 30, 30);
      
      
      
      // make .z's equal to each point's radius
      float Ravg = 0;
      for(PVector point : points){
        Ravg += point.dist(center);
        point.z = point.dist(center);
      }
      // get average radius
      Ravg /= points.size();
      
      
      
      /////  - STOP IF RADIUS IS NOT IN RANGE
      //
      if(Ravg < Rmax  &&  Ravg > Rmin){
        ///////  GET AVERAGE RADIUS VARIATION
        // - used to determine "cicleness"
        float diffSum = 0;
        for(PVector point : points){
          diffSum += abs(Ravg - point.z);
        }
        
        // If average variation is reasonable, return true
        if(diffSum / points.size() < Ravg/8){
          radiusSum += Ravg;
          radiusCount += 1;
          return true;
        }
      }
    }
  }
  return false;
}
