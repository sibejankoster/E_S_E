class cRobot{
  
  /********************************
  * variables
  ********************************/
  cNavigationArch navigation;
  
  cDDR ddr;                    //direct drive class defines wheel speeds, direction
  cPID pidVelocity;            //PID class implements PID controller
  cPID pidOmega;
  double v, omega;
  PGraphics pgWorld; 
  PImage    imgWorld;  
  PImage    robot;
  
  PVector position;
  PVector heading;
  PVector obstacleHeading;
  PVector u;                    // input signal
  PVector telemetryPosition;    // position of point between wheels
  int iSensors;                 // number of sensors
  ArrayList alSensors;          //list of sensors robot has. Element = cSensor
  ArrayList alObstacles;        //list of found obstacles. Element = PVector
  ArrayList alMeasuredVectors;  //list of all vectors sensors have measured
  float fRange;                 //range of sensors
  float fToGoalDistance;
  
  color colObstacle;            // colours 
  color colSensor;
  color colRef;
  PFont myFont;                // screen font generate using /tools
  int [][] pixel;              // array for plotting trajectory

  /********************************
  * constructor
  ********************************/
    
  cRobot(PVector position, PVector heading){  //heading has x and y and needs to be normalised
    this.position = position;
    this.heading = heading;
    this.fRange = 75;
    this.fToGoalDistance = 0;
    this.iSensors = 0;  //20
    
    this.heading = heading;
    //println("robot heading: " + this.heading.toString()); 
    
    //DDR
    pidVelocity = new cPID(0.2, 0.2, 0.01);
    pidOmega    = new cPID(0.03, 0.025, 0.0002);
    this.v = 0;
    this.omega = 0;    
    float fDDRheading = atan2(heading.y,heading.x);      //atan returns angle from 0..2*PI (radians)
    println("fDDRheading: " + fDDRheading);
    ddr = new cDDR(position, fDDRheading);               //heading in radians
    
    //Sensors
    PVector tmpHeading = new PVector(this.heading.x, this.heading.y); 
    PVector tmpPosition = new PVector(this.position.x, this.position.y);   
    alSensors = new ArrayList(); 
   
    for (int i = 0; i < this.iSensors; i++){
      tmpHeading.rotate((2*PI)/(float)(this.iSensors));
      alSensors.add( new cSensor(tmpPosition, new PVector(tmpHeading.x, tmpHeading.y),  fRange) );
    } 

  /********************************
  * objects
  ********************************/
  
    obstacleHeading   = new PVector(0,0);
    alMeasuredVectors = new ArrayList();
    alObstacles       = new ArrayList();
    
    colSensor         = color(0,255,0);
    colObstacle       = color(0,0,255);
    colRef            = color(255,255,255);
    myFont            = createFont("Georgia", 14);
    textFont(myFont);
    robot           = loadImage("robot.png");
    telemetryPosition = new PVector(width/2 + 30, 30);

    imgWorld = createImage((int)this.fRange*2, (int)this.fRange*2, RGB);
    pgWorld = createGraphics(imgWorld.width, imgWorld.height, JAVA2D); 
    pixel = new int[150][150];
        
    navigation = new cNavigationArch();
    u = new PVector(0,0);
  } 
  
  //build PImage representation of the internal world
  void build(){
     pgWorld.beginDraw();
    pgWorld.background(50);
    
    //draw sensor
    pgWorld.noFill();
        
// draw trajectory in small screen using array for past data
   pgWorld.stroke(colSensor);
   pgWorld.strokeWeight (2);
   int cooX= floor(position.x/4);
   int cooY= floor(position.y/4);
   pixel[cooX][cooY]=1;
   for (int i =0; i<150; i++) {
     for (int j =0; j<150; j++) {
        if (pixel[i][j]==1) {
        pgWorld.ellipse(i,j, 2,2);
        }
     }
   }
    pgWorld.endDraw();
    this.imgWorld = pgWorld;       
  }    
  
  void update(PImage imgWorld){    
 
  /***********************************
  * calculate goal direction and errors
  ************************************/
   
    //Distance from goal    
    PVector tmp = new PVector(this.position.x, this.position.y);
    tmp.sub(world.goal.position);
    fToGoalDistance = tmp.mag();   
    
    //DDR - version 2
    this.u = navigation.getInputSignal();
    
    float heading_desired = atan2(u.y, u.x);                       // dit aanpassen op positie pen vooraan de robot
    float fheading = atan2(this.heading.y, this.heading.x);
    float heading_error = heading_desired - fheading;              //in radians
    //println("heading: " + fheading + " heading_desired: " + heading_desired + " heading_error: " + heading_error);
    heading_error = atan2(sin(heading_error),cos(heading_error));  //atan2 to make sure this stays in [-pi,pi].
    omega = pidOmega.update(heading_desired, fheading, heading_error);    
    if (fToGoalDistance > 2) ddr.update_unicycle(v, omega);        //stopcriterium
    
    this.v =  1.25/(log(abs((float)omega)+2)+1);
    
    //Get position from DDR to update sensors
    this.position = ddr.position;
    
    ///this.heading  = PVector.fromAngle((float)ddr.heading);
    this.heading = new PVector( cos((float)ddr.heading), sin((float)ddr.heading) );
    
    //Sensors
    PVector tmpHeading = new PVector(heading.x, heading.y);  
    PVector tmpPosition = new PVector(this.position.x, this.position.y);   
    for (int i = 0; i < alSensors.size(); i++) {
      cSensor sensor = (cSensor) alSensors.get(i);
      sensor.position = tmpPosition;
      sensor.position.x = Math.round(sensor.position.x);
      sensor.position.y = Math.round(sensor.position.y);            
      tmpHeading.rotate(2*PI/this.iSensors);  //each iteration rotate PI/5 radians
      sensor.heading = new PVector(tmpHeading.x, tmpHeading.y);      
      sensor.handleHeading();
      sensor.build();      
      sensor.measure(imgWorld);
    }      
    
  /********************************
  * analyze obstacles
  ********************************/
    alObstacles.clear();
    int num = 0;
    int iFirstOccurance = -1;
    int iLastOccurance = -1;
    boolean bPrev = true;
    boolean bCurr = true;
    boolean bObstacleFound = false;
    int index = 0;
    
    for (int i = 0; i < alSensors.size()*2; i++) {
      index = i%this.iSensors;
      cSensor sensor = (cSensor) alSensors.get(index);
      if (sensor.getLastMeasurement() > -1){  //sensor found something
        bCurr = true;
      }
      else{
        bCurr = false; 
      }
      
      if (bCurr && !bPrev){
        bObstacleFound = true;
        iFirstOccurance = index;
        break;
      }
      
      bPrev = bCurr;
    }
    
    if (bCurr  && !bObstacleFound){
      println(millis() + " all lasers are measuring");
      
      this.obstacleHeading.x = 0;
      this.obstacleHeading.y = 0;      
      
      println(millis() + " [1] this.obstacleHeading: " + this.obstacleHeading.toString());
    }
    else{
      boolean bPrevMeasurement = true;
      boolean bCurrMeasurement = true;  
  
      //Obstacle was found    
      if (bObstacleFound){
        for (int i = 0; i < alSensors.size(); i++) {
          index = i + iFirstOccurance;
          index = index % this.iSensors;  //10
          
          cSensor sensor = (cSensor) alSensors.get(index);
          
          if (sensor.getLastMeasurement() > -1){  //sensor found something
            bCurrMeasurement = true;
          }
          else {
            bCurrMeasurement = false; 
          }
          
          //println("index: " + index + " meas: " + sensor.getLastMeasurement());
          if (bCurrMeasurement == true && bPrevMeasurement == false){
            //println("obstacle: " + index); 
          }
          
          if (bCurrMeasurement == false && bPrevMeasurement == true){
            num++;
            iLastOccurance = index;
            iLastOccurance--;
            if (iLastOccurance == -1) iLastOccurance = (this.iSensors-1);
            if (iFirstOccurance == -1) iFirstOccurance = (this.iSensors-1);
            break;
          }
          
          bPrevMeasurement = bCurrMeasurement;
        }  
      
        //Compute average vector of all sensor measurements
        alMeasuredVectors.clear();
        if (iFirstOccurance > iLastOccurance) iLastOccurance += this.iSensors;
        for (int i = iFirstOccurance; i <= iLastOccurance; i++) {
          index = i%this.iSensors;
          cSensor sensor = (cSensor) alSensors.get(index);
          //println("sensor.getLastMeasuredVector(): " + index + ":" + sensor.getLastMeasuredVector().toString() + " " + sensor.getLastMeasurement());
          alMeasuredVectors.add( sensor.getLastMeasuredVector() );
        }
        
        this.obstacleHeading = getAvg(alMeasuredVectors);
        //println(millis() + " [2] this.obstacleHeading: " + this.obstacleHeading.toString());
      }      
      else{  //Obstacle was NOT found
        this.obstacleHeading.x = 0;
        this.obstacleHeading.y = 0;
        //println(millis() + " not found: this.obstacleHeading: " + this.obstacleHeading.toString());
      } 
    } 
    
    navigation.update(this.position, world.goal.position, this.obstacleHeading, this.fToGoalDistance);    
  }

  /*********************************************
  * go opposite direction from colliding objects
  **********************************************/
  
  //Compute average vector of all PVector elements in ArrayList 'vectors'
  PVector getAvg(ArrayList vectors){
    PVector res = new PVector(0,0);
    for (int i = 0; i < vectors.size(); i++){
      PVector v = (PVector) vectors.get(i);    
      res.x += v.x;
      res.y += v.y;
    }  
    res.mult(1.0/vectors.size());
    return res; 
  }  
    
  void draw(){
    rectMode(CENTER);
    stroke(0);
    
    //draw robot body

    pushMatrix();
    translate(position.x, position.y);
    rotate( this.heading.heading2D() );
    image(this.robot, -this.robot.width/6, -this.robot.height/2); //sjk
    popMatrix();
    
    //draw robot sensors
    for (int i = 0; i < alSensors.size(); i++) {
      cSensor sensor = (cSensor) alSensors.get(i);
      sensor.draw();
    } 

    //display robot data
    fill(0);
    PVector tPosition = new PVector(Math.round(this.position.x), Math.round(this.position.y));
    text("TELEMETRY",                                                                                    telemetryPosition.x, telemetryPosition.y);
    text("Pos: " + tPosition.toString(),                                                            telemetryPosition.x, telemetryPosition.y+20); 
    text("Head: " + Math.round(atan2(this.heading.y, this.heading.x)*10)/10.f,                        telemetryPosition.x, telemetryPosition.y+40);   
    text("Vel/Omega: " + Math.round(this.v*100)/100.0f + " / " + Math.round(this.omega*100)/100.0f, telemetryPosition.x, telemetryPosition.y+60); 
    text("Dist to goal: " +  Math.round(fToGoalDistance*10)/10.0f,                                 telemetryPosition.x, telemetryPosition.y+80); 
    text("Behaviour: " +  navigation.eBehaviour,                                                         telemetryPosition.x, telemetryPosition.y+100);
    text("Obst. direction: " + this.obstacleHeading.toString(),                                         telemetryPosition.x, telemetryPosition.y+120);
    text("Input signal: " + this.u.toString(),                                                           telemetryPosition.x, telemetryPosition.y+140);
  }
}
