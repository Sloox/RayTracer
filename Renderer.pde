//basic class to render a scene
//renders pixel by pixel keeping all vars in global state for return to main screen
import java.lang.Math;
class Renderer{
  
  
  //globals for state
    vMath Mathutils;
    RendererCamera rCam;
    int raybouncemax = 12;
    CollisionHelper CH, CHTemp, CHRefract;//CHTemp used in PointToPointCheck to keep original CH state
    SceneHandler SceneH;
    float[] RGBGlobal;
    
    int infinitetextureScale = 32;//for infinte planes
    float TEXFILTEROFFSET = 0.05;
    int rendertype = 2;
    float[] RGBDEBEEROFFSET = new float[]{1.0,1.0,1.0};
    boolean AO = true;
    int AORAYS = 64;
    
    boolean PFXGamma = false;
    float gamma;
    
    boolean TMap = false;
    float kexp;
    int kpower;
    
    boolean ConstrainBrightness = true;
    
    int MAXRENDERDISTANCE = 999;
     PVector Reso, ScreenVecorLocation;
    
  Renderer(PVector MPos, PVector Res, int _raybouncemax, float _gamma){//constructor
    Mathutils = new vMath();
    raybouncemax = _raybouncemax;
    Reso = Res;
    //Asuming default for now
    //SceneH = new SceneHandler(sketchPath("data\\Scenes\\Lorem.txt"));
    //SceneH = new SceneHandler(sketchPath("data\\Scenes\\tunnel.txt"));
   // SceneH = new SceneHandler(sketchPath("data\\Scenes\\Stest.txt"));
    //SceneH = new SceneHandler(sketchPath("data\\Scenes\\planet.txt"));
    // SceneH = new SceneHandler(sketchPath("data\\Scenes\\planes.txt"));
    SceneH = new SceneHandler(sketchPath("data\\Scenes\\air.txt"));
    //SceneH = new SceneHandler(sketchPath("data\\Scenes\\CTtest.txt"));
  //SceneH = new SceneHandler();
    rCam = new RendererCamera( MPos, Res, new PVector(0.0,0.0,0.0));
    RGBGlobal = new float[]{0.0,0.0,0.0}; RGBDEBEEROFFSET = new float[]{1.0,1.0,1.0};
    gamma = _gamma;
    //LoadConfig(sketchPath("data\\Config\\C1.txt"));
    
  }
  
  
  
  
  void updateCamMouse(PVector MPos, PVector Res){
     rCam = new RendererCamera( MPos, Res, new PVector(0.0,0.0,0.0));
  }
  
  
  
  //base raytracing 
  float[] calcPixelColor_NOSSA(float x, float y, int xRes, int yRes){
    RGBGlobal = new float[]{0.0,0.0,0.0}; RGBDEBEEROFFSET = new float[]{1.0,1.0,1.0}; 
    //screen coords   
    PVector screenVec = new PVector(x,y);
    ScreenVecorLocation = screenVec.get();
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
    RGBGlobal =new float[]{RGBGlobal[0]*0.55,RGBGlobal[1]*0.55,RGBGlobal[2]*0.55};
    
    return ApplyPostFX(RGBGlobal) ; 
   }
   
   
  
   
   
  //random offset for each pixel
  float[] calcPixelColor_STOCHASTICSSA(float x, float y, int xRes, int yRes, int Samples, float offsetMin, float offsetMax){
    RGBGlobal = new float[]{0.0,0.0,0.0}; RGBDEBEEROFFSET = new float[]{1.0,1.0,1.0};
    //screen coords   
    PVector screenVec = new PVector(x,y);
    ScreenVecorLocation = screenVec.get();
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
   
    
    return ApplyPostFX(RGBGlobal); 
   }
   
   
   
   float[] calcPixelColor_STOCHASTICREGULARSSA_18(float x, float y, int xRes, int yRes, float offset){//SSA via grid patteren
      RGBGlobal = new float[]{0.0,0.0,0.0}; RGBDEBEEROFFSET = new float[]{1.0,1.0,1.0};
      ScreenVecorLocation = new PVector(x,y);
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
      RGBGlobal = new float[]{RGBGlobal[0]/(14.0),RGBGlobal[1]/(14.0),RGBGlobal[2]/(14.0)};//average out pixels and return color
      return ApplyPostFX(RGBGlobal);
    }
   
    float[] calcPixelColor_REGULARSSA_9(float x, float y, int xRes, int yRes, float offset){//SSA via grid patteren
      RGBGlobal = new float[]{0.0,0.0,0.0}; RGBDEBEEROFFSET = new float[]{1.0,1.0,1.0};
      ScreenVecorLocation = new PVector(x,y);
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
      RGBGlobal = new float[]{RGBGlobal[0]/(12.0),RGBGlobal[1]/(12.0),RGBGlobal[2]/(12.0)};//average out pixels and return color
      return ApplyPostFX(RGBGlobal);
    }
    
    float[] calcPixelColor_REGULARSSA_5(float x, float y, int xRes, int yRes, float offset){//SSA via grid patteren
      RGBGlobal = new float[]{0.0,0.0,0.0}; RGBDEBEEROFFSET = new float[]{1.0,1.0,1.0};
      ScreenVecorLocation = new PVector(x,y);
      ArrayList<float[]> Cols = new ArrayList<float[]>();
        Cols.add(calcPixelColor_NOSSA(x,y,xRes,yRes));//base ray
        Cols.add(calcPixelColor_NOSSA(x+offset,y,xRes,yRes));//right
        Cols.add(calcPixelColor_NOSSA(x-offset,y,xRes,yRes));//left
        Cols.add(calcPixelColor_NOSSA(x,y+offset,xRes,yRes));//down
        Cols.add(calcPixelColor_NOSSA(x,y-offset,xRes,yRes));//up
        
      for(float[] ff : Cols){
        RGBGlobal = new float[]{RGBGlobal[0]+ff[0],RGBGlobal[1]+ff[1],RGBGlobal[2]+ff[2]};
      }
      RGBGlobal = new float[]{RGBGlobal[0]/(7.0),RGBGlobal[1]/(7.0),RGBGlobal[2]/(7.0)};//average out pixels and return color
      return ApplyPostFX(RGBGlobal);
    }
   
   
  //Calcs first pass, looks for edges then gets next pass 
   PImage calcPixelColor_ADAPTIVESSA(int xMin, int yMin,int xMax, int yMax ,int xRes, int yRes){
    RGBGlobal = new float[]{0.0,0.0,0.0}; RGBDEBEEROFFSET = new float[]{1.0,1.0,1.0};
    //error check TODO
    //first pass
    
    int fpWidth = (int)((xMax)-xMin);
    int fpHeight = (int)((yMax)-yMin);
    
    PImage firstPass = new PImage(fpWidth,fpHeight);
    int xOffset = 0;
    int yOffset = 0;
    float[] fpRGB = new float[]{0.0,0.0,0.0};
    for(int i = xMin;i<xMax;++i){
      for(int j = yMin;j<yMax;++j){
        fpRGB = calcPixelColor_NOSSA(i,j,xRes,yRes);
        firstPass.pixels[fpWidth*yOffset+xOffset] = color(fpRGB[0]*255,fpRGB[1]*255,fpRGB[2]*255);
        yOffset++;
      }
     xOffset++;
     yOffset = 0; 
    }//first pass of image done!
    //get edges
    
    SobelEdgeDetection SB = new SobelEdgeDetection();
   
    PImage edgedFirst =  SB.findEdgesAll(firstPass,90);//we now have the edges
    xOffset = 0;

    //check edge response, if its beyond a certain threshold, supersample it to hell and gone
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
                 if (red(edgedFirst.pixels[fpWidth*l+k])!=255)
                  ++amount; 
               }
           }
        ;
           if(amount>3){
             PixelFlag.add(new float[]{i,j});
           }
      }

      float[] NewRGB;
      for(float[] Coords : PixelFlag){
         NewRGB = ApplyPostFX(calcPixelColor_REGULARSSA_9(Coords[0]+xMin,Coords[1]+yMin,xRes,yRes,0.3));
         firstPass.pixels[(int)(fpWidth*(Coords[1])+Coords[0])] = color(NewRGB[0]*255,NewRGB[1]*255,NewRGB[2]*255);
      }
    
    return firstPass; 
   }
   
   
     
  //PostFX
 float[] ApplyPostFX(float[] RGBg){
     if(PFXGamma){
       RGBg =  ApplyGamma(RGBg,gamma);
     }
     if(TMap){
       RGBg =  ApplyToneMap(RGBg,kexp,kpower);
     }
     if(ConstrainBrightness){
       RGBg = new float[]{ (float)(java.lang.Math.tanh(RGBg[0])),(float)(java.lang.Math.tanh(RGBg[1])),(float)(java.lang.Math.tanh(RGBg[2]))};
     }
     return RGBg;
     
   }
 float[] ApplyToneMap(float[] RGBIN, float kExposure, int kPower){
   
   float rTM =pow(kPower,RGBIN[0]-kExposure);
   float gTM =pow(kPower,RGBIN[1]-kExposure);
   float bTM =pow(kPower,RGBIN[2]-kExposure);
   
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
           CH.HitObjectMaterial.diffuseCol = TextureRender(CH.Center,CH.intersectPoint,rayDir,CH);
         }
        
         for(rDirectionalLight rL: SceneH.DirectionalLights){
             RGBGlobal = ApplyDirLight(RGBGlobal, CH, rL, ColMultiplier, rayDir);
         }
         for(rPointLight pL: SceneH.PointLights){
             RGBGlobal = ApplyPointLight(RGBGlobal, CH, pL, ColMultiplier, rayDir);
         }
         
         float AOAcum = 1.0;
         //Ambient Occulision
         if(AO){//AORAYS = 4
           AOAcum*=Ambient_occlusion(CH, rayDir);
           RGBGlobal = Mathutils.addFloat(RGBGlobal,Mathutils.toFloat(Mathutils.componentMult(Mathutils.scalarMult(CH.HitObjectMaterial.diffuseCol,CH.HitObjectMaterial.diffuseD*ColMultiplier),Mathutils.scalarMult(SceneH.Ambience.ambienceCol,AOAcum))));
         }else{
           //add ambience
           RGBGlobal = Mathutils.addFloat(RGBGlobal,Mathutils.toFloat(Mathutils.componentMult(Mathutils.scalarMult(CH.HitObjectMaterial.diffuseCol,CH.HitObjectMaterial.diffuseD*ColMultiplier),SceneH.Ambience.ambienceCol)));
         }
         
         
         // + Emmisive for complete Phongmodel
         RGBGlobal = Mathutils.addFloat(RGBGlobal,Mathutils.toFloat(Mathutils.scalarMult(CH.HitObjectMaterial.emissiveCol,ColMultiplier)));
         //phong done!
         //refract
         if(CH.HitObjectMaterial.refractionAmnt>0.0){//object has refraction amount so do it!
           if(CH.inside){//insde means the normal must inverse because we may need to travel througnit
              CH.surfaceNormal = Mathutils.scalarMult(CH.surfaceNormal,-1.0);
              CH.distFinal = PVector.dist(CH.intersectPoint,CH.diststartrefracthit);
              CH.diststartrefracthit = new PVector(0.0,0.0,0.0);
              RGBDEBEEROFFSET = new float[]{RGBDEBEEROFFSET[0]*exp(RGBDEBEEROFFSET[0]*CH.HitObjectMaterial.C*CH.distFinal*-1),RGBDEBEEROFFSET[1]*exp(RGBDEBEEROFFSET[1]*CH.HitObjectMaterial.C*CH.distFinal*-1),RGBDEBEEROFFSET[2]*exp(RGBDEBEEROFFSET[2]*CH.HitObjectMaterial.C*CH.distFinal*-1)};
              
           }else{
              CH.diststartrefracthit = CH.intersectPoint.get();//make clone
           }
             
             //as mentioned if we hit an object we gotta travel through it
             //therfore cant ignore it anymore
             lastHitID = 0;//reset
             //also need to move the ray a tiny amount pass the collision so no re-intersect occurs on the retrace
             rayPos = Mathutils.addVect(CH.intersectPoint,Mathutils.scalarMult(rayDir,0.01));
             //and do the refraction according to snell law which is simplified as  R = eta * I - (eta * dot(N, I) + sqrt(k)) * N;
             rayDir = refract(rayToCamDir, CH.surfaceNormal,CH.HitObjectMaterial.refractIndex);
             ColMultiplier *= CH.HitObjectMaterial.refractionAmnt;
             if(ColMultiplier<0.06)
               return componentMultFloat(RGBGlobal, RGBDEBEEROFFSET);
             
         }else if(CH.HitObjectMaterial.reflectionD>0.0){//reflection?
           rayPos = CH.intersectPoint;
           rayDir = reflect(rayDir, CH.surfaceNormal);
           
           lastHitID = CH.id;
           ColMultiplier *= CH.HitObjectMaterial.reflectionD;
           if(ColMultiplier<0.06)
             return  componentMultFloat(RGBGlobal, RGBDEBEEROFFSET);
         
         
         }else{//we are done!
           return componentMultFloat(RGBGlobal, RGBDEBEEROFFSET);
         }
         
       }else{//no hit ! return background col!
         return Mathutils.addFloat(RGBGlobal,Mathutils.toFloat(Mathutils.scalarMult(new PVector(0.1,0.1,0.1),ColMultiplier) ));
         
       }
        
    }
    return  componentMultFloat(RGBGlobal, RGBDEBEEROFFSET);
    
  }
  
 
  
  float Ambient_occlusion(CollisionHelper CH3, PVector rayDir){
    int i;
    float ao=0.0;
    float aototal=0.0;
    float d;
    float rn;
    PVector r;
    float blinddistance = 0.0;
    for (i=0; i<AORAYS; i++) {
      
      r=rand_vector(CH3.surfaceNormal);
   
      blinddistance=SceneIntersectBlindDistance(r, CH3.intersectPoint,CH3.id);
      rn=Mathutils.dotProduct(r,CH3.surfaceNormal);
      aototal+=rn;
      if (blinddistance!=MAXRENDERDISTANCE) {
        d=blinddistance;
        d=1.0/(0.02+d*1.0+d*d*0.1);
        if (d>1.0) {d=1.0;};
        ao+=d*rn;
      }
    }
    
    ao=ao/aototal;
    ao = constrain(ao,0,1.0);
    return 1.0-ao;
  }

  
  PVector rand_vector(PVector IntersectPtNormal) {
    PVector p =new PVector();
    p.x=random(0.0,1.0)*2.0-1.0;
    p.y=random(0.0,1.0)*2.0-1.0;
    p.z=random(0.0,1.0)*2.0-1.0;
    while ((Mathutils.dotProduct(p,p)>1.0)||(Mathutils.dotProduct(p,IntersectPtNormal)<0)) {
      p.x=random(0.0,1.0)*2.0-1.0;
      p.y=random(0.0,1.0)*2.0-1.0;
      p.z=random(0.0,1.0)*2.0-1.0;
    }
    p.normalize();
    return p;
  }
  
 PVector TextureRender(PVector Center, PVector intersectPoint, PVector RayDir, CollisionHelper CH2){
      if(rendertype==0){//bilinear
        if(CH.type==2)//sphere
             return  SphereTextureMapBilinear(CH.Center,CH.intersectPoint, RayDir,CH);
            else if(CH.type==1)
             return SquareTextureMapBilinear(CH.Center,CH.intersectPoint, RayDir,CH);
             else
             return  PlaneTextureMapBilinear(CH.Center,CH.intersectPoint, RayDir,CH,infinitetextureScale); 
        
      }else if(rendertype==1){
        if(CH.type==2)//nn
             return  SphereTextureMapNN(CH.Center,CH.intersectPoint, RayDir,CH);
            else if(CH.type==1)
             return SquareTextureMapNN(CH.Center,CH.intersectPoint, RayDir,CH);
             else
             return  PlaneTextureMapNN(CH.Center,CH.intersectPoint, RayDir,CH,infinitetextureScale); 
        
        
      }
      else{
        if(CH.type==2)//normal
             return  SphereTextureMap(CH.Center,CH.intersectPoint, RayDir,CH);
            else if(CH.type==1)
             return SquareTextureMap(CH.Center,CH.intersectPoint, RayDir,CH);
             else
             return  PlaneTextureMap(CH.Center,CH.intersectPoint, RayDir,CH,infinitetextureScale); 
        
      }
  }
  
  
  
 
  
  //resources for optimiaztions http://tigrazone.narod.ru/raytrace2.htm
  boolean InfinitePlaneIntersection(rInfinitePlane inPlane, CollisionHelper CH2, PVector rPos, PVector rDir, int ignorePrimitiveID){
    //infinitePlane handling
    if(ignorePrimitiveID == inPlane.id){
       return false;
    }
     
      
    PVector NAx = Mathutils.normalizeVect(inPlane.NAxis);
    //Ray plane intersection is fairly easy, solve for t=-(rPos dot N + offsetfromorigin)/(rDir dot N), if t <0.0 no intersect, else yes return true and update
    float rayMaxFram = MAXRENDERDISTANCE;
    if(CH2.collisionframe>0.0){
     rayMaxFram =CH2.collisionframe;
    }
    float t = -((Mathutils.dotProduct(rPos,NAx)+inPlane.distfromOrigin)/(Mathutils.dotProduct(rDir,NAx)));
    if(t<0.0 || t>=rayMaxFram)
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
     CH.Size = new PVector(99,99,99);//negative size to indicate infinity
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
    float rayMaxframe = MAXRENDERDISTANCE;//max distances
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
      
      float closestDisttobox = MAXRENDERDISTANCE;
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
    PVector nNorm = Mathutils.normalizeVect(new PVector(A-B,A-C,0.001));
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
    PVector nNorm = Mathutils.normalizeVect(new PVector(B-A,C-A,0.15));
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
  
  
  //returns the distance to the closest interesect
  float SceneIntersectBlindDistance(PVector startPos, PVector targetPos, int ignorePrimID){
    //used for shadows 
    CHTemp = new CollisionHelper(CH);//create a copy
    CH = new CollisionHelper();//clear old
    PVector rayDir = Mathutils.subVect(targetPos,startPos);
    CH.collisionframe = -1;
    rayDir = Mathutils.normalizeVect(rayDir);
    //run interesection against everything that isnt a lightsource and then return true on first hit
    //spheres
    float distance =MAXRENDERDISTANCE;
    
     
    
    for(rSphere rS : SceneH.Spheres){
        if(rS.lightSource==false&&ignorePrimID!=rS.id){
          
         if(SphereIntersection(rS, CH, startPos, rayDir, ignorePrimID)){
           //we have a hit! return false but restore collision var
           if(CH.collisionframe<distance){
             distance = CH.collisionframe;
           }
         }
        }
    }
   CH = new CollisionHelper();//clear old
     rayDir = Mathutils.subVect(targetPos,startPos);
    CH.collisionframe = -1;
    rayDir = Mathutils.normalizeVect(rayDir);
    //run interesection against everything that isnt a lightsource and then return true on first hit
    //spheres
    //boxes
    //spheres
    for(rAABox rB : SceneH.AABoxes){
        if(rB.lightSource==false&&ignorePrimID!=rB.id){
         if(AABoxintersection(rB, CH, startPos, rayDir, ignorePrimID)){
           if(CH.collisionframe<distance){
             distance = CH.collisionframe;
           }
         }
        }
    }//end for
     CH = new CollisionHelper();//clear old
     rayDir = Mathutils.subVect(targetPos,startPos);
    CH.collisionframe = -1;
    rayDir = Mathutils.normalizeVect(rayDir);
    //run interesection against everything that isnt a lightsource and then return true on first hit
    //spheres
    //planes
    for(rInfinitePlane rIP : SceneH.InfinitePlanes){
         //not concerned if it is a light or not
           if(ignorePrimID!=rIP.id)
           if(InfinitePlaneIntersection(rIP, CH, startPos, rayDir,ignorePrimID )){
             if(CH.collisionframe<distance){
             distance = CH.collisionframe;
             }
           }
           }
    
   
    CH = new CollisionHelper(CHTemp);
    return distance;//thePoint can see the other point!!!!
  }
  
  /////////////////////http://ruh.li/GraphicsLightReflection.html
   ///////////////////////////////////////////////COOK TORRENCE////////////////////////////////////////////////////////////////
  float[] SpecularCookTorrencePointLight(float[] rettie, CollisionHelper CH2, rPointLight pLights, float refleamnt, PVector rDir){
    //MAterial Vars
    //New
    
    float roughness = CH.HitObjectMaterial.roughnessval;//0-1, 0 smooth, 1 = rough
    float FresReflect = CH.HitObjectMaterial.fresreflect;//fresnel reflectance at normal incidence
    float k = CH.HitObjectMaterial.k;//fraction of diffuse reflection
    float gaussConts = CH.HitObjectMaterial.specularE;
    PVector Normal = Mathutils.normalizeVect(CH2.surfaceNormal);
    PVector View = Mathutils.normalizeVect(Mathutils.scalarMult(rDir,-1));
    PVector light = Mathutils.normalizeVect(pLights.lightPosition);
    
    //compnenets of the equation
    float ndotv = max(Mathutils.dotProduct(Normal,View),0.01);
    PVector halfVect = Mathutils.normalizeVect(Mathutils.addVect(View,light) );
    float ndoth = max(Mathutils.dotProduct(Normal,halfVect),0.001);
    float ndotl = max(Mathutils.dotProduct(Normal,light),0.001);
    float vdoth = max(Mathutils.dotProduct(View,halfVect),0.001);
    
    //fresnesll
    float refl_r, refr_r;
    float frac = pow(1.0-Mathutils.dotProduct(View,halfVect),5.0);
    refl_r = ((FresReflect-1.0)*(FresReflect-1.0) + 4.0*FresReflect*frac + k*k) / ((FresReflect+1.0)*(FresReflect+1.0) + k*k);
    refr_r =1.0 - refl_r;
 
    // microfacet distribution
    float alpha = acos(ndoth);
    float d = gaussConts * exp(-(alpha*alpha) / (roughness*roughness));

    // geometric attenuation factor
    float g = min(1.0, min(2.0*ndoth*ndotv/vdoth, 2.0*ndoth*ndotl/vdoth));
    float bdrfspec = (refl_r*d*g)/(PI*ndotv*ndotl);
    PVector brdf_spec = new PVector(bdrfspec,bdrfspec,bdrfspec);
  
    PVector fdiff = Mathutils.addVect(new PVector(refr_r,refr_r,refr_r),Mathutils.scalarMult(new PVector(1.0 - refr_r,1.0 - refr_r,1.0 - refr_r),pow(1.0 - ndotl, 5.0)));

    PVector brdf_diff = Mathutils.componentMult(new PVector(1.0,1.0,1.0),new PVector(1.0-fdiff.x/(2.0*PI),1.0-fdiff.y/(2.0*PI),1.0-fdiff.z/(2.0*PI)));
    PVector SummatBRDF = Mathutils.addVect(brdf_spec,brdf_diff);
    PVector LightColndotl = Mathutils.scalarMult(CH2.HitObjectMaterial.specularCol,ndotl/256);
    rettie = Mathutils.addFloat(rettie,Mathutils.toFloat(Mathutils.componentMult(SummatBRDF,LightColndotl)));
    return new float[]{rettie[0],rettie[1],rettie[2]};

}

  
  float[] SpecularCookTorrencePoi2ntLight2(float[] rettie, CollisionHelper CH2, rPointLight pLights, float refleamnt, PVector rDir){
    //MAterial Vars
    //New
    
    float roughness = CH.HitObjectMaterial.roughnessval;//0-1, 0 smooth, 1 = rough
    float FresReflect = CH.HitObjectMaterial.fresreflect;//fresnel reflectance at normal incidence
    float k = CH.HitObjectMaterial.k;//fraction of diffuse reflection
    PVector Normal = Mathutils.normalizeVect(CH2.surfaceNormal);
    
    PVector hitLightDir = Mathutils.normalizeVect(Mathutils.subVect(pLights.lightPosition,CH2.intersectPoint));
    
    //PVector reflection = reflect(hitlight, CH2.surfaceNormal);
    //PVector hitLightDir = Mathutils.normalizeVect(reflection);
   
    float NdotL = max(Mathutils.dotProduct(Normal,hitLightDir),0);
    float spec = 0.0;
    //println(NdotL);
    if(NdotL>0.0){
      //intermediatry calcs
      PVector eyeDir = Mathutils.normalizeVect(Mathutils.scalarMult(rDir,-1));
      PVector hVector = Mathutils.normalizeVect(Mathutils.addVect(hitLightDir,eyeDir));
      float NdotH = max(Mathutils.dotProduct(Normal,hVector),0);
      float NdotV = max(Mathutils.dotProduct(Normal,eyeDir),0);
      float VdotH = max(Mathutils.dotProduct(eyeDir,hVector),0);
      float mSquared = roughness*roughness;
      //Geometrix attentuations
      float NH2 = 2.0*NdotH;
      float G1 = (NH2*NdotV)/VdotH;
      float G2 = (NH2*NdotL)/VdotH;
      float GAttenuation = min(1.0,min(G1,G2));
     
      //Microfacet distribution
      float R1 = 1.0/(4.0*mSquared*pow(NdotH,0.01));
      float R2 = (NdotH*NdotH-1.0)/(mSquared*NdotH*NdotH);
      float finalRoughness = R1*exp(R2);
      
      //Fresnel
      //Shlicks approx
      float fressy = pow(1.0-VdotH,5.0);
      
      fressy*=(1.0-FresReflect);
      fressy+=FresReflect;
      spec = (fressy*GAttenuation*finalRoughness)/(NdotV*NdotL*3.1415);
      
    }
     rettie = Mathutils.addFloat(rettie,Mathutils.toFloat(Mathutils.scalarMult(CH2.HitObjectMaterial.specularCol,NdotL*(spec))));
    return rettie;
    
    
  }
  
  
  
  float[] SpecularCookTorrenceDirectionalLight(float[] rettie, CollisionHelper CH2, rDirectionalLight rLights, float refleamnt, PVector rDir){
    //MAterial Vars
    //New
    
    float roughness = CH.HitObjectMaterial.roughnessval;//0-1, 0 smooth, 1 = rough
    float FresReflect = CH.HitObjectMaterial.fresreflect;//fresnel reflectance at normal incidence
    float k = CH.HitObjectMaterial.k;//fraction of diffuse reflection
    float gaussConts = CH.HitObjectMaterial.specularE;
    PVector Normal = Mathutils.normalizeVect(CH2.surfaceNormal);
    PVector View = Mathutils.normalizeVect(Mathutils.scalarMult(rDir,-1));
    PVector light = Mathutils.normalizeVect(rLights.lightDirectionreverse);
    
    //compnenets of the equation
    float ndotv = max(Mathutils.dotProduct(Normal,View),0.01);
    PVector halfVect = Mathutils.normalizeVect(Mathutils.addVect(View,light) );
    float ndoth = max(Mathutils.dotProduct(Normal,halfVect),0.001);
    float ndotl = max(Mathutils.dotProduct(Normal,light),0.001);
    float vdoth =  max(Mathutils.dotProduct(View,halfVect),0.001);
    
    //fresnesll
    float refl_r, refr_r;
    float frac = pow(1.0-Mathutils.dotProduct(View,halfVect),5.0);
    refl_r = ((FresReflect-1.0)*(FresReflect-1.0) + 4.0*FresReflect*frac + k*k) / ((FresReflect+1.0)*(FresReflect+1.0) + k*k);
    refr_r =1.0 - refl_r;
   
    // microfacet distribution
    float alpha = acos(ndoth);
    float d = gaussConts * exp(-(alpha*alpha) / (roughness*roughness));

    // geometric attenuation factor
    float g = min(1.0, min(2.0*ndoth*ndotv/vdoth, 2.0*ndoth*ndotl/vdoth));
    float bdrfspec = (refl_r*d*g)/(PI*ndotv*ndotl);
    PVector brdf_spec = new PVector(bdrfspec,bdrfspec,bdrfspec);
  
    PVector fdiff = Mathutils.addVect(new PVector(refr_r,refr_r,refr_r),Mathutils.scalarMult(new PVector(1.0 - refr_r,1.0 - refr_r,1.0 - refr_r),pow(1.0 - ndotl, 5.0)));

    PVector brdf_diff = Mathutils.componentMult(new PVector(1.0,1.0,1.0),new PVector(1.0-fdiff.x/(2.0*PI),1.0-fdiff.y/(2.0*PI),1.0-fdiff.z/(2.0*PI)));
    PVector SummatBRDF = Mathutils.addVect(brdf_spec,brdf_diff);
    PVector LightColndotl = Mathutils.scalarMult(CH2.HitObjectMaterial.specularCol,ndotl/256);
    rettie = Mathutils.addFloat(rettie,Mathutils.toFloat(Mathutils.componentMult(SummatBRDF,LightColndotl)));
    
    return new float[]{rettie[0],rettie[1],rettie[2]};

 
   
    
    
  }
  
  float[] SpecularCookTorrenceDirectionalLight2(float[] rettie, CollisionHelper CH2, rDirectionalLight rLights, float refleamnt, PVector rDir){
    
    float roughness = CH.HitObjectMaterial.roughnessval;//0-1, 0 smooth, 1 = rough
    float FresReflect = CH.HitObjectMaterial.fresreflect;//fresnel reflectance at normal incidence
    float k = CH.HitObjectMaterial.k;//fraction of diffuse reflection
    PVector hitLight = Mathutils.normalizeVect(Mathutils.subVect(rLights.lightDirectionreverse,CH2.intersectPoint));
    PVector reflection = reflect(hitLight, CH2.surfaceNormal);
    float dp = (Mathutils.dotProduct(rDir,reflection));
    float spec = 0.0;
    if(dp>0.0){
      //intermediatry calcs
        PVector hVector = Mathutils.normalizeVect(Mathutils.addVect(hitLight,rDir) );
        float NdotH = (Mathutils.dotProduct(CH2.surfaceNormal,hVector));
        float NdotV = (Mathutils.dotProduct(CH2.surfaceNormal,rDir));
        float VdotH =(Mathutils.dotProduct(rDir,hVector));
        float mSquared = roughness*roughness;
      //Geometrix attentuations
      float NH2 = 2.0*NdotH;
      float G1 = (NH2*NdotV)/VdotH;
      float G2 = (NH2*dp)/VdotH;
      float GAttenuation = min(1.0,min(G1,G2));
      
      //Microfacet distribution
      float R1 = 1.0/(4.0*mSquared*pow(NdotH,4.0));
      float R2 = (NdotH*NdotH-1.0)/(mSquared*NdotH*NdotH);
      float finalRoughness = R1*exp(R2);
      
      //Fresnel
      //Shlicks approx
      float fressy = pow(1.0-VdotH,5.0);
      fressy*=(1.0-FresReflect);
      fressy+=FresReflect;
      spec = (fressy*GAttenuation*finalRoughness)/(NdotV*dp*3.1415);
        
   
   
      
    }
    rettie = Mathutils.addFloat(rettie,Mathutils.toFloat(Mathutils.scalarMult(CH2.HitObjectMaterial.specularCol,dp*(k+spec*(1.0-k)))));
    return rettie;
 
   
    
    
  }
  ///////////////////////////////////////////////PHONG//////////////////////////////////////////////////////////////////////////
  float [] SpecularPhongPointLight(PVector hitlight, CollisionHelper CH2,PVector rDir,rPointLight pLights,float refleamnt,float[] rettie ){
      PVector reflection = reflect(hitlight, CH2.surfaceNormal);
      float dp = Mathutils.dotProduct(rDir,reflection);
      if(dp>0.0){
        float specPow = pow(dp, CH2.HitObjectMaterial.specularE);
        PVector specVec = Mathutils.scalarMult(CH2.HitObjectMaterial.specularCol,specPow);
        PVector lColrefl = Mathutils.scalarMult(pLights.lightCol,refleamnt);
        rettie = Mathutils.addFloat(rettie,Mathutils.toFloat(Mathutils.componentMult(specVec,lColrefl)));
      }
      return rettie;
  }
  
  float [] SpecularPhongDirectionalLight(PVector hitlight, CollisionHelper CH2,PVector rDir,rDirectionalLight rLights,float refleamnt,float[] rettie ){
      PVector reflection = reflect(rLights.lightDirectionreverse, CH2.surfaceNormal);
      float dp = Mathutils.dotProduct(rDir,reflection);
      
      if(dp>0.0){
        float specPow = pow(dp, CH2.HitObjectMaterial.specularE);
        PVector specVec = Mathutils.scalarMult(CH2.HitObjectMaterial.specularCol,specPow);
        PVector lColrefl = Mathutils.scalarMult(rLights.lightCol,refleamnt);
        rettie = Mathutils.addFloat(rettie,Mathutils.toFloat(Mathutils.componentMult(specVec,lColrefl)));
      }
      return rettie;
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
      
        if(CH2.HitObjectMaterial.specularE<0){//SPEC FIX
          return rettie;
        }else if(CH2.HitObjectMaterial.isct){//apply cook torrence
         rettie = SpecularCookTorrencePointLight(rettie,CH2, pLights,refleamnt,rDir);
      }else{//apply phong
         rettie = SpecularPhongPointLight(hitLight,CH2,rDir,pLights,refleamnt,rettie); 
      }
      
      
       //float d = map(CH2.collisionframe,0.0,(MAXRENDERDISTANCE+0.0),1.0,0.0);
        //rettie = new float[]{rettie[0]*(d),rettie[1]*(d),rettie[2]*(d)};
      
      
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
        
        //------------------------
        //Check for no specular -1 denotes no spec
        if(CH2.HitObjectMaterial.specularE<0){//SPEC FIX
          return rettie;
        }else if(CH2.HitObjectMaterial.isct){//apply cook torrence
         rettie = SpecularCookTorrenceDirectionalLight(rettie ,CH2, rLights,refleamnt,rDir);
        }else{//apply phong
         rettie = SpecularPhongDirectionalLight(rLights.lightDirectionreverse,CH2,rDir,rLights,refleamnt,rettie); 
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
 /////////////////////////////////////////////////////////////////////////TEXTURE MAPPING//////////////////////////////////////////////////////////////////// 
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
  

  //------------------------------------------------------------------------Filtering
  
  //Nearest neighbour
  //http://www.flipcode.com/archives/Raytracing_Topics_Techniques-Part_6_Textures_Cameras_and_Speed.shtml
  PVector SphereTextureMapNN(PVector Center, PVector intersectPoint, PVector Ray, CollisionHelper CH2){//returns a color for sphere
        PVector Normals = Mathutils.normalizeVect(Mathutils.subVect(intersectPoint,Center));
        float offset = 0.5;
        
        float u = 0.5 +atan2(Normals.z,Normals.x)/(2*PI);
        float v = 0.5 -asin(Normals.y)/(PI);
        
        int MaxVal = CH2.HitObjectMaterial.Tex.height*CH2.HitObjectMaterial.Tex.width;
        color c1,c2,c3,c4,c5;
       
        int pWidth = (int)(u*CH2.HitObjectMaterial.Tex.width);
        int pHeight = (int)(v*CH2.HitObjectMaterial.Tex.height);
        int pX1 = pWidth + (pHeight*CH2.HitObjectMaterial.Tex.width);//center
        pX1 = abs(pX1%MaxVal);
        c1 = CH2.HitObjectMaterial.Tex.pixels[pX1];
        //left
        pWidth = (int)(((u)*CH2.HitObjectMaterial.Tex.width)+offset);
        pHeight = (int)(v*CH2.HitObjectMaterial.Tex.height);
        int pX2 = pWidth + (pHeight*CH2.HitObjectMaterial.Tex.width);
        pX2 = abs(pX2%MaxVal);
        c2 = CH2.HitObjectMaterial.Tex.pixels[pX2];
        //right
        pWidth = (int)(((u)*CH2.HitObjectMaterial.Tex.width)+offset);
        pHeight = (int)(v*CH2.HitObjectMaterial.Tex.height);
        int pX3 = pWidth + (pHeight*CH2.HitObjectMaterial.Tex.width);//right
        pX3 = abs(pX3%MaxVal);
        c3= CH2.HitObjectMaterial.Tex.pixels[pX3];
         //up
        pWidth = (int)(u*CH2.HitObjectMaterial.Tex.width);
        pHeight = (int)(((v)*CH2.HitObjectMaterial.Tex.height)+offset);
        int pX4 = pWidth + (pHeight*CH2.HitObjectMaterial.Tex.width);//up
        pX4 = abs(pX4%MaxVal);
        c4 = CH2.HitObjectMaterial.Tex.pixels[pX4];
        
        pWidth = (int)(u*CH2.HitObjectMaterial.Tex.width);
        pHeight = (int)(((v)*CH2.HitObjectMaterial.Tex.height)-offset);
        int pX5 = pWidth + (pHeight*CH2.HitObjectMaterial.Tex.width);//down
        pX5 = abs(pX5%MaxVal);
        c5 = CH2.HitObjectMaterial.Tex.pixels[pX5];
        
        
       PVector c1c =  new PVector(red(c1)/255,green(c1)/255,blue(c1)/255);
       PVector c2c =  new PVector(red(c2)/255,green(c2)/255,blue(c2)/255);
       PVector c3c =  new PVector(red(c3)/255,green(c3)/255,blue(c3)/255);
       PVector c4c =  new PVector(red(c4)/255,green(c4)/255,blue(c4)/255);
       PVector c5c =  new PVector(red(c5)/255,green(c5)/255,blue(c5)/255);
       
       PVector finalc = new PVector((c1c.x+c2c.x+c3c.x+c4c.x+c5c.x)/5,(c1c.y+c2c.y+c3c.y+c4c.y+c5c.y)/5,(c1c.z+c2c.z+c3c.z+c4c.z+c5c.z)/5);
        
        return  finalc;
  }
  
   PVector PlaneTextureMapNN(PVector Center, PVector intersectPoint, PVector Ray, CollisionHelper CH2, int scalefactor){//returns a color for cube
        //gotta resize based off each axis
        float u = 0.0;
        float v = 0.0;
        float offset = 0.5;
        color c1,c2,c3,c4,c5;
        
        int MaxVal = CH2.HitObjectMaterial.Tex.height*CH2.HitObjectMaterial.Tex.width;
        
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
        
        int pX1 = (int)(u+offset) + (((int)(v))*CH2.HitObjectMaterial.Tex.width);
        int pX2 = (int)(u-offset) + (((int)(v))*CH2.HitObjectMaterial.Tex.width);
        int pX3 = (int)(u) + (((int)(v+offset))*CH2.HitObjectMaterial.Tex.width);
        int pX4 = (int)(u) + (((int)(v-offset))*CH2.HitObjectMaterial.Tex.width);
        int pX5 = (int)(u) + (((int)(v))*CH2.HitObjectMaterial.Tex.width);
        
        
        pX1 = abs(pX1%MaxVal);
        pX2 = abs(pX2%MaxVal);
        pX3 = abs(pX3%MaxVal);
        pX4 = abs(pX4%MaxVal);
        pX5 = abs(pX5%MaxVal);
        
        c1 = CH2.HitObjectMaterial.Tex.pixels[pX1];
        c2 = CH2.HitObjectMaterial.Tex.pixels[pX2];
        c3 = CH2.HitObjectMaterial.Tex.pixels[pX3];
        c4 = CH2.HitObjectMaterial.Tex.pixels[pX4];
        c5 = CH2.HitObjectMaterial.Tex.pixels[pX5];
        
        
       PVector c1c =  new PVector(red(c1)/255,green(c1)/255,blue(c1)/255);
       PVector c2c =  new PVector(red(c2)/255,green(c2)/255,blue(c2)/255);
       PVector c3c =  new PVector(red(c3)/255,green(c3)/255,blue(c3)/255);
       PVector c4c =  new PVector(red(c4)/255,green(c4)/255,blue(c4)/255);
       PVector c5c =  new PVector(red(c5)/255,green(c5)/255,blue(c5)/255);
       PVector finalc = new PVector((c1c.x+c2c.x+c3c.x+c4c.x+c5c.x)/5,(c1c.y+c2c.y+c3c.y+c4c.y+c5c.y)/5,(c1c.z+c2c.z+c3c.z+c4c.z+c5c.z)/5);
       
       return finalc;
  }
  
  PVector SquareTextureMapNN(PVector Center, PVector intersectPoint, PVector Ray, CollisionHelper CH2){//returns a color for cube
        //gotta resize based off each axis
        float u = 0.0;
        float v = 0.0;
        float offset = 0.5;
        color c1,c2,c3,c4,c5;
        int MaxVal = CH2.HitObjectMaterial.Tex.height*CH2.HitObjectMaterial.Tex.width;
        
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
       
        int pX1 = (int)(u+offset) + (((int)(v))*CH2.HitObjectMaterial.Tex.width);
        int pX2 = (int)(u-offset) + (((int)(v))*CH2.HitObjectMaterial.Tex.width);
        int pX3 = (int)(u) + (((int)(v+offset))*CH2.HitObjectMaterial.Tex.width);
        int pX4 = (int)(u) + (((int)(v-offset))*CH2.HitObjectMaterial.Tex.width);
        int pX5 = (int)(u) + (((int)(v))*CH2.HitObjectMaterial.Tex.width);
        
        
        pX1 = abs(pX1%MaxVal);
        pX2 = abs(pX2%MaxVal);
        pX3 = abs(pX3%MaxVal);
        pX4 = abs(pX4%MaxVal);
        pX5 = abs(pX5%MaxVal);
        
        c1 = CH2.HitObjectMaterial.Tex.pixels[pX1];
        c2 = CH2.HitObjectMaterial.Tex.pixels[pX2];
        c3 = CH2.HitObjectMaterial.Tex.pixels[pX3];
        c4 = CH2.HitObjectMaterial.Tex.pixels[pX4];
        c5 = CH2.HitObjectMaterial.Tex.pixels[pX5];
        
        
       PVector c1c =  new PVector(red(c1)/255,green(c1)/255,blue(c1)/255);
       PVector c2c =  new PVector(red(c2)/255,green(c2)/255,blue(c2)/255);
       PVector c3c =  new PVector(red(c3)/255,green(c3)/255,blue(c3)/255);
       PVector c4c =  new PVector(red(c4)/255,green(c4)/255,blue(c4)/255);
       PVector c5c =  new PVector(red(c5)/255,green(c5)/255,blue(c5)/255);
       PVector finalc = new PVector((c1c.x+c2c.x+c3c.x+c4c.x+c5c.x)/5,(c1c.y+c2c.y+c3c.y+c4c.y+c5c.y)/5,(c1c.z+c2c.z+c3c.z+c4c.z+c5c.z)/5);
       
       return finalc;
        
  }
  
  
  
  ///////////BILINEAR------------------------------------------------------------------------------------------------------------------------------------------
   PVector PlaneTextureMapBilinear(PVector Center, PVector intersectPoint, PVector Ray, CollisionHelper CH2, int scalefactor){//returns a color for cube
        //gotta resize based off each axis
        float u = 0.0;
        float v = 0.0;
      
        color c1,c2,c3,c4;
        
        int MaxVal = CH2.HitObjectMaterial.Tex.height*CH2.HitObjectMaterial.Tex.width;
        
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
        
        float u_ratio = u-floor(u);
        float v_ratio = v-floor(v);
        float u_Op = 1-u_ratio;
        float v_Op = 1-v_ratio;
        
        
        int pX1 = (int)(u) + (((int)(v))*CH2.HitObjectMaterial.Tex.width);//center
        int pX2 = (int)(u+TEXFILTEROFFSET) + (((int)(v))*CH2.HitObjectMaterial.Tex.width);
        int pX3 = (int)(u) + (((int)(v+TEXFILTEROFFSET))*CH2.HitObjectMaterial.Tex.width);
        int pX4 = (int)(u+TEXFILTEROFFSET) + (((int)(v+TEXFILTEROFFSET))*CH2.HitObjectMaterial.Tex.width);
        
        
        pX1 = abs(pX1%MaxVal);
        pX2 = abs(pX2%MaxVal);
        pX3 = abs(pX3%MaxVal);
        pX4 = abs(pX4%MaxVal);

        
        c1 = CH2.HitObjectMaterial.Tex.pixels[pX1];
        c2 = CH2.HitObjectMaterial.Tex.pixels[pX2];
        c3 = CH2.HitObjectMaterial.Tex.pixels[pX3];
        c4 = CH2.HitObjectMaterial.Tex.pixels[pX4];

        
        
       PVector c1c =  new PVector(red(c1)/255,green(c1)/255,blue(c1)/255);
       PVector c2c =  new PVector(red(c2)/255,green(c2)/255,blue(c2)/255);
       PVector c3c =  new PVector(red(c3)/255,green(c3)/255,blue(c3)/255);
       PVector c4c =  new PVector(red(c4)/255,green(c4)/255,blue(c4)/255);
       
       float redBL = (((c1c.x*u_Op)+(c2c.x*u_ratio)*v_Op)) +(((c3c.x*u_Op)+(c4c.x*u_ratio))*v_ratio);
       float greenBL = (((c1c.y*u_Op)+(c2c.y*u_ratio)*v_Op)) +(((c3c.y*u_Op)+(c4c.y*u_ratio))*v_ratio);
       float blueBL = (((c1c.z*u_Op)+(c2c.z*u_ratio)*v_Op)) +(((c3c.z*u_Op)+(c4c.z*u_ratio))*v_ratio);
       

       PVector finalc = new PVector(redBL,greenBL,blueBL);
       
       return finalc;
  }
  
  PVector SquareTextureMapBilinear(PVector Center, PVector intersectPoint, PVector Ray, CollisionHelper CH2){//returns a color for cube
        //gotta resize based off each axis
        float u = 0.0;
        float v = 0.0;
     
        color c1,c2,c3,c4;
        int MaxVal = CH2.HitObjectMaterial.Tex.height*CH2.HitObjectMaterial.Tex.width;
        
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
       
        float u_ratio = u-floor(u);
        float v_ratio = v-floor(v);
        float u_Op = 1-u_ratio;
        float v_Op = 1-v_ratio;
        
        int pX1 = (int)(u) + (((int)(v))*CH2.HitObjectMaterial.Tex.width);
        int pX2 = (int)(u+TEXFILTEROFFSET) + (((int)(v))*CH2.HitObjectMaterial.Tex.width);
        int pX3 = (int)(u) + (((int)(v+TEXFILTEROFFSET))*CH2.HitObjectMaterial.Tex.width);
        int pX4 = (int)(u+TEXFILTEROFFSET) + (((int)(v+TEXFILTEROFFSET))*CH2.HitObjectMaterial.Tex.width);
       
        
        
        pX1 = abs(pX1%MaxVal);
        pX2 = abs(pX2%MaxVal);
        pX3 = abs(pX3%MaxVal);
        pX4 = abs(pX4%MaxVal);
       
        
        c1 = CH2.HitObjectMaterial.Tex.pixels[pX1];
        c2 = CH2.HitObjectMaterial.Tex.pixels[pX2];
        c3 = CH2.HitObjectMaterial.Tex.pixels[pX3];
        c4 = CH2.HitObjectMaterial.Tex.pixels[pX4];
       
        
        
       PVector c1c =  new PVector(red(c1)/255,green(c1)/255,blue(c1)/255);
       PVector c2c =  new PVector(red(c2)/255,green(c2)/255,blue(c2)/255);
       PVector c3c =  new PVector(red(c3)/255,green(c3)/255,blue(c3)/255);
       PVector c4c =  new PVector(red(c4)/255,green(c4)/255,blue(c4)/255);

       float redBL = (((c1c.x*u_Op)+(c2c.x*u_ratio)*v_Op)) +(((c3c.x*u_Op)+(c4c.x*u_ratio))*v_ratio);
       float greenBL = (((c1c.y*u_Op)+(c2c.y*u_ratio)*v_Op)) +(((c3c.y*u_Op)+(c4c.y*u_ratio))*v_ratio);
       float blueBL = (((c1c.z*u_Op)+(c2c.z*u_ratio)*v_Op)) +(((c3c.z*u_Op)+(c4c.z*u_ratio))*v_ratio);
       
       PVector finalc = new PVector(redBL,greenBL,blueBL);
       
       return finalc;
        
  }
  
 
  
   PVector SphereTextureMapBilinear(PVector Center, PVector intersectPoint, PVector Ray, CollisionHelper CH2){//returns a color for sphere
        PVector Normals = Mathutils.normalizeVect(Mathutils.subVect(intersectPoint,Center));
        
        float u = 0.5 +atan2(Normals.z,Normals.x)/(2*PI);
        float v = 0.5 -asin(Normals.y)/(PI);
        
        int MaxVal = CH2.HitObjectMaterial.Tex.height*CH2.HitObjectMaterial.Tex.width;
        color c1,c2,c3,c4;
       
        int pWidth = (int)(u*CH2.HitObjectMaterial.Tex.width);
        int pHeight = (int)(v*CH2.HitObjectMaterial.Tex.height);
        int pX1 = pWidth + (pHeight*CH2.HitObjectMaterial.Tex.width);//center
        pX1 = abs(pX1%MaxVal);
        c1 = CH2.HitObjectMaterial.Tex.pixels[pX1];
        //left
        pWidth = (int)(((u)*CH2.HitObjectMaterial.Tex.width)+TEXFILTEROFFSET);
        pHeight = (int)(v*CH2.HitObjectMaterial.Tex.height);
        int pX2 = pWidth + (pHeight*CH2.HitObjectMaterial.Tex.width);
        pX2 = abs(pX2%MaxVal);
        c2 = CH2.HitObjectMaterial.Tex.pixels[pX2];
        //right
        pWidth = (int)(((u)*CH2.HitObjectMaterial.Tex.width));
        pHeight = (int)((((v)*CH2.HitObjectMaterial.Tex.height)+TEXFILTEROFFSET));
        
        int pX3 = pWidth + (pHeight*CH2.HitObjectMaterial.Tex.width);//right
        pX3 = abs(pX3%MaxVal);
        c3= CH2.HitObjectMaterial.Tex.pixels[pX3];
         //up
        pWidth = (int)(((u)*CH2.HitObjectMaterial.Tex.width)+TEXFILTEROFFSET);
        pHeight = (int)((((v)*CH2.HitObjectMaterial.Tex.height)+TEXFILTEROFFSET));
        int pX4 = pWidth + (pHeight*CH2.HitObjectMaterial.Tex.width);//up
        pX4 = abs(pX4%MaxVal);
        c4 = CH2.HitObjectMaterial.Tex.pixels[pX4];
        
        
        float u_ratio = u-floor(u);
        float v_ratio = v-floor(v);
        float u_Op = 1-u_ratio;
        float v_Op = 1-v_ratio;
        
        PVector c1c =  new PVector(red(c1)/255,green(c1)/255,blue(c1)/255);
        PVector c2c =  new PVector(red(c2)/255,green(c2)/255,blue(c2)/255);
        PVector c3c =  new PVector(red(c3)/255,green(c3)/255,blue(c3)/255);
        PVector c4c =  new PVector(red(c4)/255,green(c4)/255,blue(c4)/255);
  
       float redBL = (((c1c.x*u_Op)+(c2c.x*u_ratio)*v_Op)) + (((c3c.x*u_Op)+(c4c.x*u_ratio))*v_ratio);
       float greenBL = (((c1c.y*u_Op)+(c2c.y*u_ratio)*v_Op)) +(((c3c.y*u_Op)+(c4c.y*u_ratio))*v_ratio);
       float blueBL = (((c1c.z*u_Op)+(c2c.z*u_ratio)*v_Op)) +(((c3c.z*u_Op)+(c4c.z*u_ratio))*v_ratio);
         
         PVector finalc = new PVector(redBL,greenBL,blueBL);
         
         return finalc;
        
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
  
  
  float[] componentMultFloat(float[] F1, float[] F2){////////////////////////////////////////BEER LAMBERT
  
    return new float[]{F1[0]*F2[0],F1[1]*F2[1],F1[2]*F2[2]};
  }
  
 void LoadConfig(String File){//S D L 
    
     try{
      BufferedReader br = new BufferedReader(new FileReader(File));//open file
      String Line = br.readLine();
      String Line2 = br.readLine();
       
       while(Line!=null && Line2!=null){
        
         if(Line.contains("TEXSCALE")){
           infinitetextureScale = Integer.parseInt(Line2);
           
         }else if(Line.contains("RAYBOUNCEUPPER")){
           raybouncemax = Integer.parseInt(Line2);
           
         }else if(Line.contains("TEXTFILTEROFFSET")){
           TEXFILTEROFFSET = Float.parseFloat( Line2);
           
         }else if(Line.contains("POSTFXGAMMA")){
           gamma = Float.parseFloat( Line2);
           PFXGamma = true;
           
         }else if(Line.contains("POSTFXTONEMAP")){
            String[] splitResult = Line2.split(",");
            kexp = Float.parseFloat( splitResult[0]);
            kpower = Integer.parseInt(splitResult[1]);
            TMap = true;
         }else if(Line.contains("TEXTURERENDER")){
             rendertype =Integer.parseInt(Line2);
         }else if(Line.contains("AO")){
             AORAYS =Integer.parseInt(Line2);
             AO = true;
         }else{
           
         }
         Line = br.readLine();
        Line2 = br.readLine();
       }
        br.close();
       
     }catch(Exception e){
       JOptionPane.showMessageDialog(null,""+e.toString(),"Exception",JOptionPane.INFORMATION_MESSAGE);
       System.out.println("Exception:"+e.toString());
     }
     finally{
     
     }
     
 }
  
}
