//help simplify the vector calculations

class vMath{
  
  
  //subtract Vectors
  PVector subVect(PVector Vector1, PVector Vector2){//subtract 1 from 2
    return PVector.sub(Vector1,Vector2);
  }
  //add vect
  
  PVector addVect(PVector Vector1, PVector Vector2){//add 1 to 2
    return PVector.add(Vector1,Vector2);
  }
  //Normalize the vector, i.e. unit vector
  PVector normalizeVect(PVector Vector1){
    PVector temp = Vector1.get();//copy constructor
    return temp.normalize(temp);
  }
  //Cross product
  PVector crossProduct(PVector Vect1, PVector Vect2){
     PVector temp = Vect1.get();//copy constructor
     PVector temp2 = Vect2.get();//copy constructor
     return temp.cross(temp2); 
  }
  //component multilplacation
  PVector componentMult(PVector Vect1, PVector Vect2){
    return new PVector(Vect1.x*Vect2.x,Vect1.y*Vect2.y,Vect1.z*Vect2.z);
  }
  //Component div
  PVector componendDiv2(PVector Vect1, PVector Vect2){
    return new PVector(Vect1.x/Vect2.x,Vect1.y/Vect2.y);
  }
  PVector componendDiv3(PVector Vect1, PVector Vect2){
    return new PVector(Vect1.x/Vect2.x,Vect1.y/Vect2.y, Vect1.z/Vect2.z);
  }
  PVector scalarMult(PVector Vect1, float scalar){
     return PVector.mult(Vect1, scalar); 
  }
  
  float dotProduct(PVector Vect1, PVector Vect2){
   return PVector.dot(Vect1,Vect2);//V1[0]*V2[0]+.... 
  }
  
  float[] toFloat(PVector Vect1){
     return new float[]{Vect1.x, Vect1.y, Vect1.z}; 
  }
  
  float[] addFloat(float[] F1, float[] F2){
    return new float[]{F1[0]+F2[0],F1[1]+F2[1],F1[2]+F2[2]};
    
  }
  
  
  PVector MatrixVectorProduct(Mat3 Matrix3, PVector P1){
    float r1 = (Matrix3.r1.x*P1.x+Matrix3.r1.y*P1.y+Matrix3.r1.z*P1.z);
    float r2 = (Matrix3.r2.x*P1.x+Matrix3.r2.y*P1.y+Matrix3.r2.z*P1.z);
    float r3 = (Matrix3.r3.x*P1.x+Matrix3.r3.y*P1.y+Matrix3.r3.z*P1.z);
    return new PVector(r1,r2,r3);
    
  }
  
  float clamp(float x, float minVal, float maxVal){ //returns x constrained to minval and maxval
    return min(max(x,minVal),maxVal);
    
  }
  
  PVector clampVect(PVector Vect , float minval, float maxval){
     return new PVector(clamp(Vect.x,minval,maxval),clamp(Vect.y,minval,maxval)); 
  }
  
  
 float eSign(float in){//extracts the sign on a float (-1 if <0, 1 if >0 else 0.0 )
    if(in<0.0){
      return -1.0;
    }else if(in>0.0){
      return 1.0;
    }else
      return 0.0;
  } 
  
}

class Mat3{
  PVector r1,r2,r3;
  
  Mat3(PVector _r1, PVector _r2, PVector _r3){
    r1 = _r1;
    r2 = _r2;
    r3 = _r3;
  }
  
}
