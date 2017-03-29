//basic camera controll

class RendererCamera {
  //Camera Vectors
  PVector MousePos, Resolution, CameraAt, CameraFWD, CameraLeft, CameraUp, CameraPos;
  //Constants
  float cameraViewWidth, cameraViewHeight, cameraDistance, angleX, angleY;
  vMath MathUtil;
  
  //basic info of camera and its calculations
  RendererCamera(PVector _MousePos, PVector _Resolution, PVector _cameraAT){
    //init
    MathUtil = new vMath();
    
    //Just setting vars
    //Normalize Mouse position
    MousePos = new PVector(_MousePos.x/_Resolution.x, _MousePos.y/_Resolution.y);
    
    Resolution = _Resolution;
    CameraAt = _cameraAT;// new PVector(0.0,0.0,0.0); origin
    //Defaults
    angleX = 3.14 + 6.28*MousePos.x;
    angleY = (MousePos.y*3.90)-0.4;
    //Camera specific
    CameraPos = new PVector((sin(angleX)*cos(angleY))*4.0, sin(angleY)*4.0, (cos(angleX)*cos(angleY))*4.0);//base it off mouse position on screen
    CameraFWD = MathUtil.normalizeVect(MathUtil.subVect(CameraAt,CameraPos));
    CameraLeft = MathUtil.normalizeVect(MathUtil.crossProduct(MathUtil.normalizeVect(MathUtil.subVect(CameraAt,CameraPos)), new PVector(0.0,MathUtil.eSign(cos(angleY)),0.0)));
    CameraUp = MathUtil.normalizeVect(MathUtil.crossProduct(CameraLeft, CameraFWD));
  
    //Camera Const
    cameraViewWidth = 6.0;
    cameraViewHeight = cameraViewWidth*(_Resolution.y/_Resolution.x);
    cameraDistance = 6.0;
    
  }
  
  
}
