//Differential drive robot

class cDDR{
  
  PVector wheelL;    //position of the left wheel
  PVector wheelR;    //positoin of the right wheel
  PVector position;  //position of the centre of mass
  PVector base;      //base vector
  double  heading;   //heading angle
  double R;          //radius of the wheels
  double L;          //distance between wheels
  
  cDDR(PVector position, double heading){  //heading in radians
    this.L = 50;
    this.R = 10;
    this.position = position;
    this.heading = heading;
    println("DDR heading: " + this.heading);
    this.base = new PVector((float)(this.L/2.0),0.0f);
    base.rotate((float)((-PI/2)+heading));
    println("DDR base: " + base.toString());
    this.wheelL = new PVector(position.x + base.x, position.y + base.y);
    this.wheelR = new PVector(position.x - base.x, position.y - base.y);
  }  
  
  void update_ddr(double vr, double vl){
    double d_x = (R/2)*(vr+vl)*cos((float)heading);
    double d_y = (R/2)*(vr+vl)*sin((float)heading);
    double d_heading = (R/L)*(vr-vl);
    
    this.heading += d_heading;
    this.heading = atan2(sin((float)this.heading), cos((float)this.heading));    //transform heading into <-PI, PI> interval
    this.position.x += d_x;  
    this.position.y += d_y;  
    
    this.base = new PVector((float)(this.L/2.0),0.0f);
    base.rotate((float)((-PI/2)+heading));
    this.wheelL = new PVector(position.x + base.x, position.y + base.y);
    this.wheelR = new PVector(position.x - base.x, position.y - base.y);
  }
  
  void update_unicycle(double v, double omega){
     double vr = (2*v + omega*this.L)/(2*this.R);
     double vl = (2*v - omega*this.L)/(2*this.R);
     update_ddr(vr, vl);
  }
  
  void draw(){
    stroke(204, 102, 0);
    arc(wheelL.x, wheelL.y, 10, 10, 0, PI*2);
    arc(wheelR.x, wheelR.y, 10, 10, 0, PI*2);
    line(wheelL.x, wheelL.y, wheelR.x, wheelR.y);
  } 
  
  void drawVector(PVector origin, PVector v){
    stroke(0);
    arc(origin.x, origin.y, 10, 10, 0, PI*2);
    line(origin.x, origin.y, origin.x+v.x, origin.y+v.y);
  }
  
}
