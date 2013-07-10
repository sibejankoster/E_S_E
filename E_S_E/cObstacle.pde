class cObstacle extends  cMouseMover{
  float a;
  float b;
 
  cObstacle(PVector position, float a, float b){
    super(position);    
    this.a = a;
    this.b = b;
  } 
  
  void update(){
    super.update();
  }
}
