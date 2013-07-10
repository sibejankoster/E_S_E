  class cLog{
    
    java.io.FileWriter fstream;
    java.io.BufferedWriter out;
    String logFileName;
    boolean bLog;
    
    cLog(String logFileName, boolean bLog){
      this.logFileName = logFileName;
      this.bLog        = bLog;
      
      if (bLog){
        File inFile = new File(sketchPath("") + logFileName);
        if (!inFile.delete()) {
          println("Could not delete file");
          return;
        } 
        
        try{
          // Create file 
          fstream = new java.io.FileWriter(sketchPath("") + logFileName,true);
          out = new java.io.BufferedWriter(fstream);
          out.write("Logging: " + logFileName + "\r\n");
          out.close();
        }
        catch (Exception e){//Catch exception if any
          //output.println("cLor error: " + e.getMessage());
          javax.swing.JOptionPane.showMessageDialog(null, "cLor error: " + e.getMessage()); 
        }
      }
    }  
    
    
    void log(String str){
      if (bLog){
        Throwable t = new Throwable(); 
        StackTraceElement[] elements = t.getStackTrace(); 
        
        String calleeMethod = elements[0].getMethodName(); 
        String callerMethodName = elements[1].getMethodName(); 
        String callerClassName = elements[1].getClassName(); 
  
        try{
          // Create file 
          fstream = new java.io.FileWriter(sketchPath("") + logFileName,true);
          out = new java.io.BufferedWriter(fstream);
          out.write("Caller class: " + callerClassName + " | Caller method: " + callerMethodName + " -> " + str + "\r\n");
          out.close();
        }
        catch (Exception e){//Catch exception if any
          //javax.swing.JOptionPane.showMessageDialog(null, "cLor error: " + e.getMessage());
        }
      }
    }
    
    void finalize(){
      try{
        out.close();
      }
      catch (Exception e){//Catch exception if any
        //javax.swing.JOptionPane.showMessageDialog(null, "cLor finalize error: " + e.getMessage());
      }
    }
    
  }
