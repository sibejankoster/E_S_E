cWorld  world;

void setup() {
  size(1200, 600);  
  noStroke();
  fill(102);
  frameRate(40);
  world = new cWorld();
}

void draw() {
  background(200);
  
  world.update();
  world.draw();  
  
  world.robot.build();
  image(world.robot.imgWorld, (width*3/4)-(world.robot.imgWorld.width/2), height-(world.robot.imgWorld.height)); //klein monitor schermpje
    
  stroke(0);
  line(width/2,0,width/2,height);
}
