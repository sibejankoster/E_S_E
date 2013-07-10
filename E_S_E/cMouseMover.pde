class cMouseMover{
  PVector position;
  PVector mousePositionOld;
  PVector mousePositionNew;  
  boolean bSelected;   
  boolean mousePressedOld;
  
  cMouseMover(PVector position){
    this.position = position;
    this.mousePositionNew = new PVector(0,0);
    this.mousePositionOld = new PVector(0,0); 
    this.bSelected = false; 
    this.mousePressedOld = false;  
  }
  
  void update(){
    this.mousePositionOld = this.mousePositionNew;
    this.mousePositionNew = new PVector(mouseX, mouseY);
    
    if (mousePressed == true && this.mousePressedOld == false) {
      if ( (mouseX > (this.position.x-10)) && (mouseX < (this.position.x+10)) && (mouseY > (this.position.y-10)) && (mouseY < (this.position.y+10)))
        this.bSelected = true; 
    }
    if (mousePressed == false && this.mousePressedOld == true){
      this.bSelected = false; 
    }
    
    if (this.bSelected){
      this.mousePositionOld.sub(this.mousePositionNew);      
      //this.position = new PVector(mouseX, mouseY);
      this.mousePositionOld.mult(-1);
      this.position.add(this.mousePositionOld);
    }    
    
    this.mousePressedOld = mousePressed;
  }
}
