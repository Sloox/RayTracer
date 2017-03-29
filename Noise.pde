//Here lies Noise Functions for procedural texturing


//http://www.noisemachine.com/talk1/29.html for noise
//http://freespace.virgin.net/hugo.elias/models/m_perlin.htm

class PerlinNoise{//http://webstaff.itn.liu.se/~stegu/TNM022-2005/perlinnoiselinks/perlin-noise-math-faq.html &&http://www.drdobbs.com/architecture-and-design/cuda-supercomputing-for-the-masses-part/222600097?pgno=4 for permuations
  int[] Permus = new int[512];
  
  PerlinNoise(){//constructor
    int permutation[] = { 151,160,137,91,90,15,//i donot  own this look above
      131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
      190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
      88,237,149,56,87,174,20,125,136,171,168,68,175,74,165,71,134,139,48,27,166,
      77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
      102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208,89,18,169,200,196,
      135,130,116,188,159,86,164,100,109,198,173,186,3,64,52,217,226,250,124,123,
      5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
      23,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167,43,172,9,
      129,22,39,253,19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
      251,34,242,193,238,210,144,12,191,179,162,241,81,51,145,235,249,14,239,107,
      49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127,4,150,254,
      138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
   };
   for (int i = 0; i < 256; i++) {
     Permus[256+i] = Permus[i] = permutation[i];
   }
  }
  float fade(float t){
   return t*t*t*(t*(t*6-15)+10); 
  }
  
  float plerp(float t, float a, float b){
    return a+t*(b-a);
  }
  
  float grad(int hash, float x, float y, float z){
    int h = hash&15;
    float u=h<8||h==12||h==13?x:y,
          v=h<4||h==12||h==13?y:z;
    return ((h&1)==0?u:-u)+((h&2)==0?v:-v);
    
  }
  
  float getNoise(float x, float y, float z){
     int X = (int)floor(x)&255,
         Y =  (int)floor(y)&255,
         Z = (int)floor(z)&255;
     x-=floor(x);
     y-=floor(y);
     z-=floor(z);
     
     float u = fade(x),
           v = fade(y),
           w = fade(z);
      int A = Permus[X]+Y,
          AA = Permus[A]+Z,
          AB = Permus[A+1]+Z,
          B = Permus[X+1]+Y,
          BA = Permus[B]+Z,
          BB = Permus[B+1]+Z;
          
     return//arf arf arf
       plerp(w, plerp(v, plerp(u, grad(Permus[AA], x, y, z),
                           grad(Permus[BA], x-1, y, z)), 
                   plerp(u, grad(Permus[AB], x, y-1, z), 
                           grad(Permus[BB], x-1, y-1, z))), 
           plerp(v, plerp(u, grad(Permus[AA+1], x, y, z-1),
                           grad(Permus[BA+1], x-1, y, z-1)),
                   plerp(u, grad(Permus[AB+1], x, y-1, z-1 ),
                           grad(Permus[BB+1], x-1, y-1, z-1 ))));
         
  }
  
  PImage genBlueMarble(int tWidth, int tHeight){
     PImage newTex = new PImage(tWidth,tHeight);
     float ns = 0.030;//increase for more noise
     float tt = 1;
     
     for(int i = 0;i<(tWidth);++i)
       for(int j = 0;j<tHeight;++j){
         float u = i/tWidth;
         float v = j/tHeight;
         float noise00 = getNoise(i*ns, j*ns,tt);
         float noise01 = getNoise(i*ns, (j+tHeight)*ns,tt);
         float noise10 = getNoise((i+tWidth)*ns, j*ns,tt);
         float noise11 = getNoise((i+tWidth)*ns, (j+tHeight)*ns,tt);
         float noisea = u*v*noise00 + u*(1-v)*noise01 + (1-u)*v*noise10 + (1-u)*(1-v)*noise11;
         int value = (int) (256* noisea) +50;
         int r = (int)noise00;
         int g = value;
         int b = value +50;
     
         if (r > 255) r = 255;
         if (r < 0) r = 0;
     
         if (g > 255) g = 255;
         if (g < 0) g = 0;
     
         if (b > 255) b = 255;
         if (b < 0) b = 0;
         color c = color(r&0xFF,g&0xFF,b&0xFF); 
         newTex.pixels[i+(j*tWidth)] = c;
       }
       return newTex;
  }


PImage gencheckerBoard(int tWidth, int tHeight, color col1, color col2, int stride){
     PImage newTex = new PImage(tWidth,tHeight);
     int index = 0;
     color curcolor;
    
     for(int i = 0;i<(tWidth);++i)
       for(int j = 0;j<tHeight;++j){
         int sCol = i/stride;
         int sRow = j/stride;
         if(((sCol+sRow)%2)==0)
           curcolor = col1;
          else
           curcolor = col2;
         newTex.pixels[index++] = curcolor;
       }
       return newTex;
  }
  
  
   PImage genPlasmaGreen(int tWidth, int tHeight){//credit goes to Luis Gonzalez http://luis.net/
      PImage newTex = new PImage(tWidth,tHeight);
      int[] cls;
      int pal []=new int [128];
      float s1,s2;
      for (int i=0;i<128;i++) {
          s1=sin(i*PI/25);
          s2=sin(i*PI/50+PI/4);
          pal[i]=color(128+s1*128,128+s2*128,s1*128);
         }
 
      cls = new int[tWidth*tHeight];

     for(int x = 0;x<(tWidth);++x)
       for(int y = 0;y<tHeight;++y){
           cls[x+y*tWidth] = (int)((127.5 + +(127.5 * sin(x / 32.0)))+ (127.5 + +(127.5 * cos(y / 32.0))) + (127.5 + +(127.5 * sin(sqrt((x * x + y * y)) / 32.0)))  ) / 4;
       }
     for (int pixelCount = 0; pixelCount < cls.length; pixelCount++)
      {                   
        newTex.pixels[pixelCount] =  pal[(cls[pixelCount] +323)&127];
      }

        return newTex; 
   }
   
   PImage genPlasmaPurple(int tWidth, int tHeight){//credit goes to Deinyon Davies http://ddoodm.com/
      PImage newTex = new PImage(tWidth,tHeight);
      int[][] cls;
      int pal []=new int [255];
      float s1,s2;
      colorMode(HSB);
      for (int i=0;i<255;i++) {
          int s = int(128.0 + 128 * cos(PI * (float)i / 64.0));
          int b = int(128.0 + 128 * sin(PI * (float)i / 128.0));
          pal[i] = color(200,s,b+25);

         }
 
      cls = new int[tWidth][tHeight];

     for(int x = 0;x<(tWidth);++x)
       for(int y = 0;y<tHeight;++y){
           cls[x][y] = 128+int(128f + (128f * sin(x / 256f))+ 128f + (256f * pow(1/cos(y / 256f),-1))+ 128f * sin((float)x/tWidth)+ 128f + 128*sin((x+y)/128f)+ 128f + (128f * cos(sqrt(x*x + y*y) / 256f)));
       }
     for(int x = 0;x<(tWidth);++x)
       for(int y = 0;y<tHeight;++y){                 
        newTex.pixels[y+tWidth*x] =  pal[(cls[x][y]+24)%255];
      }
      colorMode(RGB);
        return newTex; 
   }
   
   PImage genRandom(int tWidth, int tHeight){
     PImage newTex = new PImage(tWidth,tHeight);
     float ns = 0.10;//increase for more noise
     float tt = 1;
     
     for(int i = 0;i<(tWidth);++i)
       for(int j = 0;j<tHeight;++j){
      
         float noise1 = getNoise(i*ns, j,ns*i*j);
         float noise2 = getNoise((i+tWidth)*ns, j*tt,noise1);
       
        
         int value = (int) (256* noise1) +50;
         int r = (int)noise2+20;
         int g = value-int(50);
         int b = value-int(50);
     
         if (r > 255) r = 255;
         if (r < 0) r = 0;
     
         if (g > 255) g = 255;
         if (g < 0) g = 0;
     
         if (b > 255) b = 255;
         if (b < 0) b = 0;
         color c = color(r&0xFF,g&0xFF,b&0xFF); 
         newTex.pixels[i+(j*tWidth)] = c;
       }
       return newTex;
  }
  
  
  
}
//http://stackoverflow.com/questions/18279456/any-simplex-noise-tutorials-or-resources
//Texturing and Modeling, A Procedural Approach
//http://webstaff.itn.liu.se/~stegu/TNM022-2005/perlinnoiselinks/perlin-noise-math-faq.html
//http://www.mrl.nyu.edu/~perlin/doc/oscar.html#noise
//simplex noise
