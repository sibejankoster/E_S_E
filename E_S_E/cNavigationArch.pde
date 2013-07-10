class cNavigationArch{
  
  cLog log;
  PVector u;       //u is actual input signal to the robot
  PVector u_gtg;   //go-to-goal input vector
  PVector u_fw_cc; // follow wall counter clockwise
  PVector u_fw_c;  // clockwise
  PVector u_ao;    // obstacle avoidance
  PVector tmp;     //just help variable
  float delta;     //how close we want to go to obstacle
  float eps = 15.0; //actual distance to obstacle
  float d_tau;     //distance to the goal
  eBehaviours eBehaviour;
  int state =0;
  
  cNavigationArch(){
    this.u       = new PVector(0.0, 0.0);
    this.u_gtg   = new PVector(0.0, 0.0);
    this.u_fw_cc = new PVector(0.0, 0.0);
    this.u_fw_c  = new PVector(0.0, 0.0);
    this.u_ao    = new PVector(0.0, 0.0);
    this.eBehaviour = eBehaviours.GTG;
    this.delta = 30;
    this.d_tau = 0;
    this.log = new cLog("cNavigationArch.log", false);
    log.log("cNavigationArch.log");
    log.log("eBehaviour: " + eBehaviour);
  }
  
  PVector getInputSignal(){
    return this.u;
  } 
  
  boolean equalsDelta(float d){    
    if ( (d > (delta - eps)) && (d < (delta + eps)) ) return true;
    else return false;
  }
  
  float innerProduct(PVector a, PVector b){
    return (a.x * b.x) + (a.y * b.y); 
  }
  
  //p - position of the robot
  //g - position of the goal
  //o - HEADING to obstacle
  void update(PVector p, PVector g, PVector o, float fToGoalDistance){
    
    //------------------
    //Go-To-Goal
    //------------------
    tmp = new PVector(p.x, p.y); 
    tmp.sub(g);                      //bepaal afstand (x,y) tot goal
    //tmp.normalize();
    tmp.mult(-1.0);                  //keer afstandsvector om
    this.u_gtg = tmp;

    //------------------
    //Avoid-Obstacle
    //------------------    
    if (o.x == 0 && o.y == 0){
      u_ao.x = 0;
      u_ao.y = 0; 
    }
    else{
      tmp = new PVector(o.x, o.y);         
      //tmp.normalize();
      tmp.mult(-1.0);
      this.u_ao = tmp;
    } 
    
    //------------------
    //Follow-The-Wall Clockwise
    //------------------
    tmp = new PVector(o.x, o.y);         
    //tmp.normalize();
    tmp.mult(-1.);
    tmp.rotate(PI/2);
    this.u_fw_c = tmp;      
    
    //------------------
    //Follow-The-Wall Counter-Clockwise
    //------------------
    tmp = new PVector(o.x, o.y);         
    //tmp.normalize();
    tmp.mult(-1.0);
    tmp.rotate(-PI/2);
    this.u_fw_cc = tmp;          
    
    //------------------
    //Set up behaviour
    //------------------
    //GTG -> FW_CC
    if (eBehaviour == eBehaviours.GTG && equalsDelta(o.mag()) && innerProduct(u_gtg, u_fw_cc) > 0){
      this.d_tau = fToGoalDistance;
      this.eBehaviour = eBehaviours.FW_CC;
      log.log("eBehaviour: " + eBehaviour);
    }
    
    //GTG -> FW_C
    if (eBehaviour == eBehaviours.GTG && equalsDelta(o.mag()) && innerProduct(u_gtg, u_fw_c) > 0){
      this.d_tau = fToGoalDistance;
      this.eBehaviour = eBehaviours.FW_C;
      log.log("eBehaviour: " + eBehaviour);
    }    
    
    //FW_CC -> AO
    if (eBehaviour == eBehaviours.FW_CC && Math.round(o.mag())/1.0f < (delta-eps)){
      this.eBehaviour = eBehaviours.AO;
      log.log("eBehaviour: " + eBehaviour);
    }
    
    //FW_C -> AO
    if (eBehaviour == eBehaviours.FW_C && Math.round(o.mag())/1.0f < (delta-eps)){
      this.eBehaviour = eBehaviours.AO;
      log.log("eBehaviour: " + eBehaviour);
    }    
    
    //AO -> FW_CC
    if (eBehaviour == eBehaviours.AO && equalsDelta(o.mag()) && innerProduct(u_gtg, u_fw_cc) > 0){
      this.d_tau = fToGoalDistance;
      this.eBehaviour = eBehaviours.FW_CC;
      log.log("eBehaviour: " + eBehaviour);
    }
    
    //AO -> FW_C
    if (eBehaviour == eBehaviours.AO && equalsDelta(o.mag()) && innerProduct(u_gtg, u_fw_c) > 0){
      this.d_tau = fToGoalDistance;
      this.eBehaviour = eBehaviours.FW_C;
      log.log("eBehaviour: " + eBehaviour);
    }    
    
    //FW_CC -> GTG
    if (eBehaviour == eBehaviours.FW_CC && fToGoalDistance < d_tau && innerProduct(u_ao, u_gtg) > 0){
      this.eBehaviour = eBehaviours.GTG;
      log.log("eBehaviour: " + eBehaviour);
    }
    
    //FW_C -> GTG
    if (eBehaviour == eBehaviours.FW_C && fToGoalDistance < d_tau && innerProduct(u_ao, u_gtg) > 0){
      this.eBehaviour = eBehaviours.GTG;
      log.log("eBehaviour: " + eBehaviour);
    }    
  
  // ---- hack goal  ----
  // write letters
  tmp = new PVector(p.x, p.y);
  int hyst= 600; 
    //
    //hiertussen moet de af te leggen figuur
    //
    if (state ==0)                   
    { g.x=180;                    // dit is het eerste punt
      g.y=220;
      tmp.sub(g);                 // bepaal afstand (x,y) tot goal
      if (tmp.x*tmp.x+tmp.y*tmp.y <hyst) state =1;  
    }
  if (state ==1)                   
    { g.x=180;                    // 
      g.y=160;
      tmp.sub(g);                 // bepaal afstand (x,y) tot goal
      if (tmp.x*tmp.x+tmp.y*tmp.y <hyst) state =2;  
    }
  if (state ==2)                   
    { g.x=120;                    // 
      g.y=160;
      tmp.sub(g);                 // bepaal afstand (x,y) tot goal
      if (tmp.x*tmp.x+tmp.y*tmp.y <hyst) state =3;  
    }
    if (state ==3)                   
    { g.x=120;                    // 
      g.y=250;
      tmp.sub(g);                 // bepaal afstand (x,y) tot goal
      if (tmp.x*tmp.x+tmp.y*tmp.y <hyst) state =4;  
    }
    if (state ==4)                   
    { g.x=190;                    // 
      g.y=300;
      tmp.sub(g);                 // bepaal afstand (x,y) tot goal
      if (tmp.x*tmp.x+tmp.y*tmp.y <hyst) state =5;  
    }
    if (state ==5)                   
    { g.x=240;                    // 
      g.y=260;
      tmp.sub(g);                 // bepaal afstand (x,y) tot goal
      if (tmp.x*tmp.x+tmp.y*tmp.y <hyst) state =6;  
    }
    if (state ==6)                   
    { g.x=280;                    // 
      g.y=170;
      tmp.sub(g);                 // bepaal afstand (x,y) tot goal
      if (tmp.x*tmp.x+tmp.y*tmp.y <hyst) state =7;  
    }
    if (state ==7)                   
    { g.x=340;                    // 
      g.y=230;
      tmp.sub(g);                 // bepaal afstand (x,y) tot goal
      if (tmp.x*tmp.x+tmp.y*tmp.y <hyst) state =8;  
    }
    if (state ==8)                   
    { g.x=300;                    // 
      g.y=290;
      tmp.sub(g);                 // bepaal afstand (x,y) tot goal
      if (tmp.x*tmp.x+tmp.y*tmp.y <hyst) state =9;  
    }
       if (state ==9)                   
    { g.x=280;                    // 
      g.y=240;
      tmp.sub(g);                 // bepaal afstand (x,y) tot goal
      if (tmp.x*tmp.x+tmp.y*tmp.y <hyst) state =10;  
    }
       if (state ==10)                   
    { g.x=340;                    // 
      g.y=270;
      tmp.sub(g);                 // bepaal afstand (x,y) tot goal
      if (tmp.x*tmp.x+tmp.y*tmp.y <hyst) state =11;  
    }
      if (state ==11)                   
    { g.x=440;                    // dit is het eerste punt
      g.y=220;
      tmp.sub(g);                 // bepaal afstand (x,y) tot goal
      if (tmp.x*tmp.x+tmp.y*tmp.y <hyst) state =12;  
    }
    if (state ==12)                   
    { g.x=440;                    // 
      g.y=160;
      tmp.sub(g);                 // bepaal afstand (x,y) tot goal
      if (tmp.x*tmp.x+tmp.y*tmp.y <hyst) state =13;  
    }
    if (state ==13)                   
    { g.x=380;                    // 
      g.y=160;
      tmp.sub(g);                 // bepaal afstand (x,y) tot goal
      if (tmp.x*tmp.x+tmp.y*tmp.y <hyst) state =14;  
    }
    if (state ==14)                   
    { g.x=380;                    // 
      g.y=250;
      tmp.sub(g);                 // bepaal afstand (x,y) tot goal
      if (tmp.x*tmp.x+tmp.y*tmp.y <hyst) state =15;  
    }
    if (state ==15)                   
    { g.x=400;                    // 
      g.y=300;
      tmp.sub(g);                 // bepaal afstand (x,y) tot goal
      if (tmp.x*tmp.x+tmp.y*tmp.y <hyst) state =16;  
    }
    if (state ==16)                   
    { g.x=480;                    // 
      g.y=280;
      tmp.sub(g);                 // bepaal afstand (x,y) tot goal
      if (tmp.x*tmp.x+tmp.y*tmp.y <hyst) state =17;  
    }
    if (state ==17)                  
    { g.x=520;                    // 
      g.y=260;
      tmp.sub(g);                 // bepaal afstand (x,y) tot goal
      if (tmp.x*tmp.x+tmp.y*tmp.y <hyst) state =18;  
    }
    
    if (this.eBehaviour == eBehaviours.GTG)   this.u = this.u_gtg;
    if (this.eBehaviour == eBehaviours.FW_CC) this.u = this.u_fw_cc;
    if (this.eBehaviour == eBehaviours.FW_C)  this.u = this.u_fw_c;
    if (this.eBehaviour == eBehaviours.AO)    this.u = this.u_ao;
  }
  
  //p - position of the robot
  //g - position of the goal
  //o - HEADING to obstacle
  void update_(PVector p, PVector g, PVector o, float fToGoalDistance){
    
    //log.log("update - STARTED");    
    
    //------------------
    //Set up behaviour
    //------------------
    //if (eBehaviour == eBehaviours.GTG && Math.round(o.mag())/1.0f  == delta){
    if (eBehaviour == eBehaviours.GTG && equalsDelta(o.mag())){
      this.d_tau = fToGoalDistance;
      this.eBehaviour = eBehaviours.FW_CC;
      log.log("eBehaviour: " + eBehaviour);
    }
    
    if (eBehaviour == eBehaviours.FW_CC && Math.round(o.mag())/1.0f < delta){
      this.eBehaviour = eBehaviours.AO;
      log.log("eBehaviour: " + eBehaviour);
    }
    
    //if (eBehaviour == eBehaviours.AO && Math.round(o.mag())/1.0f == delta){
    if (eBehaviour == eBehaviours.AO && equalsDelta(o.mag())){
      this.d_tau = fToGoalDistance;
      this.eBehaviour = eBehaviours.FW_CC;
      log.log("eBehaviour: " + eBehaviour);
    }
    
    if (eBehaviour == eBehaviours.FW_CC && fToGoalDistance < d_tau){
      this.eBehaviour = eBehaviours.GTG;
      log.log("eBehaviour: " + eBehaviour);
    }
    
    //------------------
    //Go-To-Goal
    //------------------
    if (eBehaviour == eBehaviours.GTG){
      PVector tmp = new PVector(p.x, p.y); 
      tmp.sub(g);
      tmp.normalize();
      tmp.mult(-0.4);
      this.u = tmp;
    }
    
    //------------------
    //Avoid-Obstacle
    //------------------
    if (eBehaviour == eBehaviours.AO){
      if (o.x == 0 && o.y == 0){
        u.x = 0;
        u.y = 0; 
      }
      else{
        PVector tmp = new PVector(o.x, o.y);         
        tmp.normalize();
        tmp.mult(-0.4);
        this.u = tmp;
      }
    }    
    
    //------------------
    //Follow-The-Wall Clockwise
    //------------------
    if (eBehaviour == eBehaviours.FW_C){
      PVector tmp = new PVector(o.x, o.y);         
      tmp.normalize();
      tmp.mult(-0.4);
      tmp.rotate(PI/2);
      this.u = tmp;      
    }
    
    //------------------
    //Follow-The-Wall Counter-Clockwise
    //------------------
    if (eBehaviour == eBehaviours.FW_CC){
      PVector tmp = new PVector(o.x, o.y);         
      tmp.normalize();
      tmp.mult(-0.4);
      tmp.rotate(-PI/2);
      this.u = tmp;       
    }    
    
    //log.log("update - COMPLETED");
  }
}
