class cSensor{
  
  PGraphics pgWorld; 
  PImage    imgWorld;
  
  color colObstacle;
  color colSensor;
  color colRef;  
  
  PVector position;
  PVector heading;
  float fRange;
  int index;
  float fLastMeasurement;
  
  cSensor(PVector position, PVector heading, float fRange){
    this.position = position;    
    this.fRange = fRange;
    this.heading = heading;
    handleHeading();
    this.index = -1;
    this.fLastMeasurement = -1;
    
    imgWorld = createImage(height, height, RGB);
    pgWorld = createGraphics(height, height, JAVA2D);  

    colSensor = color(0,255,0);
    colObstacle = color(0,0,255);
    colRef = color(255,255,255);
    //println("colSensor: " + hex(colSensor));
    //println("colObstacle: " + hex(colObstacle));
    //println("heading mag: " + heading.mag());
  } 
  
  void handleHeading(){
    this.heading.normalize();
    this.heading.mult(this.fRange);    
  }
  
  void build(){
    pgWorld.beginDraw();
    pgWorld.background(255);
    
    //draw sensor
    pgWorld.noSmooth();
    pgWorld.noFill();
    pgWorld.stroke(colSensor);
    
    //draw line into pgWorld
    pgWorld.point(this.position.x, this.position.y);
    pgWorld.line(this.position.x, this.position.y, this.position.x + this.heading.x, this.position.y + this.heading.y);    
      
    pgWorld.endDraw();
    this.imgWorld = pgWorld;       
  }  
  
  void draw(){    
    stroke(0);  
    float fLastMeasurement_ = this.getLastMeasurement();
    if (fLastMeasurement_ == -1)  fLastMeasurement_ = this.fRange; 
    line(this.position.x, this.position.y, this.position.x + this.heading.x*(fLastMeasurement_/this.fRange), this.position.y + this.heading.y*(fLastMeasurement_/this.fRange));
  }
  
  void draw_world(){
    //build();
    image(this.imgWorld,0,0); 
  }
  
  String toString(){
    return "position [" + position.x + "," + position.y + "] heading [" + heading.x + "," + heading.y + "] range [" + this.fRange + "]";
  }
  
  //-------------------
  // Convert PVector::p into position in array
  //-------------------  
  int pointToPixelArrayPosition(PVector p, PImage img){
    int i = 0;
    i =  ( ( (int) p.y ) * img.width ) + (int)p.x;
    return i;
  }
    
  //-------------------
  // Convert position i in array to PVector
  //-------------------  
  PVector pixelArrayPositionToPoint(int i, PImage img){
    PVector p = new PVector(0,0);
    p.y = i/img.width;
    p.x = i%img.width; //reminder
    return p;
  }    
  
  //-------------------
  //measure dinstance to an obstacle - return -1 or measured distance
  //-------------------
  float measure(PImage img){
    float distance = -1;
    PVector pvExamine = position;
    
    this.imgWorld.loadPixels();
    img.loadPixels();
    
    this.index = pointToPixelArrayPosition(this.position, this.imgWorld);
    try{
      if (this.index >= 0){
        if (this.imgWorld.pixels[this.index] != colRef){      
          while(findSensorLine() != -1){
      
            //Check if there is an obstacle
            if (img.pixels[this.index] != colRef){
    
              //determine distance of this.index from this.position
              PVector vIndex = pixelArrayPositionToPoint(this.index, imgWorld);
              vIndex.sub(position);
              distance = vIndex.mag();          
              
              break; 
            }
          }
        }
        else{ 
          //println("reference color error. color = " + hex(this.imgWorld.pixels[this.index]) + " at: " + this.position);      
          
          this.imgWorld.updatePixels();    
          img.updatePixels();       
          
          return -2; 
        }
      }
    }
    catch (ArrayIndexOutOfBoundsException e){
      //println("This pixel [" + this.index + "] can't be read!");
      return -1;
    }
 
    this.imgWorld.updatePixels();    
    img.updatePixels(); 
    
    fLastMeasurement = distance;
    return distance;
  }
  
  float getLastMeasurement(){
    return this.fLastMeasurement; 
  }  
  
  PVector getLastMeasuredVector(){
    return new PVector(this.heading.x*(this.fLastMeasurement/this.fRange), this.heading.y*(this.fLastMeasurement/this.fRange));    
  }
  
  int findSensorLine(){
    try{
      if (this.imgWorld.pixels[this.index] == colSensor){
        this.imgWorld.pixels[this.index] = colRef;      
        return this.index;
      }
      else{ //check neighbours
        PVector p = pixelArrayPositionToPoint(this.index, this.imgWorld);
        PVector p_bck = p.get();      
        
        //right-up neighbor
        p.x++; p.y--;
        this.index = pointToPixelArrayPosition(p, this.imgWorld);    
        if (this.imgWorld.pixels[this.index] == colSensor){
          this.imgWorld.pixels[this.index] = colRef;
          return this.index;
        }      
        p = p_bck.get();
        
        //right neighbor
        p.x++;       
        this.index = pointToPixelArrayPosition(p, this.imgWorld);    
        if (this.imgWorld.pixels[this.index] == colSensor){
          this.imgWorld.pixels[this.index] = colRef;
          return this.index;
        }      
        p = p_bck.get();
        
        //right-down neighbor
        p.x++; p.y++;
        this.index = pointToPixelArrayPosition(p, this.imgWorld);   
        if (this.imgWorld.pixels[this.index] == colSensor){
          this.imgWorld.pixels[this.index] = colRef;
          return this.index;
        }      
        p = p_bck.get();    
      
        //up neighbor
        p.y--;
        this.index = pointToPixelArrayPosition(p, this.imgWorld); 
        if ( this.index >= 0){
          if (this.imgWorld.pixels[this.index] == colSensor){
            this.imgWorld.pixels[this.index] = colRef;
            return this.index;
          }      
        }
        p = p_bck.get();
  
        //down neighbor
        p.y++;
        this.index = pointToPixelArrayPosition(p, this.imgWorld); 
        if ( this.index >= 0){
          if (this.imgWorld.pixels[this.index] == colSensor){
            this.imgWorld.pixels[this.index] = colRef;
            return this.index;
          }      
        }
        p = p_bck.get();      
        
        //left-up neighbor
        p.x--; p.y--;
        this.index = pointToPixelArrayPosition(p, this.imgWorld); 
        if ( this.index >= 0){
          if (this.imgWorld.pixels[this.index] == colSensor){
            this.imgWorld.pixels[this.index] = colRef;
            return this.index;
          }      
        }
        p = p_bck.get();
        
        //left neighbor
        p.x--;       
        this.index = pointToPixelArrayPosition(p, this.imgWorld);      
        if (this.imgWorld.pixels[this.index] == colSensor){
          this.imgWorld.pixels[this.index] = colRef;
          return this.index;
        }      
        p = p_bck.get();
        
        //left-down neighbor
        p.x--; p.y++;
        this.index = pointToPixelArrayPosition(p, this.imgWorld);   
        if (this.imgWorld.pixels[this.index] == colSensor){
          this.imgWorld.pixels[this.index] = colRef;
          return this.index;
        }            
        
      }
    }  
    catch (ArrayIndexOutOfBoundsException e){
      //println("This pixel [" + this.index + "] can't be read!");
      return -1;
    }
    
    return -1;
  }     
}
