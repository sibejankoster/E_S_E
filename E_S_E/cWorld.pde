class cWorld{
  PGraphics pgWorld; 
  PImage    imgWorld;
  
  color colObstacle;
  color colSensor;
  color colGoal;
  
  cRobot robot;
  cGoal goal;
  ArrayList alObstacles;
  
  cWorld(){
    imgWorld = createImage(height, height, RGB);
    pgWorld  = createGraphics(height, height, JAVA2D);    
   
    colSensor = color(0,255,0);  //wit 
    colObstacle = color(0,0,255);
    colGoal  = color(255,0,0);
    
    robot = new cRobot(new PVector(50,300), new PVector(1,0));
    
    alObstacles = new ArrayList();    
    //alObstacles.add( new cObstacle(new PVector(300,100), 50, 50) );
    //alObstacles.add( new cObstacle(new PVector(300,150), 50, 50) );
    //alObstacles.add( new cObstacle(new PVector(300,200), 50, 50) );
    //alObstacles.add( new cObstacle(new PVector(300,250), 50, 50) );
    
    //alObstacles.add( new cObstacle(new PVector(250,250), 50, 50) );
    //alObstacles.add( new cObstacle(new PVector(200,250), 50, 50) );
    //alObstacles.add( new cObstacle(new PVector(150,250), 50, 50) );
    //alObstacles.add( new cObstacle(new PVector(100,250), 50, 50) );
    //alObstacles.add( new cObstacle(new PVector( 50,250), 50, 50) );
    
    goal = new cGoal(new PVector(360,360));
  }
  
  //for detecting collisions, build PImage representation of the internal world
  void build(){
    pgWorld.beginDraw();
    pgWorld.background(255);    
    
    pgWorld.stroke(colObstacle);    
    
    //draw obstacles
    pgWorld.rectMode(CENTER);
    pgWorld.fill(colObstacle);
    for (int i = 0; i < alObstacles.size(); i++) {      
      cObstacle obstacle = (cObstacle) alObstacles.get(i);
      if(obstacle.bSelected){
        pgWorld.stroke(0); 
      }
      else{
        pgWorld.noStroke();
      }
      //pgWorld.rectMode(CENTER);
      pgWorld.rect(obstacle.position.x, obstacle.position.y, obstacle.a, obstacle.b);
      pgWorld.stroke(0);
      pgWorld.arc(obstacle.position.x, obstacle.position.y, 10, 10, 0, 2*PI); 
    }     
    pgWorld.rectMode(CORNER);  
    pgWorld.endDraw();
    this.imgWorld = pgWorld;
  }
  
  //1
  void update(){
    
     //Move obstacle by mouse
     for (int i = 0; i < alObstacles.size(); i++) {
       cObstacle obstacle = (cObstacle) alObstacles.get(i);
       obstacle.update();
     }      
     
     //Move goal by mouse
     goal.update();
    
     build();
     robot.update(imgWorld);
  }
  
  //2
  void draw(){
    //draw world
    image(imgWorld,0,0);
    
    //draw robot
    robot.draw();
    
    //draw goal
    fill(colGoal);
    goal.draw();
  }  
}
