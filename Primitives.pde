  //contains all the primitive data and primitive methods
  //includes Material types and values & Light classes
  
  
  
  class rSphere{
    //basic id for spheres 
    int id; 
    PVector Center;
    float radius;
    rMaterial MatType;
    boolean lightSource;
    
    rSphere(int _id, PVector _Center,float _radius, rMaterial _MatType, boolean _lightSource){
     id = _id;
     Center = _Center;
     radius = _radius;
     MatType = _MatType;
     lightSource = _lightSource;
    }
    
    
  }
  
  class rAABox{//Axis alighned box
    //basic id for spheres 
    int id; 
    PVector Position;
    PVector Scale;
    rMaterial MatType;
     boolean lightSource;
    
    rAABox(int _id, PVector _Position, PVector _Scale, rMaterial _MatType, boolean _lightSource){
     id = _id;
     Position = _Position;
     Scale = _Scale;
     MatType = _MatType;
     lightSource = _lightSource;
     
    }
    
  }
  
  class rMaterial{//TODO add transparency
    float diffuseD;//defuse delta
    PVector diffuseCol;  
    
    float specularE;//specular epsilon
    PVector specularCol;
    
    PVector emissiveCol;
    float reflectionD;//reflection const 1.0 full, 0.0 none
    
    //refraction
    float refractionAmnt;
    float refractIndex;
    
    PImage Tex,BumpM;
    boolean hastex, hasbumpmap;//bumpmap & texture
    
    //beer lambert
    float C = 0.10;//Density of matter
    
    //cook torrence
    boolean isct = false;
    float roughnessval = 0.3;
    float fresreflect = 0.8;
    float k  = 0.2;
    
    
    
    
    //default constructor
    rMaterial(){//default values, values dont matter
      diffuseD = 1.0;
      diffuseCol = new PVector(0.0,0.0,0.0);//black
      specularE = 1.0;
      specularCol = new PVector(0.0,0.0,0.0);
      emissiveCol = new PVector(0.0,0.0,0.0);
      reflectionD = 0.0;
      refractionAmnt = 0.0;
      refractIndex = 0.0;
      Tex = new PImage();
      hastex= false;
      BumpM = new PImage();
      hasbumpmap = false;
      C = 0.15;
      isct = false;//default not cook torrence
      roughnessval = 0.3;
      fresreflect = 0.8;
      k  = 0.2;
    }
    //constructior + cooktorrence
    rMaterial(float _diffuseD, PVector _diffuseCol, float _specularE, PVector _specularCol, PVector _emissiveCol, float _reflectionD, float _refractamnt, float _refractIndex, float dbeersConstant, float _roughnessval, float _fresreflect, float _k){
     diffuseD = _diffuseD;
     diffuseCol = _diffuseCol;
     specularE = _specularE;
     specularCol = _specularCol;
     emissiveCol = _emissiveCol;
     reflectionD = _reflectionD;
     refractionAmnt = _refractamnt;
     refractIndex = _refractIndex;
     Tex = new PImage();
     hastex = false;
     BumpM = new PImage();
     hasbumpmap = false;
     C = dbeersConstant;
     isct = true;//using ct constructoer means ct enabled
     roughnessval = _roughnessval;
     fresreflect = _fresreflect;
     k  = _k;
    }
    
     //constructior + Phong
    rMaterial(float _diffuseD, PVector _diffuseCol, float _specularE, PVector _specularCol, PVector _emissiveCol, float _reflectionD, float _refractamnt, float _refractIndex, float dbeersConstant){
     diffuseD = _diffuseD;
     diffuseCol = _diffuseCol;
     specularE = _specularE;
     specularCol = _specularCol;
     emissiveCol = _emissiveCol;
     reflectionD = _reflectionD;
     refractionAmnt = _refractamnt;
     refractIndex = _refractIndex;
     Tex = new PImage();
     hastex = false;
     BumpM = new PImage();
     hasbumpmap = false;
     C = dbeersConstant;
     isct = false;//default not cook torrence
     roughnessval = 0.3;
     fresreflect = 0.8;
     k  = 0.2;
    }
    
    void setTexture(String File){
        Tex = loadImage(sketchPath(File));
        hastex = true;
    }
    void setBumpmap(String File){
      BumpM = loadImage(File);
      hasbumpmap = true;
    }
 
    void setNoiseTexture(int index, boolean asBumpmap, int texSizeWidth, int texSizeHeight, int size){
       PerlinNoise pn = new PerlinNoise();
      switch(index){
         case 1:
           Tex = pn.genBlueMarble(texSizeWidth,texSizeHeight);
           hastex = true;
           if(asBumpmap)
             BumpM = Tex;
           hasbumpmap = asBumpmap;
           
          break;
         case 2:
            Tex = pn.gencheckerBoard(texSizeWidth,texSizeHeight,color(255.0,255.0,255.0),color(0.0,0.0,0.0), size);
            hastex = true;
            if(asBumpmap)
             BumpM = Tex;
           hasbumpmap = asBumpmap;
          break;
         case 3:
           Tex = pn.genPlasmaGreen(texSizeWidth,texSizeHeight);
            hastex = true;
            if(asBumpmap)
             BumpM = Tex;
           hasbumpmap = asBumpmap;
           break;
         case 4:
           Tex = pn.genPlasmaPurple(texSizeWidth,texSizeHeight);
            hastex = true;
            if(asBumpmap)
             BumpM = Tex;
           hasbumpmap = asBumpmap;
           break;
        case 5:
           Tex = pn.genRandom(texSizeWidth,texSizeHeight);
            hastex = true;
            if(asBumpmap)
             BumpM = Tex;
           hasbumpmap = asBumpmap;
           break;
         default: 
      }
      
    }
  }
    
  
  //point light support
  class rPointLight{
    PVector lightPosition;
    PVector lightCol;
    
    rPointLight(PVector _lightPosition,  PVector _lightCol){
      lightPosition = _lightPosition;
      lightCol = _lightCol;
    }
  }
  
  
  //directionalLights ;)
  class rDirectionalLight{
    PVector lightDirectionreverse;
    PVector lightCol;
    
    rDirectionalLight(PVector _lightDirectionreverse,  PVector _lightCol){
      lightDirectionreverse = _lightDirectionreverse;
      lightCol = _lightCol;
    }
  }
  
  //ambience for scene, classes for everything!!!!
 class rAmbientLight{
    PVector ambienceCol;
    rAmbientLight(PVector _ambienceCol){
      ambienceCol = _ambienceCol;
    }
 }
 
  class rInfinitePlane{//infine plane class
      int id; 
      PVector NAxis;//must be normlaized)
      float distfromOrigin;//distance from origin
      rMaterial MatType;
       boolean lightSource;
      
     rInfinitePlane(int _id,PVector _NAxis,  float _distfromOrigin, rMaterial _MatType, boolean LSource){
        id = _id;
        NAxis = _NAxis;
        distfromOrigin = _distfromOrigin;
        MatType = _MatType;
        lightSource = LSource;
      }
  }
  
  
  
