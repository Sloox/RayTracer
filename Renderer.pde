//basic class to render a scene
//renders pixel by pixel keeping all vars in global state for return to main screen

class Renderer{
  
  //globals for state
    vMath Mathutils;
    RendererCamera rCam;
    int raybouncemax = 12;
    CollisionHelper CH, CHTemp, CHRefract;//CHTemp used in PointToPointCheck to keep original CH state
    SceneHandler SceneH;
    float[] RGBGlobal;
    float gamma;
    int infinitetextureScale = 32;//for infinte planes
    
    
  Renderer(PVector MPos, PVector Res, int _raybouncemax, float _gamma){//constructor
    Mathutils = new vMath();
    raybouncemax = _raybouncemax;
    //Asuming default for now
    //SceneH = new SceneHandler(sketchPath("data\\Scenes\\Lorem.txt"));
   // SceneH = new SceneHandler(sketchPath("data\\Scenes\\tunnel.txt"));
   // SceneH = new SceneHandler(sketchPath("data\\Scenes\\planet.txt"));
    // SceneH = new SceneHandler(sketchPath("data\\Scenes\\planes.txt"));
  SceneH = new SceneHandler();
    rCam = new RendererCamera( MPos, Res, new PVector(0.0,0.0,0.0));
    RGBGlobal = new float[]{0.0,0.0,0.0};
    gamma = _gamma;
  }
  
  void updateCamMouse(PVector MPos, PVector Res){
     rCam = new RendererCamera( MPos, Res, new PVector(0.0,0.0,0.0));
  }
  
  
  
  //base raytracing 
  float[] calcPixelColor_NOSSA(float x, float y, int xRes, int yRes){
    RGBGlobal = new float[]{0.0,0.0,0.0};
    //screen coords   
    PVector screenVec = new PVector(x,y);
    PVector ResVec = new PVector(xRes,yRes);
    PVector cPercent = Mathutils.componendDiv2(screenVec,ResVec);
    PVector nPercent = Mathutils.subVect(cPercent, new PVector(0.5,0.5));
    
    //ray from the pixel
    PVector rayPos;
    PVector rayTarget;
   
  //rayTarget calcs
    PVector Temp = Mathutils.scalarMult(rCam.CameraFWD,rCam.cameraDistance);
    PVector Temp2 = Mathutils.scalarMult(rCam.CameraLeft,(rCam.cameraViewWidth*nPercent.x));
    PVector Temp3 = Mathutils.scalarMult(rCam.CameraUp,(rCam.cameraViewHeight*nPercent.y));
 
    rayTarget = Mathutils.addVect(Temp,Mathutils.addVect(Temp2,Temp3));
    rayPos = rCam.CameraPos.get();
    
    PVector rayDir = Mathutils.normalizeVect(rayTarget);
    
    RGBGlobal = rayTraceRefraction(rayPos, rayDir, raybouncemax);
    //RGBGlobal = ApplyToneMap(RGBGlobal);
    //RGBGlobal = ApplyGamma(RGBGlobal,gamma );
    return RGBGlobal; 
   }
   
   
  //random offset for each pixel
  float[] calcPixelColor_STOCHASTICSSA(float x, float y, int xRes, int yRes, int Samples, float offsetMin, float offsetMax){
    RGBGlobal = new float[]{0.0,0.0,0.0};
    //screen coords   
    PVector screenVec = new PVector(x,y);
    PVector ResVec = new PVector(xRes,yRes);
    ArrayList<float[]> Cols = new ArrayList<float[]>();
    for(int i = 0;i<Samples;++i){
      PVector offsetVec = Mathutils.clampVect(PVector.random2D(),offsetMin,offsetMax);
      PVector cPercent = Mathutils.componendDiv2(Mathutils.addVect(screenVec,offsetVec),ResVec);
      PVector nPercent = Mathutils.subVect(cPercent, new PVector(0.5,0.5));
      
      //ray from the pixel
      PVector rayPos;
      PVector rayTarget;
     
    //rayTarget calcs
      PVector Temp = Mathutils.scalarMult(rCam.CameraFWD,rCam.cameraDistance);
      PVector Temp2 = Mathutils.scalarMult(rCam.CameraLeft,(rCam.cameraViewWidth*nPercent.x));
      PVector Temp3 = Mathutils.scalarMult(rCam.CameraUp,(rCam.cameraViewHeight*nPercent.y));
   
      rayTarget = Mathutils.addVect(Temp,Mathutils.addVect(Temp2,Temp3));
      rayPos = rCam.CameraPos.get();
      
      PVector rayDir = Mathutils.normalizeVect(rayTarget);
      
      Cols.add((rayTraceRefraction(rayPos, rayDir, raybouncemax))); 
     // println(RGBGlobal);
    //delay(10000);
    }
    for(float[] ff : Cols){
      RGBGlobal = new float[]{RGBGlobal[0]+ff[0],RGBGlobal[1]+ff[1],RGBGlobal[2]+ff[2]};
    }
    RGBGlobal = new float[]{RGBGlobal[0]/(Samples*Samples),RGBGlobal[1]/(Samples*Samples),RGBGlobal[2]/(Samples*Samples)};//average out pixels and return color
    //post FX
   // RGBGlobal = ApplyToneMap(RGBGlobal);
   // RGBGlobal = ApplyGamma(RGBGlobal,gamma);
    
    return RGBGlobal; 
   }
   
   
   
   float[] calcPixelColor_STOCHASTICREGULARSSA_18(float x, float y, int xRes, int yRes, float offset){//SSA via grid patteren
      RGBGlobal = new float[]{0.0,0.0,0.0};
      
      ArrayList<float[]> Cols = new ArrayList<float[]>();
        Cols.add(calcPixelColor_NOSSA(x,y,xRes,yRes));//base ray
        Cols.add(calcPixelColor_NOSSA(x+offset,y,xRes,yRes));//right
        Cols.add(calcPixelColor_NOSSA(x-offset,y,xRes,yRes));//left
        Cols.add(calcPixelColor_NOSSA(x,y+offset,xRes,yRes));//down
        Cols.add(calcPixelColor_NOSSA(x,y-offset,xRes,yRes));//up
        Cols.add(calcPixelColor_NOSSA(x-offset,y-offset,xRes,yRes));//up & left
        Cols.add(calcPixelColor_NOSSA(x+offset,y-offset,xRes,yRes));//up & right
        Cols.add(calcPixelColor_NOSSA(x-offset,y+offset,xRes,yRes));//down & left
        Cols.add(calcPixelColor_NOSSA(x+offset,y+offset,xRes,yRes));//down & Right
        Cols.add(calcPixelColor_NOSSA(x+offset,y+offset,xRes,yRes));//down & Right
        Cols.add(calcPixelColor_STOCHASTICSSA(x+offset,y+offset,xRes,yRes, 9, -(offset*2), (offset*2)));//add even more SSA
        
      for(float[] ff : Cols){
        RGBGlobal = new float[]{RGBGlobal[0]+ff[0],RGBGlobal[1]+ff[1],RGBGlobal[2]+ff[2]};
      }
      RGBGlobal = new float[]{RGBGlobal[0]/(11.0),RGBGlobal[1]/(11.0),RGBGlobal[2]/(11.0)};//average out pixels and return color
      return RGBGlobal;
    }
   
    float[] calcPixelColor_REGULARSSA_9(float x, float y, int xRes, int yRes, float offset){//SSA via grid patteren
      RGBGlobal = new float[]{0.0,0.0,0.0};
      
      ArrayList<float[]> Cols = new ArrayList<float[]>();
        Cols.add(calcPixelColor_NOSSA(x,y,xRes,yRes));//base ray
        Cols.add(calcPixelColor_NOSSA(x+offset,y,xRes,yRes));//right
        Cols.add(calcPixelColor_NOSSA(x-offset,y,xRes,yRes));//left
        Cols.add(calcPixelColor_NOSSA(x,y+offset,xRes,yRes));//down
        Cols.add(calcPixelColor_NOSSA(x,y-offset,xRes,yRes));//up
        Cols.add(calcPixelColor_NOSSA(x-offset,y-offset,xRes,yRes));//up & left
        Cols.add(calcPixelColor_NOSSA(x+offset,y-offset,xRes,yRes));//up & right
        Cols.add(calcPixelColor_NOSSA(x-offset,y+offset,xRes,yRes));//down & left
        Cols.add(calcPixelColor_NOSSA(x+offset,y+offset,xRes,yRes));//down & Right
        
      for(float[] ff : Cols){
        RGBGlobal = new float[]{RGBGlobal[0]+ff[0],RGBGlobal[1]+ff[1],RGBGlobal[2]+ff[2]};
      }
      RGBGlobal = new float[]{RGBGlobal[0]/(10.0),RGBGlobal[1]/(10.0),RGBGlobal[2]/(10.0)};//average out pixels and return color
      return RGBGlobal;
    }
    
    float[] calcPixelColor_REGULARSSA_5(float x, float y, int xRes, int yRes, float offset){//SSA via grid patteren
      RGBGlobal = new float[]{0.0,0.0,0.0};
      
      ArrayList<float[]> Cols = new ArrayList<float[]>();
        Cols.add(calcPixelColor_NOSSA(x,y,xRes,yRes));//base ray
        Cols.add(calcPixelColor_NOSSA(x+offset,y,xRes,yRes));//right
        Cols.add(calcPixelColor_NOSSA(x-offset,y,xRes,yRes));//left
        Cols.add(calcPixelColor_NOSSA(x,y+offset,xRes,yRes));//down
        Cols.add(calcPixelColor_NOSSA(x,y-offset,xRes,yRes));//up
        
      for(float[] ff : Cols){
        RGBGlobal = new float[]{RGBGlobal[0]+ff[0],RGBGlobal[1]+ff[1],RGBGlobal[2]+ff[2]};
      }
      RGBGlobal = new float[]{RGBGlobal[0]/(6.0),RGBGlobal[1]/(6.0),RGBGlobal[2]/(6.0)};//average out pixels and return color
      return RGBGlobal;
    }
   
   
  //Calcs first pass, looks for edges then gets next pass 
   PImage calcPixelColor_ADAPTIVESSA(int xMin, int yMin,int xMax, int yMax ,int xRes, int yRes){
    RGBGlobal = new float[]{0.0,0.0,0.0};
    //error check TODO
    //first pass
    int fpWidth = (int)((xMax)-xMin);
    int fpHeight = (int)((yMax)-yMin);
    
    PImage firstPass = new PImage(fpWidth,fpHeight);
    int xOffset = 0;
    int yOffset = 0;
    float[] fpRGB = new float[]{0.0,0.0,0.0};
    for(int i = xMin;i<=xMax;++i){
      for(int j = yMin;j<=yMax;++j){
        fpRGB = calcPixelColor_NOSSA(i,j,xRes,yRes);
        firstPass.pixels[fpWidth*yOffset+xOffset] = color(fpRGB[0]*255,fpRGB[1]*255,fpRGB[2]*255);
        
      }
     xOffset++;
     yOffset = 0; 
    }//first pass of image done!
    //get edges
    xOffset = 0;
    yOffset = 0;
    SobelEdgeDetection SB = new SobelEdgeDetection();
    PImage edgedFirst =  SB.findEdgesAll(firstPass,90);//we now have the edges
    //check edge response, if its beyond a certain threshold, supersample it to hell and gone
    float edgeOffset = 0.0;
    int k =0;
    int l = 0;
    ArrayList<float[]> PixelFlag = new ArrayList<float[]>();
    for(int i = 0;i<=fpWidth;++i)
      for(int j = 0;j<=fpHeight;++j){
        int amount = 0;
         for(k = i-1;k<(i+1);++k)
           for(l = j-1;l<(j+1);++l){
             if(k>0&&l>0)
               if(k<fpWidth&&l<fpHeight){
                 if (red(edgedFirst.pixels[fpWidth*l+k])==255)
                  ++amount; 
               }
           }
           edgeOffset = amount/9.0;
           if(edgeOffset>0.30){
             PixelFlag.add(new float[]{i,j});
           }
      }
     
      float[] NewRGB;
      for(float[] Coords : PixelFlag){
         NewRGB = calcPixelColor_REGULARSSA_9(Coords[0]+xMin,Coords[1]+yMin,xRes,yRes,0.1);
         firstPass.pixels[(int)(fpWidth*(Coords[1])+Coords[0])] = color(NewRGB[0]*255,NewRGB[1]*255,NewRGB[2]*255);
      }
    return firstPass; 
   }
   
   
     
  //PostFX
  
 float[] ApplyToneMap(float[] RGBIN){
   float kExposure = 0.8;
   
   float rTM =pow(52,RGBIN[0]-kExposure);
   float gTM =pow(52,RGBIN[1]-kExposure);
   float bTM =pow(52,RGBIN[2]-kExposure);
   
   return new float[]{rTM,gTM,bTM};
   
 }
 
 float[] ApplyGamma(float[] RGBIN, float gammeCoef){
   float rTM =pow(RGBIN[0],gammeCoef);
   float gTM =pow(RGBIN[1],gammeCoef);
   float bTM =pow(RGBIN[2],gammeCoef);
   return new float[]{rTM,gTM,bTM};
   
 }
  
  
  
  float[] rayTraceRefraction(PVector rayPos, PVector rayDir, int depth){//with refraction
    //constants to help keep state while tracing rays
    int lastHitID = 0;
    float ColMultiplier = 1.0;//used as a cutoff multiplier by reflections & refractions
    PVector rayToCamDir = rayDir;
    
    for(int index = 0;index<raybouncemax;++index){//max number of bounces
       CH = new CollisionHelper(); //reset this for new raytrace
       
       //check for interesection of all objects in scene
       //spheres
       for(rSphere rS : SceneH.Spheres){
         //not concerned if it is a light or not
         SphereIntersection(rS, CH, rayPos, rayDir, lastHitID);
       }
       //boxes
       for(rAABox rB : SceneH.AABoxes){
         //not concerned if it is a light or not
         // boolean AABoxintersection(rAABox inBox, CollisionHelper CH2, PVector rPos, PVector rDir, int ignorePrimitiveID){//rayAAboxinteresection
         AABoxintersection(rB, CH, rayPos, rayDir, lastHitID);
       }
       
       //planes
       for(rInfinitePlane rIP : SceneH.InfinitePlanes){
         //not concerned if it is a light or not
         InfinitePlaneIntersection(rIP, CH, rayPos, rayDir, lastHitID);
       }
       
       if(CH.foundhit){//we found a hit now check whats going on
         //apply lighting
         //add texture cols
         if(CH.HitObjectMaterial.hastex==true){//has texture now change the diffuse cols
           if(CH.type==2)//sphere
             CH.HitObjectMaterial.diffuseCol = SphereTextureMap(CH.Center,CH.intersectPoint, rayDir,CH);
            else if(CH.type==1)
              CH.HitObjectMaterial.diffuseCol = SquareTextureMap(CH.Center,CH.intersectPoint, rayDir,CH);
             else
              CH.HitObjectMaterial.diffuseCol = PlaneTextureMap(CH.Center,CH.intersectPoint, rayDir,CH,infinitetextureScale); 
         }
        
         for(rDirectionalLight rL: SceneH.DirectionalLights){
             RGBGlobal = ApplyDirLight(RGBGlobal, CH, rL, ColMultiplier, rayDir);
         }
         for(rPointLight pL: SceneH.PointLights){
             RGBGlobal = ApplyPointLight(RGBGlobal, CH, pL, ColMultiplier, rayDir);
         }
         //add ambience
         RGBGlobal = Mathutils.addFloat(RGBGlobal,Mathutils.toFloat(Mathutils.componentMult(Mathutils.scalarMult(CH.HitObjectMaterial.diffuseCol,CH.HitObjectMaterial.diffuseD*ColMultiplier),SceneH.Ambience.ambienceCol)));
         // + Emmisive for complete Phongmodel
         RGBGlobal = Mathutils.addFloat(RGBGlobal,Mathutils.toFloat(Mathutils.scalarMult(CH.HitObjectMaterial.emissiveCol,ColMultiplier)));
         //phong done!
         //refract
         if(CH.HitObjectMaterial.refractionAmnt>0.0){//object has refraction amount so do it!
           if(CH.inside)//insde means the normal must inverse because we may need to travel througnit
             CH.surfaceNormal = Mathutils.scalarMult(CH.surfaceNormal,-1.0);
             //as mentioned if we hit an object we gotta travel through it
             //therfore cant ignore it anymore
             lastHitID = 0;//reset
             //also need to move the ray a tiny amount pass the collision so no re-intersect occurs on the retrace
             rayPos = Mathutils.addVect(CH.intersectPoint,Mathutils.scalarMult(rayDir,0.0001));
             //and do the refraction according to snell law which is simplified as  R = eta * I - (eta * dot(N, I) + sqrt(k)) * N;
             rayDir = refract(rayToCamDir, CH.surfaceNormal,CH.HitObjectMaterial.refractIndex);
             ColMultiplier *= CH.HitObjectMaterial.refractionAmnt;
             if(ColMultiplier<0.06)
               return RGBGlobal;
             
         }else if(CH.HitObjectMaterial.reflectionD>0.0){//reflection?
           rayPos = CH.intersectPoint;
           rayDir = reflect(rayDir, CH.surfaceNormal);
           
           lastHitID = CH.id;
           ColMultiplier *= CH.HitObjectMaterial.reflectionD;
           if(ColMultiplier<0.06)
             return RGBGlobal;
         
         
         }else{//we are done!
           return RGBGlobal;
         }
         
       }else{//no hit ! return background col!
         return Mathutils.addFloat(RGBGlobal,Mathutils.toFloat(Mathutils.scalarMult(new PVector(0.1,0.1,0.1),ColMultiplier) ));
         
       }
        
    }
    return RGBGlobal;
    
  }
  
 
  
  //resources for optimiaztions http://tigrazone.narod.ru/raytrace2.htm
  boolean InfinitePlaneIntersection(rInfinitePlane inPlane, CollisionHelper CH2, PVector rPos, PVector rDir, int ignorePrimitiveID){
    //infinitePlane handling
    if(ignorePrimitiveID == inPlane.id)
      return false;
      
    PVector NAx = Mathutils.normalizeVect(inPlane.NAxis);
    //Ray plane intersection is fairly easy, solve for t=-(rPos dot N + offsetfromorigin)/(rDir dot N), if t <0.0 no intersect, else yes return true and update
    float rayMaxFram = 9999;
    if(CH2.collisionframe>0.0){
     rayMaxFram =CH2.collisionframe;
    }
    float t = -((Mathutils.dotProduct(rPos,NAx)+inPlane.distfromOrigin)/(Mathutils.dotProduct(rDir,NAx)));
    if(t<=0.0 || t>=rayMaxFram)
      return false;//no plane intersection
    
      
     PVector intersePT = Mathutils.addVect(rPos,Mathutils.scalarMult(rDir,t));
     //CH.inside =(t==0.0);//parallel again?
     
      CH.axis = getAxis(NAx);
      
     
     if(inPlane.distfromOrigin<0&&CH.axis==1){
       CH.surfaceNormal = Mathutils.scalarMult(NAx,-1.0);
       
     }
      else if(inPlane.distfromOrigin<0&&CH.axis==2){
         CH.surfaceNormal = Mathutils.scalarMult(NAx,-1.0);
   
    }else if(inPlane.distfromOrigin<0&&CH.axis==3){
       
       CH.surfaceNormal = Mathutils.scalarMult(NAx,-1.0);
      
     }else{
        CH.surfaceNormal =NAx ;
     }
     
     CH.collisionframe = t;
     CH.HitObjectMaterial = inPlane.MatType;
     CH.intersectPoint = intersePT;
      //normal calculation
    
      //update and return
     CH.foundhit = true;
     CH.id = inPlane.id;
     CH.Size = new PVector(999,999,999);//negative size to indicate infinity
     CH.Center = NAx;//no center as infinity
     CH.type = 3;
    
     
     if(inPlane.MatType.hasbumpmap){
       CH.surfaceNormal = computeIPlaneBumpMap(inPlane,CH);
     }
     return true;
  }
  
  PVector computeIPlaneBumpMap(rInfinitePlane inPlane, CollisionHelper CH2){
    //have to map the loaded texture UV coords as before with texture 
        // texture coordinates 
      PVector uaxis = new PVector(1.0,0.0,0.0);
      PVector vaxis = new PVector(0.0,1.0,0.0);
      
      if (CH2.axis == 1)
      {
        uaxis = new PVector(0.0,1.0,0.0);
        vaxis = new PVector(0.0,0.0,1.0);
      }
      else if (CH2.axis==2)
      {
        uaxis = new PVector(1.0,0.0,0.0);
        vaxis = new PVector(0.0,0.0,1.0);    
      }
   
    Mat3 BumpMapSpace = new Mat3(uaxis,vaxis, CH2.surfaceNormal);//matrix for finite difference calculation ie. barycentrix coords
    

    //get texture offsets
    float A = getPlaneTexelMap(CH2.Center,CH2.intersectPoint,CH2,infinitetextureScale,0,0);
    float B = getPlaneTexelMap(CH2.Center,CH2.intersectPoint,CH2,infinitetextureScale,1.5,0);
    float C = getPlaneTexelMap(CH2.Center,CH2.intersectPoint,CH2,infinitetextureScale,0,1.5);
    //got offset values now get new normal via finite difference
    PVector nNorm = Mathutils.normalizeVect(new PVector(B-A,C-A,0.15));
    return Mathutils.normalizeVect(Mathutils.MatrixVectorProduct(BumpMapSpace,nNorm));//altered normal
  }
  
  float getPlaneTexelMap(PVector Center, PVector intersectPoint, CollisionHelper CH2, int scalefactor, float xOffset, float yOffset){//returns a color for cube
        //gotta resize based off each axis
        float u = 0.0;
        float v = 0.0;
       if(CH2.axis==1){//XAxis
            u = (intersectPoint.z*scalefactor)%(float)CH2.HitObjectMaterial.BumpM.width;
            v = (intersectPoint.y*scalefactor)%(float)CH2.HitObjectMaterial.BumpM.height;
          
        }else if(CH2.axis==2){//yaxis
           u = (intersectPoint.x*scalefactor)%(float)CH2.HitObjectMaterial.BumpM.width;
           v = (intersectPoint.z*scalefactor)%(float)CH2.HitObjectMaterial.BumpM.height;
        
        }else{
          u = (intersectPoint.x*scalefactor)%(float)CH2.HitObjectMaterial.BumpM.width;
          v = (intersectPoint.y*scalefactor)%(float)CH2.HitObjectMaterial.BumpM.height;
        }
      
        u = abs(u);
        v = abs(v);
        int pX = (int)(u+xOffset) + (((int)(v+yOffset))*CH2.HitObjectMaterial.BumpM.width);
        int MaxVal = CH2.HitObjectMaterial.BumpM.height*CH2.HitObjectMaterial.BumpM.width;
        pX = abs(pX%MaxVal);
        color c = CH2.HitObjectMaterial.BumpM.pixels[pX];
        
        float Ave = (red(c)+green(c)+blue(c))/(3*255);
        return Ave;
  }
  
  boolean AABoxintersection(rAABox inBox, CollisionHelper CH2, PVector rPos, PVector rDir, int ignorePrimitiveID){//rayAAboxinteresection
    //intersecting a Axis aligned box requires assumptions that the box is alighned with coord system
    //take note of y = mx+c or O + Rt  and to get interesection we check all 4 axis and see if the ray will interesction one of theme
    //if it does we need to check if it is constrained into the area of the box, then we know the axis, (side of box it hits) and then we 
    //compute the normal of the side and compute the new ray references http://www.scratchapixel.com/lessons/3d-basic-lessons/lesson-7-intersecting-simple-shapes/ray-box-intersection/
    if(ignorePrimitiveID == inBox.id)
      return false;//this is not the box we are looking for....
      
    float rayMinframe = 0.0;
    float rayMaxframe = 999999;//max distances
    if(CH2.collisionframe>=0.0){
       rayMaxframe = CH2.collisionframe; 
    }
    //now we check the axes of the box for interesections
    //constants for axis checking
    float aboxpos = 0.0, aboxscale = 0.0, arayDir = 0.0, arayPos = 0.0; 
    for(int axis = 0;axis<3;++axis){
      switch(axis){//get values axis based
         case  0:
             aboxpos = inBox.Position.x;
             aboxscale = inBox.Scale.x;
             arayPos = rPos.x;
             arayDir = rDir.x;
           break;
         case 1:
             aboxpos = inBox.Position.y;
             aboxscale = inBox.Scale.y;
             arayPos = rPos.y;
             arayDir = rDir.y;
           break;
         case 2:
             aboxpos = inBox.Position.z;
             aboxscale = inBox.Scale.z;
             arayPos = rPos.z;
             arayDir = rDir.z;
           break;
         default:
           return false;
      } 
      
    //get max and min of box on this axis x->y->z
      float axisMin =  aboxpos - aboxscale*0.5;
      float axisMax = axisMin + aboxscale;
      if(abs(arayDir)<0.0001){//parallel?, 0.0001 is accuaracy factor, may be very very close to parallel may be not
        if(arayPos<axisMin || arayPos>axisMax)//are we inside box?
          return false;//nope we arent ie no col
      }else{
          //what frame/distance max and min of interesection with box and the 2 axis values
         float axisminFrame = (axisMin - arayPos)/arayDir;
         float axismaxframe = (axisMax - arayPos)/arayDir;
         if(axisminFrame>axismaxframe){//is min<max? else swap
            float temp = axisminFrame;
            axisminFrame = axismaxframe;
            axismaxframe = temp;
         }
         
        if(axisminFrame>rayMinframe)//make sure our frames of reference are within the same bounds
            rayMinframe = axisminFrame;//this is essentially the distances that can be used for the 
        if(axismaxframe<rayMaxframe)//   constraint of the box
            rayMaxframe = axismaxframe;
            
        if(rayMinframe>rayMaxframe)
            return false;//the max and min difference are no longer within the bounds therefore no interesect
        }//else
      }//first for
      
      //we made it, the ray falls within the bounding frame of the box therefore interesection! 
      //but with what axis?
      CH.inside = (rayMinframe==0.0);//parallel again?
      if(CH.inside)
        CH.collisionframe = rayMaxframe;
      else
        CH.collisionframe = rayMinframe;
        
      CH.HitObjectMaterial = inBox.MatType;
      CH.intersectPoint = Mathutils.addVect(rPos,Mathutils.scalarMult(rDir,CH.collisionframe));
      
      float closestDisttobox = 99999;
      //again need to find what axis we working with (find closest distance) & then get its normal
      float interesectPointAxis = 0.0;
      for(int laxis = 0;laxis<3;++laxis){
        switch(laxis){//get values axis based
         case  0:
             aboxpos = inBox.Position.x;
             aboxscale = inBox.Scale.x;
             arayPos = rPos.x;
             arayDir = rDir.x;
             interesectPointAxis = CH.intersectPoint.x;
           break;
         case 1:
             aboxpos = inBox.Position.y;
             aboxscale = inBox.Scale.y;
             arayPos = rPos.y;
             arayDir = rDir.y;
             interesectPointAxis = CH.intersectPoint.y;
           break;
         case 2:
             aboxpos = inBox.Position.z;
             aboxscale = inBox.Scale.z;
             arayPos = rPos.z;
             arayDir = rDir.z;
             interesectPointAxis = CH.intersectPoint.z;
           break;
         default:
           //return false;
        }
       float distancefromPos = abs(aboxpos-interesectPointAxis); 
       float distanceFromEdge = abs(distancefromPos-(aboxscale*0.5));
       if(distanceFromEdge<closestDisttobox){
         closestDisttobox = distanceFromEdge;
         CH.surfaceNormal = new PVector(0.0,0.0,0.0);
         float normalVal = 0.0;
         if(interesectPointAxis<aboxpos)
            normalVal = -1.0; 
         else
           normalVal = 1.0;//already a normal
         switch(laxis){
           case 0:
               CH.surfaceNormal.x = normalVal;
             break;
           case 1:
                CH.surfaceNormal.y = normalVal;
             break;
           case 2:
                CH.surfaceNormal.z = normalVal;
             break;
           default:
            // return false;
         }//end of 2nd case
       }//end of normal calc if      
        
      }//end of 2nd for
      
    
    CH.foundhit = true;//and we have a hit!
    CH.id = inBox.id;//id
    CH.Size = inBox.Scale;//set scale for texture if necessary
    CH.Center = inBox.Position;//and the center posistion
    CH.type = 1;//box
    CH.axis = getAxis(CH.surfaceNormal);//getting axis for texturing
      //compute bump map
    if(inBox.MatType.hasbumpmap){
      if(CH.inside)//insde means the normal must inverse because we may need to travel througnit
            CH.surfaceNormal = Mathutils.scalarMult(CH.surfaceNormal,-1.0);
      CH.surfaceNormal = computeAAboxBumpMap(inBox,CH); 
      if(CH.inside)//insde means the normal must inverse because we may need to travel througnit
              CH.surfaceNormal = Mathutils.scalarMult(CH.surfaceNormal,-1.0);   
    }
    return true;
  }
  
  int getAxis(PVector SurfaceNormal){
     if(SurfaceNormal.x!=0.0)
      return 1;
     else if(SurfaceNormal.y!=0.0)
      return 2;
     else
      return 3; 
  }
 
  //bumpmap for AABox
  PVector computeAAboxBumpMap(rAABox inBox, CollisionHelper CH2){
    //have to map the loaded texture UV coords as before with texture 
        // texture coordinates 
      PVector uaxis = new PVector(1.0,0.0,0.0);
      PVector vaxis = new PVector(0.0,1.0,0.0);
      
      if (CH2.axis == 1)
      {
        uaxis = new PVector(0.0,1.0,0.0);
        vaxis = new PVector(0.0,0.0,1.0);
      }
      else if (CH2.axis==2)
      {
        uaxis = new PVector(1.0,0.0,0.0);
        vaxis = new PVector(0.0,0.0,1.0);    
      }
   
    Mat3 BumpMapSpace = new Mat3(uaxis,vaxis, CH2.surfaceNormal);//matrix for finite difference calculation ie. barycentrix coords
    

    //get texture offsets
    float A = getTexAAboxVal(CH2.Center,CH2.intersectPoint,CH2,0,0);
    float B = getTexAAboxVal(CH2.Center,CH2.intersectPoint,CH2,1.5,0);
    float C = getTexAAboxVal(CH2.Center,CH2.intersectPoint,CH2,0,1.5);
    //got offset values now get new normal via finite difference
    PVector nNorm = Mathutils.normalizeVect(new PVector(A-B,A-C,0.15));
    return Mathutils.normalizeVect(Mathutils.MatrixVectorProduct(BumpMapSpace,nNorm));//altered normal
  }
  
  
  float getTexAAboxVal(PVector Center, PVector intersectPoint, CollisionHelper CH2, float XOffset, float yOffset){//returns a color for cube
        //gotta resize based off each axis
        float u = 0.0;
        float v = 0.0;
        if(CH2.axis==1){//XAxis
            u = map(intersectPoint.z,Center.z-CH2.Size.z/2,Center.z+CH2.Size.z/2,0.0,(float)CH2.HitObjectMaterial.BumpM.width);
            v = map(intersectPoint.y,Center.y-CH2.Size.y/2,Center.y+CH2.Size.y/2,0.0,(float)CH2.HitObjectMaterial.BumpM.height);
          
        }else if(CH2.axis==2){//yaxis
           u = map(intersectPoint.x,Center.x-CH2.Size.x/2,Center.x+CH2.Size.x/2,0.0,(float)CH2.HitObjectMaterial.BumpM.width);
           v = map(intersectPoint.z,Center.z-CH2.Size.z/2,Center.z+CH2.Size.z/2,0.0,(float)CH2.HitObjectMaterial.BumpM.height);
        
        }else{
          u = map(intersectPoint.x,Center.x-CH2.Size.x/2,Center.x+CH2.Size.x/2,0.0,(float)CH2.HitObjectMaterial.BumpM.width);
          v = map(intersectPoint.y,Center.y-CH2.Size.y/2,Center.y+CH2.Size.y/2,0.0,(float)CH2.HitObjectMaterial.BumpM.height);
        }
       
      
        
        int pX = (int)(u+XOffset) + (((int)(v+yOffset))*CH2.HitObjectMaterial.BumpM.width);
        int MaxVal = CH2.HitObjectMaterial.BumpM.height*CH2.HitObjectMaterial.BumpM.width;
        pX = abs(pX%MaxVal);
        
        color c = CH2.HitObjectMaterial.BumpM.pixels[pX];
        float Ave = (red(c)+green(c)+blue(c))/(3*255);
        return Ave;
  }
  
  boolean SphereIntersection(rSphere inSphere, CollisionHelper CH2, PVector rPos, PVector rDir, int ignorePrimitiveID){//Ray Sphere interesection
       //simplified formula assuming rDir is normalized therfore use quadratic equation in parts and gate it so that we can invrease performance
      //Collision info is used to keep track of the point of interesection and object interesection so that we have a globabl refereence for easy use
      if(ignorePrimitiveID == inSphere.id)
        return false;//ignore it no interesect
      
      PVector rsCenter = Mathutils.subVect(rPos,inSphere.Center);//ray sphere centere ray
      float b = Mathutils.dotProduct(rsCenter,rDir);
      float c = Mathutils.dotProduct(rsCenter,rsCenter) - inSphere.radius*inSphere.radius;
      
      if(c>0.0 && b>0.0){
         return false;//r origin is outides sphere & r pointing away therefore exit 
      }
      
      float discrim = (b*b)-c;//discriminate
      if(discrim<0.0)
        return false;//- equates to a miss
      
      boolean fromInside = false;//nned to proove if its inside or not
      float colFrame = -b-sqrt(discrim);//ray found now compute smallest t value of quadrat equaution
      
      if(colFrame<0.0){
         colFrame = -b+sqrt(discrim);//remember there are 2 cases +- sqrt of discrimim 
         fromInside = true;//we inside now  
      }
      //max distance for ray
      if(CH2.collisionframe>=0.0 && colFrame> CH2.collisionframe)
        return false;
      //set our collisioninfo globals so that we know whats going on
      //we now have a hit & must deal with it appropriately
      CH.inside = fromInside;
      CH.collisionframe =  colFrame;
      CH.HitObjectMaterial = inSphere.MatType;
      CH.intersectPoint = Mathutils.addVect(rPos,Mathutils.scalarMult(rDir,colFrame));
      //normal calculation
      CH.surfaceNormal = Mathutils.subVect(CH.intersectPoint,inSphere.Center);
      CH.surfaceNormal = Mathutils.normalizeVect(CH.surfaceNormal);
      if(inSphere.MatType.hasbumpmap){//compute bumpmap normals
        if(CH.inside)
          CH.surfaceNormal = Mathutils.scalarMult(CH.surfaceNormal,-1.0);
         CH.surfaceNormal = computeSphereBumpMap(inSphere, CH);
         if(CH.inside)
          CH.surfaceNormal = Mathutils.scalarMult(CH.surfaceNormal,-1.0);
       
      }
      //update and return
      CH.foundhit = true;
      CH.id = inSphere.id;
      CH.Size = new PVector(inSphere.radius,inSphere.radius,inSphere.radius);//set scale for texture if necessary
      CH.Center = inSphere.Center;//and the center posistion
      CH.type = 2;
      return true;
  }
  
  //bumpmap for spheres
  PVector computeSphereBumpMap(rSphere insphere, CollisionHelper CH2){
    //have to map the loaded texture UV coords as before with texture
    PVector Normals = Mathutils.normalizeVect(Mathutils.subVect(CH2.intersectPoint,insphere.Center));
    float texCoordX = 0.5+atan2(Normals.z, Normals.x)/(2*PI);
    float texCoordY =0.5-asin(Normals.y)/(PI);
   
    //bump map here create u & v coords ang get offsets
    PVector uAxis = Mathutils.normalizeVect(Mathutils.crossProduct(new PVector(0.0,1.0,0.0),CH2.surfaceNormal));
    PVector vAxis = Mathutils.normalizeVect(Mathutils.crossProduct(uAxis,CH2.surfaceNormal));
    Mat3 BumpMapSpace = new Mat3(uAxis,vAxis, CH2.surfaceNormal);//matrix for finite difference calculation ie. barycentrix coords
    
    float texCoordOffset = -1.0/512.0;
    //get texture offsets
    float A = getTexValSphere(texCoordX,texCoordY,CH2);
    float B = getTexValSphere(texCoordX+texCoordOffset,texCoordY,CH2);
    float C = getTexValSphere(texCoordX,texCoordY+texCoordOffset,CH2);   
    //got offset values now get new normal via finite difference
    PVector nNorm = Mathutils.normalizeVect(new PVector(B-A,C-A,0.25));
    return Mathutils.normalizeVect(Mathutils.MatrixVectorProduct(BumpMapSpace,nNorm));//altered normal
  }
  
  float getTexValSphere(float TexCoordX, float TexCoordY, CollisionHelper CH2){
    
    int pWidth = (int)(TexCoordX*CH2.HitObjectMaterial.BumpM.width);
    int pHeight = (int)(TexCoordY*CH2.HitObjectMaterial.BumpM.height);
    int pX = pWidth + (pHeight*CH2.HitObjectMaterial.BumpM.width);
    int MaxVal = CH2.HitObjectMaterial.BumpM.height*CH2.HitObjectMaterial.BumpM.width;
    pX = abs(pX%MaxVal);
    color c = CH2.HitObjectMaterial.BumpM.pixels[pX];
    float Ave = (red(c)+green(c)+blue(c))/(3*255);
    return Ave;
  
  }
  
  boolean PointToPointCheck(PVector startPos, PVector targetPos, int ignorePrimID){//can two points see each other directly?
    //used for shadows 
    CHTemp = new CollisionHelper(CH);//create a copy
    CH = new CollisionHelper();//clear old
    PVector rayDir = Mathutils.subVect(targetPos,startPos);
    CH.collisionframe = rayDir.mag();
    rayDir = Mathutils.normalizeVect(rayDir);
    //run interesection against everything that isnt a lightsource and then return true on first hit
    //spheres
    
     
    
    for(rSphere rS : SceneH.Spheres){
        if(rS.lightSource==false){
         if(SphereIntersection(rS, CH, startPos, rayDir, ignorePrimID)){
           //we have a hit! return false but restore collision var
           CH = new CollisionHelper(CHTemp);
           return false;
         }
        }
    }
     CH = new CollisionHelper();//clear old
     rayDir = Mathutils.subVect(targetPos,startPos);
     CH.collisionframe = rayDir.mag();
     rayDir = Mathutils.normalizeVect(rayDir);
    //boxes
    //spheres
    for(rAABox rB : SceneH.AABoxes){
        if(rB.lightSource==false){
         if(AABoxintersection(rB, CH, startPos, rayDir, ignorePrimID)){
           //we have a hit! return false but restore collision var
           CH = new CollisionHelper(CHTemp);
           return false;
         }
        }
    }//end for
     CH = new CollisionHelper();//clear old
     rayDir = Mathutils.subVect(targetPos,startPos);
     CH.collisionframe = rayDir.mag();
     rayDir = Mathutils.normalizeVect(rayDir);
    //planes
    for(rInfinitePlane rIP : SceneH.InfinitePlanes){
         //not concerned if it is a light or not
         if(rIP.lightSource==false)
           if(InfinitePlaneIntersection(rIP, CH, startPos, rayDir, ignorePrimID)){
             CH = new CollisionHelper(CHTemp);
             return false;
           }
    }
    
   
    CH = new CollisionHelper(CHTemp);
    return true;//thePoint can see the other point!!!!
  }
  
  
  
  float[] ApplyPointLight(float[] PixelCol, CollisionHelper CH2, rPointLight pLights, float refleamnt, PVector rDir){//applys lighint model to the pixelcolor float and returns the new one
    float[] rettie = PixelCol;
    if(PointToPointCheck(CH2.intersectPoint,pLights.lightPosition,CH2.id)){//shadow ray calc
      //diffuse
      PVector hitLight = Mathutils.normalizeVect(Mathutils.subVect(pLights.lightPosition,CH2.intersectPoint));
      float dp = Mathutils.dotProduct(CH2.surfaceNormal,hitLight);
      if(dp>0.0){
             rettie = Mathutils.addFloat(rettie,Mathutils.toFloat(Mathutils.componentMult(Mathutils.scalarMult(CH2.HitObjectMaterial.diffuseCol,(dp)),Mathutils.scalarMult(pLights.lightCol,CH2.HitObjectMaterial.diffuseD*refleamnt))));
      }
        
      //specular
      PVector reflection = reflect(hitLight, CH2.surfaceNormal);
      dp = Mathutils.dotProduct(rDir,reflection);
      if(dp>0.0){
        float specPow = pow(dp, CH2.HitObjectMaterial.specularE);
        PVector specVec = Mathutils.scalarMult(CH2.HitObjectMaterial.specularCol,specPow);
        PVector lColrefl = Mathutils.scalarMult(pLights.lightCol,refleamnt);
        rettie = Mathutils.addFloat(rettie,Mathutils.toFloat(Mathutils.componentMult(specVec,lColrefl)));
      }
      
      
    }
    return rettie;
  }
  
  float[] ApplyDirLight(float[] PixelCol, CollisionHelper CH2, rDirectionalLight rLights, float refleamnt, PVector rDir){//applys lighint model to the pixelcolor float and returns the new one
    float[] rettie = PixelCol;
    PVector tDirPos = Mathutils.addVect(CH2.intersectPoint,Mathutils.scalarMult(rLights.lightDirectionreverse,1000));
    if(PointToPointCheck(CH2.intersectPoint,tDirPos,CH2.id)){//shadow ray calc
      //diffuse
      float dp = Mathutils.dotProduct(CH2.surfaceNormal,rLights.lightDirectionreverse);
      if(dp>0.0){
        PVector diffuseMul = Mathutils.scalarMult(CH2.HitObjectMaterial.diffuseCol,dp);
        PVector lightDif = Mathutils.scalarMult(rLights.lightCol,CH2.HitObjectMaterial.diffuseD*refleamnt);
        rettie = Mathutils.addFloat(rettie,Mathutils.toFloat(Mathutils.componentMult(diffuseMul,lightDif)));
      }
        
      //specular
      PVector reflection = reflect(rLights.lightDirectionreverse, CH2.surfaceNormal);
      dp = Mathutils.dotProduct(rDir,reflection);
      if(dp>0.0){
        float specPow = pow(dp, CH2.HitObjectMaterial.specularE);
        PVector specVec = Mathutils.scalarMult(CH2.HitObjectMaterial.specularCol,specPow);
        PVector lColrefl = Mathutils.scalarMult(rLights.lightCol,refleamnt);
        rettie = Mathutils.addFloat(rettie,Mathutils.toFloat(Mathutils.componentMult(specVec,lColrefl)));
      }
    }
    return rettie;
  }
  
  PVector reflect(PVector I, PVector Nn){//Reflect a vector given incident ray and normal
  //given as I - 2.0*dot(N,I)*N;
  //assume N is normalized
    PVector N = Mathutils.normalizeVect(Nn);
    float temp = (2.0)*Mathutils.dotProduct(N,I);
    PVector tVect = Mathutils.subVect(I,Mathutils.scalarMult(N,temp));
  
    return tVect;
  }
  
  PVector refract(PVector I, PVector N, float eta){//calculate refraction as per https://www.opengl.org/sdk/docs/man/html/refract.xhtml
    float INdot = Mathutils.dotProduct(N,I);
    float k = 1.0-eta*eta*(1.0-INdot*INdot);
    if(k<0.0){
       return new PVector(0.0,0.0,0.0);// 
    }else{
       float Nt = eta*INdot+sqrt(k);
       PVector Ieta = Mathutils.scalarMult(I,eta);
       PVector Nnt = Mathutils.scalarMult(N,Nt);
      return Mathutils.subVect(Ieta,Nnt); 
    }
    
  }
  
  PVector SphereTextureMap(PVector Center, PVector intersectPoint, PVector Ray, CollisionHelper CH2){//returns a color for sphere
        PVector Normals = Mathutils.normalizeVect(Mathutils.subVect(intersectPoint,Center));
       
        float u = 0.5 +atan2(Normals.z,Normals.x)/(2*PI);
        float v = 0.5 -asin(Normals.y)/(PI);
       
        int pWidth = (int)(u*CH2.HitObjectMaterial.Tex.width);
        int pHeight = (int)(v*CH2.HitObjectMaterial.Tex.height);
        
        int pX = pWidth + (pHeight*CH2.HitObjectMaterial.Tex.width);
        int MaxVal = CH2.HitObjectMaterial.Tex.height*CH2.HitObjectMaterial.Tex.width;
        pX = abs(pX%MaxVal);
        color c = CH2.HitObjectMaterial.Tex.pixels[pX];
        
        return new PVector(red(c)/255,green(c)/255,blue(c)/255);
  }
  
  
  //http://www.flipcode.com/archives/Raytracing_Topics_Techniques-Part_6_Textures_Cameras_and_Speed.shtml
  PVector SphereTextureMapBilinear(PVector Center, PVector intersectPoint, PVector Ray, CollisionHelper CH2){//returns a color for sphere
        PVector Normals = Mathutils.normalizeVect(Mathutils.subVect(intersectPoint,Center));
       
        float u = 0.5 +atan2(Normals.z,Normals.x)/(2*PI);
        float v = 0.5 -asin(Normals.y)/(PI);
       
        int pWidth = (int)(u*CH2.HitObjectMaterial.Tex.width);
        int pHeight = (int)(v*CH2.HitObjectMaterial.Tex.height);
        
        int pX = pWidth + (pHeight*CH2.HitObjectMaterial.Tex.width);
        int MaxVal = CH2.HitObjectMaterial.Tex.height*CH2.HitObjectMaterial.Tex.width;
        pX = abs(pX%MaxVal);
        color c = CH2.HitObjectMaterial.Tex.pixels[pX];
        
        return new PVector(red(c)/255,green(c)/255,blue(c)/255);
  }
  
  PVector SquareTextureMap(PVector Center, PVector intersectPoint, PVector Ray, CollisionHelper CH2){//returns a color for cube
        //gotta resize based off each axis
        float u = 0.0;
        float v = 0.0;
        if(CH2.axis==1){//XAxis
            u = map(intersectPoint.z,Center.z-CH2.Size.z/2,Center.z+CH2.Size.z/2,0.0,(float)CH2.HitObjectMaterial.Tex.width);
            v = map(intersectPoint.y,Center.y-CH2.Size.y/2,Center.y+CH2.Size.y/2,0.0,(float)CH2.HitObjectMaterial.Tex.height);
          
        }else if(CH2.axis==2){//yaxis
           u = map(intersectPoint.x,Center.x-CH2.Size.x/2,Center.x+CH2.Size.x/2,0.0,(float)CH2.HitObjectMaterial.Tex.width);
           v = map(intersectPoint.z,Center.z-CH2.Size.z/2,Center.z+CH2.Size.z/2,0.0,(float)CH2.HitObjectMaterial.Tex.height);
        
        }else{
          u = map(intersectPoint.x,Center.x-CH2.Size.x/2,Center.x+CH2.Size.x/2,0.0,(float)CH2.HitObjectMaterial.Tex.width);
          v = map(intersectPoint.y,Center.y-CH2.Size.y/2,Center.y+CH2.Size.y/2,0.0,(float)CH2.HitObjectMaterial.Tex.height);
        }
       
      
        
        int pX = (int)(u) + (((int)(v))*CH2.HitObjectMaterial.Tex.width);
        int MaxVal = CH2.HitObjectMaterial.Tex.height*CH2.HitObjectMaterial.Tex.width;
        pX = abs(pX%MaxVal);
        
        color c = CH2.HitObjectMaterial.Tex.pixels[pX];
        
        return new PVector(red(c)/255,green(c)/255,blue(c)/255);
  }
  
  
  PVector PlaneTextureMap(PVector Center, PVector intersectPoint, PVector Ray, CollisionHelper CH2, int scalefactor){//returns a color for cube
        //gotta resize based off each axis
        float u = 0.0;
        float v = 0.0;
       if(CH2.axis==1){//XAxis
            u = (intersectPoint.z*scalefactor)%(float)CH2.HitObjectMaterial.Tex.width;
            v = (intersectPoint.y*scalefactor)%(float)CH2.HitObjectMaterial.Tex.height;
          
        }else if(CH2.axis==2){//yaxis
           u = (intersectPoint.x*scalefactor)%(float)CH2.HitObjectMaterial.Tex.width;
           v = (intersectPoint.z*scalefactor)%(float)CH2.HitObjectMaterial.Tex.height;
        
        }else{
          u = (intersectPoint.x*scalefactor)%(float)CH2.HitObjectMaterial.Tex.width;
          v = (intersectPoint.y*scalefactor)%(float)CH2.HitObjectMaterial.Tex.height;
        }
      
        u = abs(u);
        v = abs(v);
        int pX = (int)(u) + (((int)(v))*CH2.HitObjectMaterial.Tex.width);
        int MaxVal = CH2.HitObjectMaterial.Tex.height*CH2.HitObjectMaterial.Tex.width;
        pX = abs(pX%MaxVal);
        color c = CH2.HitObjectMaterial.Tex.pixels[pX];
        
        return new PVector(red(c)/255,green(c)/255,blue(c)/255);
  }
  
  

  
  
  
  
  
  
  
  
  ///////////////////////////////////////////////////////////////////////////////////////////////Broken stuff below here!!!//////////////////////////////////
  
  //broken lol
   boolean PointToPointCheckRefractFixOLD(PVector startPos, PVector targetPos, int ignorePrimID, float ColMultiplier){//can two points see each other directly?
    //used for shadows 
    PVector rayToCamDir = startPos;
    if(CHRefract==null){
      CHRefract = new CollisionHelper(CH);//bigger backup
    }
    CHTemp = new CollisionHelper(CH);//create a copy
    CH = new CollisionHelper();//clear old
    PVector rayDir = Mathutils.subVect(targetPos,startPos);
    CH.collisionframe = rayDir.mag();
    rayDir = Mathutils.normalizeVect(rayDir);
    //run interesection against everything that isnt a lightsource and then return true on first hit
    //spheres
    
     //planes
    for(rInfinitePlane rIP : SceneH.InfinitePlanes){
         //not concerned if it is a light or not
         if(rIP.lightSource==false)
           if(InfinitePlaneIntersection(rIP, CH, startPos, rayDir, ignorePrimID)){//intersect but refraction?
             //refract
           if(CH.HitObjectMaterial.refractionAmnt>0.0){//object has refraction amount so do it!
             if(CH.inside)//insde means the normal must inverse because we may need to travel througnit
               CH.surfaceNormal = Mathutils.scalarMult(CH.surfaceNormal,-1.0);
               //as mentioned if we hit an object we gotta travel through it
               //therfore cant ignore it anymore
               ignorePrimID = 0;//reset
               //also need to move the ray a tiny amount pass the collision so no re-intersect occurs on the retrace
               startPos = Mathutils.addVect(CH.intersectPoint,Mathutils.scalarMult(rayDir,0.0001));
               //and do the refraction according to snell law which is simplified as  R = eta * I - (eta * dot(N, I) + sqrt(k)) * N;
               rayDir = refract(rayToCamDir, CH.surfaceNormal,CH.HitObjectMaterial.refractIndex);
               ColMultiplier *= CH.HitObjectMaterial.refractionAmnt;
               if(ColMultiplier<0.1){
                 CH = new CollisionHelper(CHTemp);
                 return false;
               }else{
                 boolean bFlag = PointToPointCheckRefractFixOLD(rayDir,targetPos, ignorePrimID, ColMultiplier);
                 CH = new CollisionHelper(CHRefract);
                 return bFlag;
               }
           }
           else{//normal collision shadow ray handling
             CH = new CollisionHelper(CHTemp);
             return false;
           }
             
        }
    }
    
    for(rSphere rS : SceneH.Spheres){
        if(rS.lightSource==false){
         if(SphereIntersection(rS, CH, startPos, rayDir, ignorePrimID)){
           //we have a hit! return false but restore collision var
           if(CH.HitObjectMaterial.refractionAmnt>0.0){//object has refraction amount so do it!
             if(CH.inside)//insde means the normal must inverse because we may need to travel througnit
               CH.surfaceNormal = Mathutils.scalarMult(CH.surfaceNormal,-1.0);
               //as mentioned if we hit an object we gotta travel through it
               //therfore cant ignore it anymore
               ignorePrimID = 0;//reset
               //also need to move the ray a tiny amount pass the collision so no re-intersect occurs on the retrace
               startPos = Mathutils.addVect(CH.intersectPoint,Mathutils.scalarMult(rayDir,0.0001));
               //and do the refraction according to snell law which is simplified as  R = eta * I - (eta * dot(N, I) + sqrt(k)) * N;
               rayDir = refract(rayToCamDir, CH.surfaceNormal,CH.HitObjectMaterial.refractIndex);
               ColMultiplier *= CH.HitObjectMaterial.refractionAmnt;
               if(ColMultiplier<0.1){
                 CH = new CollisionHelper(CHTemp);
                 return false;
               }else{
                 boolean bFlag = PointToPointCheckRefractFixOLD(rayDir,targetPos, ignorePrimID, ColMultiplier);
                 CH = new CollisionHelper(CHRefract);
                 return bFlag;
               }
           }
           else{//normal collision shadow ray handling
             CH = new CollisionHelper(CHTemp);
             return false;
           }
         }
        }
    }
    //boxes
    //spheres
    for(rAABox rB : SceneH.AABoxes){
        if(rB.lightSource==false){
         if(AABoxintersection(rB, CH, startPos, rayDir, ignorePrimID)){
           //we have a hit! return false but restore collision var
           if(CH.HitObjectMaterial.refractionAmnt>0.0){//object has refraction amount so do it!
             if(CH.inside)//insde means the normal must inverse because we may need to travel througnit
               CH.surfaceNormal = Mathutils.scalarMult(CH.surfaceNormal,-1.0);
               //as mentioned if we hit an object we gotta travel through it
               //therfore cant ignore it anymore
               ignorePrimID = 0;//reset
               //also need to move the ray a tiny amount pass the collision so no re-intersect occurs on the retrace
               startPos = Mathutils.addVect(CH.intersectPoint,Mathutils.scalarMult(rayDir,0.0001));
               //and do the refraction according to snell law which is simplified as  R = eta * I - (eta * dot(N, I) + sqrt(k)) * N;
               rayDir = refract(rayToCamDir, CH.surfaceNormal,CH.HitObjectMaterial.refractIndex);
               ColMultiplier *= CH.HitObjectMaterial.refractionAmnt;
               if(ColMultiplier<0.1){
                 CH = new CollisionHelper(CHTemp);
                 return false;
               }else{
                 boolean bFlag = PointToPointCheckRefractFixOLD(rayDir,targetPos, ignorePrimID, ColMultiplier);
                 CH = new CollisionHelper(CHRefract);
                 return bFlag;
               }
           }
           else{//normal collision shadow ray handling
             CH = new CollisionHelper(CHTemp);
             return false;
           }
         }
        }
    }//end for
    
    
   
    CH = new CollisionHelper(CHTemp);
    return true;//thePoint can see the other point!!!!
  }
  
  
}
