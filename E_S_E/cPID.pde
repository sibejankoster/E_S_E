class cPID{    
  
  /*
  PSEUDOCODE
  ----------
  previous_error = 0
  integral = 0 
  start:
    error = setpoint - measured_value
    integral = integral + error*dt
    derivative = (error - previous_error)/dt
    output = Kp*error + Ki*integral + Kd*derivative
    previous_error = error
    wait(dt)
    goto start
  */
  
  double error;
  double previous_error;
  double integral;
  double derivative;
  double dt;
  double output;
  double Kp;  //contributes to stability. medium rate responsiveness
  double Ki;  //tracking & disturbance rejection. slow rate responsiveness. may cause oscilations.
  double Kd;  //fast rate responsiveness. sensitive to noise.
  
  int previous_frame;
  int actual_frame;
  
  cPID(double Kp, double Ki, double Kd){
    this.previous_error = 0;
    this.integral = 0;
    this.derivative = 0;
    this.dt = 0.05;
    this.Kp = Kp;
    this.Ki = Ki;
    this.Kd = Kd;
    this.actual_frame = millis();
  } 
  
  double update(double refVal, double actVal){
    
    //compute dt
    previous_frame = actual_frame;
    actual_frame = millis();
    dt = (actual_frame - previous_frame)/1000.0;
    
    //actual PID regular
    error = refVal - actVal;
    integral = integral + error*dt;
    derivative = (error - previous_error)/dt;
    previous_error = error;    
    output = (Kp*error) + (Ki*integral) + (Kd*derivative);
    return output; 
  }
  
  double update(double refVal, double actVal, double error){
    
    //compute dt
    previous_frame = actual_frame;
    actual_frame = millis();
    dt = (actual_frame - previous_frame)/1000.0;
    
    //actual PID regular
    //error = refVal - actVal;
    integral = integral + error*dt;
    derivative = (error - previous_error)/dt;
    previous_error = error;    
    output = (Kp*error) + (Ki*integral) + (Kd*derivative);
    return output; 
  }  
  
  double update(PVector refVal, PVector actVal){
    //compute dt
    previous_frame = actual_frame;
    actual_frame = millis();
    dt = (actual_frame - previous_frame)/1000.0;
    
    //actual PID regular
    error = fAngleBetween(refVal, actVal);
    integral = integral + error*dt;
    derivative = (error - previous_error)/dt;
    previous_error = error;    
    output = (Kp*error) + (Ki*integral) + (Kd*derivative);
    return output;     
  }
  
  private float fAngleBetween(PVector a, PVector b){
    float fAngle = atan2( a.x*b.y - a.y*b.x, a.x*b.x + a.y*b.y );
    return fAngle;
  }  
}
