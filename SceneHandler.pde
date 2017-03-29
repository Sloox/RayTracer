//class that has scene data
//holds arrays of Primitive objects
//it is a data handler not a calculator
import javax.swing.JOptionPane;

class SceneHandler{
   ArrayList<rSphere> Spheres;
   ArrayList<rAABox> AABoxes;
   ArrayList<rPointLight> PointLights;
   ArrayList<rDirectionalLight> DirectionalLights;
   ArrayList<rInfinitePlane> InfinitePlanes;
   rAmbientLight Ambience;
   vMath Mutils;
   vMath Mathutils;
   
   SceneHandler(){//TODO->Cornell box!
     Mutils = new vMath();
     Mathutils = new vMath();
     //ambience
     Ambience = new rAmbientLight(new PVector(0.1,0.1,0.1));
     
     
     //dir lights
     DirectionalLights = new ArrayList<rDirectionalLight>();
     DirectionalLights.add(new rDirectionalLight(Mutils.normalizeVect((new PVector(-1.0,1.0,-4.0))),new PVector(0.8,0.8,0.8)));
     
     
     //point Lights
     PVector PLightPos1 = new PVector(0.0,+1.4,-2.0);
     PointLights = new ArrayList<rPointLight>();
     PointLights.add(new rPointLight((PLightPos1),new PVector(1.0,1.0,1.0)));
    // PointLights.add(new rPointLight(new PVector(0.0,+1.4,1.0),new PVector(0.0,0.0,0.1)));
     
    //planes
    InfinitePlanes = new ArrayList<rInfinitePlane>();
     
     
     //boxes floor
     AABoxes = new ArrayList<rAABox>();
     rMaterial temp = new rMaterial(1.0,new PVector(1.0,1.0,1.0),100.0,new PVector(1.0,1.0,1.0),new PVector(0.0,0.0,0.0),0.05,0.0,0.0,0.15);
     AABoxes.add(new rAABox(8,new PVector(0.0,-2.5,5.0),new PVector(6.0,0.1,10.0),temp,false));
     //top
     AABoxes.add(new rAABox(1,new PVector(0.0,+2.5,5.0),new PVector(6.0,0.1,10.0),temp,false));
     //boxes back
     AABoxes.add(new rAABox(9,new PVector(0.0,0.0,10.0),new PVector(6.0,5.0,0.1),temp,false));
     
     //left
    rMaterial temp2 = new rMaterial(1.0,new PVector(1.0,0.0,0.0),100.0,new PVector(1.0,0.0,0.0),new PVector(0.0,0.0,0.0),0.05,0.0,0.0,0.15);
    AABoxes.add(new rAABox(10,new PVector(-3.0,0.0,5.0),new PVector(0.1,5.0,10.0),temp2,false));
    //right
    rMaterial temp3 = new rMaterial(1.0,new PVector(0.0,1.0,0.0),100.0,new PVector(0.0,1.0,0.0),new PVector(0.0,0.0,0.0),0.05,0.0,0.0,0.15);
    AABoxes.add(new rAABox(11,new PVector(+3.0,0.0,5.0),new PVector(0.1,5.0,10.0),temp3,false));
    
     rMaterial tLight = new rMaterial(1.0,new PVector(1.0,1.0,1.0), 10.0, new PVector(1.0,1.0,1.0),new PVector(1.0,1.0,1.0),0.05,0.0,0.0,0.15);
     AABoxes.add(new rAABox(13,new PVector(0.0,2.4,5.0),new PVector(1.0,0.01,1.0),tLight,true));
     
     Spheres = new  ArrayList<rSphere>();
     
    //rMaterial tem4 = new rMaterial(1.0,new PVector(1.0,1.0,1.0),100.0,new PVector(1.0,1.0,1.0),new PVector(0.0,0.0,0.0),0.0);
    // rSphere(int _id, PVector _Center,float _radius, rMaterial _MatType, boolean _lightSource){
    //Spheres.add(new rSphere(5, new PVector(-1.5,1.0,4.0),0.5,tem4,false));
    
    
    rMaterial tem5 = new rMaterial(1.0,new PVector(1.0,1.0,1.0),100.0,new PVector(1.0,1.0,1.0),new PVector(0.0,0.0,0.0),0.0,0.0,0.0,0.15);
    Spheres.add(new rSphere(6, new PVector(+0.0,0.0,0.0),0.5,tem5,false));
    
    rMaterial tem3 = new rMaterial(1.0,new PVector(1.0,1.0,1.0),100.0,new PVector(1.0,1.0,1.0),new PVector(0.0,0.0,0.0),0.0,0.0,0.0,0.15);
    Spheres.add(new rSphere(7, new PVector(+0.0,0.5,6.0),0.05,tem3,false));
    
     rMaterial tem11 = new rMaterial(1.0,new PVector(1.0,1.0,1.0), 10.0, new PVector(1.0,1.0,1.0),new PVector(0.0,0.0,0.0),0.0,0.0,0.0,0.15);
     AABoxes.add(new rAABox(123,new PVector(0.0,-1.0,2.0),new PVector(3.0,0.15,5.0),tem11,false));//table
     rMaterial legs = new rMaterial(0.5,new PVector(0.0,0.2,0.0), 10.0, new PVector(0.0,0.2,0.0),new PVector(0.0,0.0,0.0),0.0,0.0,0.0,0.15);
     AABoxes.add(new rAABox(124,new PVector(-1.25,-2.0,0.75),new PVector(0.15,1.95,0.15),legs,false));
     AABoxes.add(new rAABox(125,new PVector(+1.25,-2.0,0.75),new PVector(0.15,1.95,0.15),legs,false));
     AABoxes.add(new rAABox(126,new PVector(-1.25,-2.0,5.25),new PVector(0.15,1.95,0.15),legs,false));
     AABoxes.add(new rAABox(127,new PVector(+1.25,-2.0,5.25),new PVector(0.15,1.95,0.15),legs,false));
     
     rMaterial tem12 = new rMaterial(1.0,new PVector(0.0,1.0,0.0), 10.0, new PVector(0.0,1.0,0.0),new PVector(0.0,0.0,0.0),0.0,0.0,0.0,0.15);
     AABoxes.add(new rAABox(1323,new PVector(0.0,-0.8,3.0),new PVector(3.0,0.20,0.15),tem12,false));//net
    
    
    
    
     rMaterial reds = new rMaterial(0.4,new PVector(1.0,0.0,0.0), 10.0, new PVector(1.0,0.0,0.0),new PVector(0.0,0.0,0.0),0.0,0.6,0.4,0.15);
     AABoxes.add(new rAABox(23,new PVector(1.0,0.0,1.0),new PVector(0.5,0.5,0.15),reds,false));
     AABoxes.add(new rAABox(24,new PVector(1.0,-0.35,1.0),new PVector(0.133,0.25,0.15),reds,false));
     
     AABoxes.add(new rAABox(25,new PVector(-1.0,0.0,5.0),new PVector(0.5,0.5,0.15),reds,false));
     AABoxes.add(new rAABox(26,new PVector(-1.0,-0.35,5.0),new PVector(0.133,0.25,0.15),reds,false));
     
     //rMaterial blues = new rMaterial(0.4,new PVector(0.0,0.0,1.0), 10.0, new PVector(0.0,0.0,1.0),new PVector(0.0,0.0,1.0),0.0,0.0,0.0);
     //AABoxes.add(new rAABox(27,new PVector(-2.85,-0.5,0.0),new PVector(0.25,4.00,0.15),blues,false));
   
   //texture
     rSphere test = Spheres.get(Spheres.size()-2);
     //test.MatType.setNoiseTexture();
     //test.MatType.setTexture("data\\Textures\\world.png");
     //test.MatType.setBumpmap("data\\Textures\\world.png");
     rAABox test2 = AABoxes.get(AABoxes.size()-10);
     test.MatType.setNoiseTexture(5,true,300,300,24);
     //test2.MatType.setTexture("data\\Textures\\wood.jpg");
     //test2.MatType.setBumpmap("data\\Textures\\wood.jpg");
     //test2.MatType.setBumpmap("data\\Textures\\world.png");
     //test2.MatType.setTexture("data\\Textures\\world.png");
 }
 
 
 SceneHandler(String Filename){
   //instantiate all vars
    Mutils = new vMath();
    
   DirectionalLights = new ArrayList<rDirectionalLight>();
   AABoxes = new ArrayList<rAABox>();
   Spheres = new  ArrayList<rSphere>();
   PointLights = new ArrayList<rPointLight>();
   Ambience = new rAmbientLight(new PVector(0.1,0.1,0.1));
   InfinitePlanes = new ArrayList<rInfinitePlane>();
   loadSceneFromFile(Filename);
 }
 
 
 void loadSceneFromFile(String File){//S D L 
    
     try{
      BufferedReader br = new BufferedReader(new FileReader(File));//open file
      String Line = br.readLine();
       String Line2 = br.readLine();
       
       while(Line!=null && Line2!=null){
        
         if(Line.contains("SPHERE")){
           if(Line.contains("COOKTORRENCE"))
               parseSphereCT(Line2);
            else
               parseSphere(Line2);
           
         }else if(Line.contains("AABOX")){
            if(Line.contains("COOKTORRENCE"))
               parseAABOXCT(Line2);
            else
               parseAABOX(Line2);
           
         }else if(Line.contains("DIRLIGHT")){
           parseDirLight(Line2);
           
         }else if(Line.contains("PLIGHT")){
           parsePointLight(Line2);
           
         }else if(Line.contains("AMBIENCE")){
           parseAmbience(Line2);
         }else if(Line.contains("IPLANE")){
           if(Line.contains("COOKTORRENCE"))
               parseIPlaneCT(Line2);
            else
               parseIPlane(Line2);
           
         }else{
           throw new Exception("Invalid file format for Scene file!");
         }
         Line = br.readLine();
        Line2 = br.readLine();
       }
        br.close();
       
     }catch(Exception e){
       JOptionPane.showMessageDialog(null,"Failed to load scene from file, an exception has occured","Exception",JOptionPane.INFORMATION_MESSAGE);
       System.out.println("Exception:"+e.toString());
     }
     finally{
        
     }
     
 }
 
 
 void parseSphereCT(String Line){//Cooktorrence
    String[] splitResult = Line.split(",");

    //id,center,radius,material,light,CTVARS
    int ID = Integer.parseInt(splitResult[0]);
    PVector Center = new PVector(Float.parseFloat(splitResult[1]),Float.parseFloat(splitResult[2]),Float.parseFloat(splitResult[3]));
    float radius = Float.parseFloat(splitResult[4]);
    float diffuseD = Float.parseFloat(splitResult[5]);
    PVector diffuseColor = new PVector(Float.parseFloat(splitResult[6]),Float.parseFloat(splitResult[7]),Float.parseFloat(splitResult[8]));
    float specularityPower = Float.parseFloat(splitResult[9]);
    PVector specularityColor = new PVector(Float.parseFloat(splitResult[10]),Float.parseFloat(splitResult[11]),Float.parseFloat(splitResult[12]));
    PVector emmisveColor = new PVector(Float.parseFloat(splitResult[13]),Float.parseFloat(splitResult[14]),Float.parseFloat(splitResult[15]));
    float reflectionD = Float.parseFloat(splitResult[16]);
    float refractionD =  Float.parseFloat(splitResult[17]);
    float refractionINDEX =  Float.parseFloat(splitResult[18]);
    float dbeersConstant =  Float.parseFloat(splitResult[19]);
    float CTRoughness = Float.parseFloat(splitResult[20]);
    float CTFresneslReflectance = Float.parseFloat(splitResult[21]);
    float kvar = Float.parseFloat(splitResult[22]);
    
    boolean lightsource = false;
    if(splitResult[23].contains("TRUE"))
      lightsource = true;
     
    rMaterial SphereMat = new rMaterial(diffuseD,diffuseColor,specularityPower,specularityColor,emmisveColor,reflectionD,refractionD,refractionINDEX,dbeersConstant,CTRoughness,CTFresneslReflectance,kvar);
    rSphere rs = new rSphere(ID,Center,radius, SphereMat,lightsource);
    //check for texture
    try{
       if (splitResult[24]!=null&&!splitResult[24].contains("$")){
          rs.MatType.setTexture(splitResult[24]);
       } 
       if(splitResult[25]!=null&&!splitResult[25].contains("$")){
         rs.MatType.setBumpmap(splitResult[25]);
       }
       if(splitResult[26]!=null&&!splitResult[26].contains("$")){
         rs.MatType.setNoiseTexture(Integer.parseInt(splitResult[26]),false,300,300,12);
       }
    }catch(IndexOutOfBoundsException e){
    
    }
    Spheres.add(rs);
 }
 
 void parseSphere(String Line){//phong
    String[] splitResult = Line.split(",");
    //rMaterial(1.0,new PVector(1.0,1.0,1.0),100.0,new PVector(1.0,1.0,1.0),new PVector(0.0,0.0,0.0),0.0,0.0,0.0);
    // Spheres.add(new rSphere(6, new PVector(+0.0,0.0,1.0),0.5,tem5,false));
    //id,center,radius,material,light
    int ID = Integer.parseInt(splitResult[0]);
    PVector Center = new PVector(Float.parseFloat(splitResult[1]),Float.parseFloat(splitResult[2]),Float.parseFloat(splitResult[3]));
    float radius = Float.parseFloat(splitResult[4]);
    float diffuseD = Float.parseFloat(splitResult[5]);
    PVector diffuseColor = new PVector(Float.parseFloat(splitResult[6]),Float.parseFloat(splitResult[7]),Float.parseFloat(splitResult[8]));
    float specularityPower = Float.parseFloat(splitResult[9]);
    PVector specularityColor = new PVector(Float.parseFloat(splitResult[10]),Float.parseFloat(splitResult[11]),Float.parseFloat(splitResult[12]));
    PVector emmisveColor = new PVector(Float.parseFloat(splitResult[13]),Float.parseFloat(splitResult[14]),Float.parseFloat(splitResult[15]));
    float reflectionD = Float.parseFloat(splitResult[16]);
    float refractionD =  Float.parseFloat(splitResult[17]);
    float refractionINDEX =  Float.parseFloat(splitResult[18]);
    float dbeersConstant =  Float.parseFloat(splitResult[19]);
    boolean lightsource = false;
    if(splitResult[20].contains("TRUE"))
      lightsource = true;
    rMaterial SphereMat = new rMaterial(diffuseD,diffuseColor,specularityPower,specularityColor,emmisveColor,reflectionD,refractionD,refractionINDEX,dbeersConstant);
    rSphere rs = new rSphere(ID,Center,radius, SphereMat,lightsource);
    //check for texture
    try{
       if (splitResult[21]!=null&&!splitResult[21].contains("$")){
          rs.MatType.setTexture(splitResult[21]);
       } 
       if(splitResult[22]!=null&&!splitResult[22].contains("$")){
         rs.MatType.setBumpmap(splitResult[22]);
       }
       if(splitResult[23]!=null&&!splitResult[23].contains("$")){
         rs.MatType.setNoiseTexture(Integer.parseInt(splitResult[23]),false,300,300,12);
       }
    }catch(IndexOutOfBoundsException e){
    
    }
    Spheres.add(rs);
 }
 
 void parseAABOX(String Line){
   String[] splitResult = Line.split(",");
    //rMaterial(1.0,new PVector(1.0,1.0,1.0),100.0,new PVector(1.0,1.0,1.0),new PVector(0.0,0.0,0.0),0.0,0.0,0.0);
    // AABoxes.add(new rAABox(23,new PVector(1.0,0.0,1.0),new PVector(0.5,0.5,0.15),reds,false));
    //rAABox(int _id, PVector _Position, PVector _Scale, rMaterial _MatType, boolean _lightSource){
    int ID = Integer.parseInt(splitResult[0]);
    PVector Position = new PVector(Float.parseFloat(splitResult[1]),Float.parseFloat(splitResult[2]),Float.parseFloat(splitResult[3]));
    PVector Size = new PVector(Float.parseFloat(splitResult[4]),Float.parseFloat(splitResult[5]),Float.parseFloat(splitResult[6]));
    float diffuseD = Float.parseFloat(splitResult[7]);
    PVector diffuseColor = new PVector(Float.parseFloat(splitResult[8]),Float.parseFloat(splitResult[9]),Float.parseFloat(splitResult[10]));
    float specularityPower = Float.parseFloat(splitResult[11]);
    PVector specularityColor = new PVector(Float.parseFloat(splitResult[12]),Float.parseFloat(splitResult[13]),Float.parseFloat(splitResult[14]));
    PVector emmisveColor = new PVector(Float.parseFloat(splitResult[15]),Float.parseFloat(splitResult[16]),Float.parseFloat(splitResult[17]));
    float reflectionD = Float.parseFloat(splitResult[18]);
    float refractionD =  Float.parseFloat(splitResult[19]);
    float refractionINDEX =  Float.parseFloat(splitResult[20]);
    float dbeersConstant =  Float.parseFloat(splitResult[21]);
    boolean lightsource = false;
    if(splitResult[22].contains("TRUE"))
      lightsource = true;
    rMaterial BoxMat = new rMaterial(diffuseD,diffuseColor,specularityPower,specularityColor,emmisveColor,reflectionD,refractionD,refractionINDEX,dbeersConstant);
    rAABox rAAB = new rAABox(ID,Position,Size, BoxMat,lightsource);
    //check for texture
    try{
       if (splitResult[23]!=null&&!splitResult[23].contains("$")){
          rAAB.MatType.setTexture(splitResult[23]);
       } 
       if(splitResult[24]!=null&&!splitResult[24].contains("$")){
         rAAB.MatType.setBumpmap(splitResult[24]);
       }
       if(splitResult[25]!=null&&!splitResult[25].contains("$")){
         rAAB.MatType.setNoiseTexture(Integer.parseInt(splitResult[24]),true,600,600,32);
       }
    }catch(IndexOutOfBoundsException e){
    
    }
    AABoxes.add(rAAB);
 }
 
 void parseAABOXCT(String Line){
   String[] splitResult = Line.split(",");
    //rAABox(int _id, PVector _Position, PVector _Scale, rMaterial _MatType, boolean _lightSource){
    int ID = Integer.parseInt(splitResult[0]);
    PVector Position = new PVector(Float.parseFloat(splitResult[1]),Float.parseFloat(splitResult[2]),Float.parseFloat(splitResult[3]));
    PVector Size = new PVector(Float.parseFloat(splitResult[4]),Float.parseFloat(splitResult[5]),Float.parseFloat(splitResult[6]));
    float diffuseD = Float.parseFloat(splitResult[7]);
    PVector diffuseColor = new PVector(Float.parseFloat(splitResult[8]),Float.parseFloat(splitResult[9]),Float.parseFloat(splitResult[10]));
    float specularityPower = Float.parseFloat(splitResult[11]);
    PVector specularityColor = new PVector(Float.parseFloat(splitResult[12]),Float.parseFloat(splitResult[13]),Float.parseFloat(splitResult[14]));
    PVector emmisveColor = new PVector(Float.parseFloat(splitResult[15]),Float.parseFloat(splitResult[16]),Float.parseFloat(splitResult[17]));
    float reflectionD = Float.parseFloat(splitResult[18]);
    float refractionD =  Float.parseFloat(splitResult[19]);
    float refractionINDEX =  Float.parseFloat(splitResult[20]);
    float dbeersConstant =  Float.parseFloat(splitResult[21]);
    float CTRoughness = Float.parseFloat(splitResult[22]);
    float CTFresneslReflectance = Float.parseFloat(splitResult[23]);
    float kvar = Float.parseFloat(splitResult[24]);
    boolean lightsource = false;
    if(splitResult[25].contains("TRUE"))
      lightsource = true;
    rMaterial BoxMat = new rMaterial(diffuseD,diffuseColor,specularityPower,specularityColor,emmisveColor,reflectionD,refractionD,refractionINDEX,dbeersConstant,CTRoughness,CTFresneslReflectance,kvar);
    rAABox rAAB = new rAABox(ID,Position,Size, BoxMat,lightsource);
    //check for texture
    try{
       if (splitResult[26]!=null&&!splitResult[26].contains("$")){
          rAAB.MatType.setTexture(splitResult[26]);
       } 
       if(splitResult[27]!=null&&!splitResult[27].contains("$")){
         rAAB.MatType.setBumpmap(splitResult[27]);
       }
       if(splitResult[28]!=null&&!splitResult[28].contains("$")){
         rAAB.MatType.setNoiseTexture(Integer.parseInt(splitResult[28]),true,600,600,32);
       }
    }catch(IndexOutOfBoundsException e){
    
    }
    AABoxes.add(rAAB);
 }
 
 
 void parseDirLight(String Line){
   String[] splitResult = Line.split(",");
    //DirectionalLights.add(new rDirectionalLight(Mutils.normalizeVect((new PVector(-1.0,1.0,-4.0))),new PVector(0.8,0.8,0.8)));
    PVector Direction = Mutils.normalizeVect(new PVector(Float.parseFloat(splitResult[0]),Float.parseFloat(splitResult[1]),Float.parseFloat(splitResult[2])));
    PVector Color = new PVector(Float.parseFloat(splitResult[3]),Float.parseFloat(splitResult[4]),Float.parseFloat(splitResult[5]));
    DirectionalLights.add(new rDirectionalLight(Direction, Color));
 }
 
 void parsePointLight(String Line){
   String[] splitResult = Line.split(",");
    //PVector PLightPos1 = new PVector(0.0,+2.0,5.0);
    // PointLights = new ArrayList<rPointLight>();
    // PointLights.add(new rPointLight((PLightPos1),new PVector(1.0,1.0,1.0)));
    PVector Position = new PVector(Float.parseFloat(splitResult[0]),Float.parseFloat(splitResult[1]),Float.parseFloat(splitResult[2]));
    PVector Color = new PVector(Float.parseFloat(splitResult[3]),Float.parseFloat(splitResult[4]),Float.parseFloat(splitResult[5]));
    PointLights.add(new rPointLight(Position, Color));
 }
 
 
 void parseAmbience(String Line){
   String[] splitResult = Line.split(",");
    //Ambience = new rAmbientLight(new PVector(0.1,0.1,0.1));
    PVector Color = new PVector(Float.parseFloat(splitResult[0]),Float.parseFloat(splitResult[1]),Float.parseFloat(splitResult[2]));
    Ambience = new rAmbientLight(Color);
 }
 
void parseIPlane(String Line){
    String[] splitResult = Line.split(",");
  //rInfinitePlane(int _id,PVector _NAxis,  float _distfromOrigin, rMaterial _MatType, boolean LSource){
    //rMaterial(1.0,new PVector(1.0,1.0,1.0),100.0,new PVector(1.0,1.0,1.0),new PVector(0.0,0.0,0.0),0.0,0.0,0.0);
    int ID = Integer.parseInt(splitResult[0]);
    PVector NAxis = new PVector(Float.parseFloat(splitResult[1]),Float.parseFloat(splitResult[2]),Float.parseFloat(splitResult[3]));
    float distFromOrigin = Float.parseFloat(splitResult[4]);
    float diffuseD = Float.parseFloat(splitResult[5]);
    PVector diffuseColor = new PVector(Float.parseFloat(splitResult[6]),Float.parseFloat(splitResult[7]),Float.parseFloat(splitResult[8]));
    float specularityPower = Float.parseFloat(splitResult[9]);
    PVector specularityColor = new PVector(Float.parseFloat(splitResult[10]),Float.parseFloat(splitResult[11]),Float.parseFloat(splitResult[12]));
    PVector emmisveColor = new PVector(Float.parseFloat(splitResult[13]),Float.parseFloat(splitResult[14]),Float.parseFloat(splitResult[15]));
    float reflectionD = Float.parseFloat(splitResult[16]);
    float refractionD =  Float.parseFloat(splitResult[17]);
    float refractionINDEX =  Float.parseFloat(splitResult[18]);
    float dbeersConstant =  Float.parseFloat(splitResult[19]);
    boolean lightsource = false;
    if(splitResult[20].contains("TRUE"))
      lightsource = true;
    rMaterial iPlaneMat = new rMaterial(diffuseD,diffuseColor,specularityPower,specularityColor,emmisveColor,reflectionD,refractionD,refractionINDEX,dbeersConstant);
    rInfinitePlane rIP = new rInfinitePlane(ID,NAxis,distFromOrigin,iPlaneMat,lightsource);
    //check for texture
    try{
       if (splitResult[21]!=null&&!splitResult[21].contains("$")){
          rIP.MatType.setTexture(splitResult[21]);
       } 
       if(splitResult[22]!=null&&!splitResult[22].contains("$")){
         rIP.MatType.setBumpmap(splitResult[22]);
       }
        if(splitResult[23]!=null&&!splitResult[23].contains("$")){
         rIP.MatType.setNoiseTexture(Integer.parseInt(splitResult[23]),true,600,600,32);
       }
    }catch(IndexOutOfBoundsException e){
    
    }
    InfinitePlanes.add(rIP);  
}

void parseIPlaneCT(String Line){
    String[] splitResult = Line.split(",");
  //rInfinitePlane(int _id,PVector _NAxis,  float _distfromOrigin, rMaterial _MatType, boolean LSource){
    //rMaterial(1.0,new PVector(1.0,1.0,1.0),100.0,new PVector(1.0,1.0,1.0),new PVector(0.0,0.0,0.0),0.0,0.0,0.0);
    int ID = Integer.parseInt(splitResult[0]);
    PVector NAxis = new PVector(Float.parseFloat(splitResult[1]),Float.parseFloat(splitResult[2]),Float.parseFloat(splitResult[3]));
    float distFromOrigin = Float.parseFloat(splitResult[4]);
    float diffuseD = Float.parseFloat(splitResult[5]);
    PVector diffuseColor = new PVector(Float.parseFloat(splitResult[6]),Float.parseFloat(splitResult[7]),Float.parseFloat(splitResult[8]));
    float specularityPower = Float.parseFloat(splitResult[9]);
    PVector specularityColor = new PVector(Float.parseFloat(splitResult[10]),Float.parseFloat(splitResult[11]),Float.parseFloat(splitResult[12]));
    PVector emmisveColor = new PVector(Float.parseFloat(splitResult[13]),Float.parseFloat(splitResult[14]),Float.parseFloat(splitResult[15]));
    float reflectionD = Float.parseFloat(splitResult[16]);
    float refractionD =  Float.parseFloat(splitResult[17]);
    float refractionINDEX =  Float.parseFloat(splitResult[18]);
    float dbeersConstant =  Float.parseFloat(splitResult[19]);
    float CTRoughness = Float.parseFloat(splitResult[20]);
    float CTFresneslReflectance = Float.parseFloat(splitResult[21]);
    float kvar = Float.parseFloat(splitResult[22]);
    boolean lightsource = false;
    if(splitResult[23].contains("TRUE"))
      lightsource = true;
    rMaterial iPlaneMat = new rMaterial(diffuseD,diffuseColor,specularityPower,specularityColor,emmisveColor,reflectionD,refractionD,refractionINDEX,dbeersConstant,CTRoughness,CTFresneslReflectance,kvar);
    rInfinitePlane rIP = new rInfinitePlane(ID,NAxis,distFromOrigin,iPlaneMat,lightsource);
    //check for texture
    try{
       if (splitResult[24]!=null&&!splitResult[24].contains("$")){
          rIP.MatType.setTexture(splitResult[24]);
       } 
       if(splitResult[25]!=null&&!splitResult[25].contains("$")){
         rIP.MatType.setBumpmap(splitResult[25]);
       }
        if(splitResult[26]!=null&&!splitResult[26].contains("$")){
         rIP.MatType.setNoiseTexture(Integer.parseInt(splitResult[26]),true,600,600,32);
       }
    }catch(IndexOutOfBoundsException e){
    
    }
    InfinitePlanes.add(rIP);  
}
 
 
 //Start of scene collision handling
 //AO only


   
   
 
} 
