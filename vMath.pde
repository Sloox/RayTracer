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
  
  float[] multFloat(float[] F1, float[] F2){
    return new float[]{F1[0]*F2[0],F1[1]*F2[1],F1[2]*F2[2]};
    
  }
  
 PVector rotategen(PVector vector, double theta) {
    float x = (float) (vector.x * Math.cos(theta) - vector.y * Math.sin(theta));
    float y = (float) (vector.x * Math.sin(theta) + vector.y * Math.cos(theta));
    vector.set(x, y, 0);
    return vector;
  }
  
 PVector rotategenClone(PVector vector, double theta) {
    float x = (float) (vector.x * Math.cos(theta) - vector.y * Math.sin(theta));
    float y = (float) (vector.x * Math.sin(theta) + vector.y * Math.cos(theta));
    return new PVector(x,y);
  }
  
  
  PVector[] rotateVerts(PVector[] verts,float angle,PVector axis){
    int vl = verts.length;
    PVector[] clone = new PVector[vl];
    for(int i = 0; i<vl;i++) 
        clone[i] = PVector.add(verts[i],new PVector());
    //rotate using a matrix
    PMatrix3D rMat = new PMatrix3D();
      rMat.rotate(radians(angle),axis.x,axis.y,axis.z);
      
    PVector[] dst = new PVector[vl];
    for(int i = 0; i<vl;i++) dst[i] = new PVector();
    for(int i = 0; i<vl;i++) rMat.mult(clone[i],dst[i]);
      return dst;
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


public class Quaternion {//https://github.com/kynd/PQuaternion
    public float x, y, z, w;
    
    public Quaternion() {
        x = y = z = 0;
        w = 1;
    }
    public Quaternion(float _x, float _y, float _z, float _w) {
              x = _x;
              y = _y;
              z = _z;
              w = _w;
    }
    public Quaternion(float angle, PVector axis) {
          setAngleAxis(angle, axis);
    }
    public Quaternion get() {
            return new Quaternion(x, y, z, w);
    }
    public Boolean equal(Quaternion q) {
            return x == q.x && y == q.y && z == q.z && w == q.w;
     }
     public void set(float _x, float _y, float _z, float _w) {
            x = _x;
            y = _y;
            z = _z;
            w = _w;
     }
     public void setAngleAxis(float angle, PVector axis) {
            axis.normalize();
            float hcos = cos(angle / 2);
            float hsin = sin(angle / 2);
            w = hcos;
            x = axis.x * hsin;
            y = axis.y * hsin;
            z = axis.z * hsin;
     }
     public Quaternion conj() {
            Quaternion ret = new Quaternion();
            ret.x = -x;
            ret.y = -y;
            ret.z = -z;
            ret.w = w;
            return ret;
     }
     public Quaternion mult(float r) {
              Quaternion ret = new Quaternion();
              ret.x = x * r;
              ret.y = y * r;
              ret.z = z * r;
              ret.w = w * w;
              return ret;
     }
     public Quaternion mult(Quaternion q) {
              Quaternion ret = new Quaternion();
              ret.x = q.w*x + q.x*w + q.y*z - q.z*y;
              ret.y = q.w*y - q.x*z + q.y*w + q.z*x;
              ret.z = q.w*z + q.x*y - q.y*x + q.z*w;
              ret.w = q.w*w - q.x*x - q.y*y - q.z*z;
              return ret;
     }
     public PVector mult(PVector v) {
            float px = (1 - 2 * y * y - 2 * z * z) * v.x +
            (2 * x * y - 2 * z * w) * v.y +
            (2 * x * z + 2 * y * w) * v.z;
            float py = (2 * x * y + 2 * z * w) * v.x +
            (1 - 2 * x * x - 2 * z * z) * v.y +
            (2 * y * z - 2 * x * w) * v.z;
            float pz = (2 * x * z - 2 * y * w) * v.x +
            (2 * y * z + 2 * x * w) * v.y +
            (1 - 2 * x * x - 2 * y * y) * v.z;
            return new PVector(px, py, pz);
     }
     public void normalize(){
              float len = w*w + x*x + y*y + z*z;
              float factor = 1.0f / sqrt(len);
              x *= factor;
              y *= factor;
              z *= factor;
              w *= factor;
    }
}
