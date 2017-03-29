
//helper class to keep collision of ray state
class CollisionHelper{
   int id;
   boolean foundhit;
   boolean inside;
   float collisionframe;
   PVector intersectPoint;
   PVector surfaceNormal;
   rMaterial HitObjectMaterial;
   PVector Center;
   PVector Size; 
   int type;//defines sphere, light etc
   int axis;//nneded for aabox
   
   //Beers law
   PVector diststartrefracthit;
   float distFinal;
   
   //default constructor
   CollisionHelper(){
     id = 0;
     foundhit = false;
     inside = false;
     collisionframe = -1.0;
     intersectPoint = new PVector(0.0,0.0,0.0);
     surfaceNormal = new PVector(0.0,0.0,0.0);
     HitObjectMaterial = new rMaterial();
     Center = new PVector(0.0,0.0,0.0);
     Size = new PVector(0.0,0.0,0.0);
     type = 0;
     axis = -1;
     diststartrefracthit = new PVector(0.0,0.0,0.0);
     distFinal = 0;
   }
   CollisionHelper(CollisionHelper old){
     this(old.id,old.foundhit,old.inside,old.collisionframe,old.intersectPoint,old.surfaceNormal, old.HitObjectMaterial, old.Center, old.Size, old.type, old.axis, old.diststartrefracthit, old.distFinal);
   }
   CollisionHelper(int _id, boolean _foundhit,boolean _inside, float _collisionframe, PVector _intPoint, PVector _SNormal, rMaterial _rMat, PVector _Center, PVector _Size, int _type, int _axis, PVector _diststartrefracthit, float _distFinal){
     id = _id;
     foundhit = _foundhit;
     inside = _inside;
     collisionframe = _collisionframe;
     intersectPoint = _intPoint;
     surfaceNormal = _SNormal;
     HitObjectMaterial = _rMat;
     Center = _Center;
     Size = _Size;
     type = _type;
     axis = _axis;
     diststartrefracthit = _diststartrefracthit; 
     distFinal = _distFinal;
     //Center
   }
  
  
}
