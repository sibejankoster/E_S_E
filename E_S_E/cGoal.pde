class cGoal extends  cMouseMover{
  
  cGoal(PVector position){
    super(position);   
  } 
  
  void update(){
    super.update();    
  }
  
  void draw(){
    arc(this.position.x, this.position.y, 10,10,0,2*PI);
  }    
}
