import java.util.concurrent.CountDownLatch;
import java.io.*;
import java.util.*;
import java.util.StringTokenizer;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.FutureTask;



//Constants
final int  XRES = 896;
final int  YRES = 896;
final int TILESIZE = 128;
boolean drawupdate = true;
boolean mousedown = false;
Renderer sRenderer;
float sbrightness = 256;
float rSSOffset = 0.2; //values between 0.2-0.4 produce good results
float gamma = 0.95;
int inctiles = 0;
int StochasticSamples = 256;
PImage test,test2;

////////////WHATS LEFT
//cook torrence -->http://ruh.li/GraphicsCookTorrance.html and raytracer book!!!



//Environment mapping - cube vs sphere
//Montecarlo -> check out links & Sphere + cone tracing
//Transforms on objects i.e write quick few maths util functions for transformaing any object
//Triangles 
//Expand SDL
//Acceleration -->parallel, subdivision etc
//fix the refraction, de beers law, fresnel, schlick etc
//Photon mapping? quick try?



void setup(){

 size(XRES, YRES);
 test = new PImage(XRES,YRES/2);
 test2 = new PImage(XRES,YRES);
 frame.setTitle("Raytracer");
 frameRate(1000);
 sRenderer = new Renderer(new PVector(XRES/2,YRES-YRES/8), new PVector(XRES,YRES), 8,gamma); //<>//
 Render_Scene_Fast_Blocks(64,64);//initial render
 drawupdate = true;//reset so good rendering starts immediately
}

void draw(){
  
 if(drawupdate && !mousedown){
   
   //renderParallel();
  // Render_Scene_NOSSA(inctiles++);
   //Render_Scene_CombinationSSA(inctiles++);
  //Render_Scene_Parts_RegularSSA9(inctiles++);
   Render_Scene_Parts_RegularSSA5(inctiles++);
   //Render_Scene_StochasticSSA(inctiles++,StochasticSamples);
   //Render_Adaptive_SSA_Tiles(inctiles++);
   //image(test,0,0);
   //image(test2,0,0);
   //RenderSceneMAXintPartRenderSceneMAX();
 }  else if(mousedown)
   Render_Scene_Fast_Blocks(64,64);
  else
     frameRate(10);
  
}


void Render_Scene_Fast_Blocks(int powerx, int powery){
    int chunksx = (int)(XRES/powerx);
    int chunksy = (int)(YRES/powery);
    float[] rgb = {0.0,0.0,0.0};//black
    noStroke();
     
    for(int i = 0;i<XRES;i+=chunksx)
      for(int j = 0;j<YRES;j+=chunksy){
        rgb = sRenderer.calcPixelColor_NOSSA(i,j,XRES,YRES);
       
        fill(rgb[0]*sbrightness,rgb[1]*sbrightness,rgb[2]*sbrightness);
        rect(i,j,chunksx,chunksy);
      }
    
    drawupdate = false;
    
    
}
void Render_Scene_NOSSA(int tile){
  
  float[] rgb = {0.0,0.0,0.0};//black
  
  //preperation stuff
  int numXtiles = (int)(XRES/TILESIZE);
  int numYtiles = (int)(YRES/TILESIZE);
  int numTiles =  numXtiles*numYtiles;
  if(tile>=numTiles){
    drawupdate = false;
    return;
  }
  loadPixels();
  
      int ia = TILESIZE*(tile%numXtiles);
      int ja = TILESIZE*(tile/numYtiles);
      for(int i = 0;i<TILESIZE;++i)
        for(int j = 0;j<TILESIZE;++j){
          
         rgb = sRenderer.calcPixelColor_NOSSA(ia+i,ja+j,XRES,YRES);
         color c = color(rgb[0]*sbrightness,rgb[1]*sbrightness,rgb[2]*sbrightness); 
         pixels[XRES*(ja+j)+(ia+i)] = c;
        }
        
  updatePixels();
  
}

void Render_Adaptive_SSA_Tiles(int tile){
  //preperation stuff
  int numXtiles = (int)(XRES/TILESIZE);
  int numYtiles = (int)(YRES/TILESIZE);
  int numTiles =  numXtiles*numYtiles;
  if(tile>=numTiles){
    drawupdate = false;
    return;
   }
  

  PImage Adapt = new PImage(TILESIZE*2,TILESIZE*2); //<>//
  
  int ia = TILESIZE*(tile%numXtiles);
  int ja = TILESIZE*(tile/numYtiles);
          
  Adapt = sRenderer.calcPixelColor_ADAPTIVESSA(ia,ja,ia+TILESIZE,ja+TILESIZE,XRES,YRES);
   loadPixels();
  for(int i = 0;i<TILESIZE;++i)
        for(int j = 0;j<TILESIZE;++j){        
         pixels[XRES*(ja+j)+(ia+i)] = Adapt.pixels[(j)*TILESIZE+(i)];
        }
      updatePixels();
  }
  


void Render_Regular_SSA(){
  float[] rgb = {0.0,0.0,0.0};//black
  
  //preperation stuff
  int numXtiles = (int)(XRES/TILESIZE);
  int numYtiles = (int)(YRES/TILESIZE);
  int numTiles =  numXtiles*numYtiles;
  
  loadPixels();
  for(int tile = 0;tile<numTiles;++tile){
    
      int ia = TILESIZE*(tile%numXtiles);
      int ja = TILESIZE*(tile/numYtiles);
      for(int i = 0;i<TILESIZE;++i)
        for(int j = 0;j<TILESIZE;++j){
          
         rgb = sRenderer.calcPixelColor_REGULARSSA_9(ia+i,ja+j,XRES,YRES,rSSOffset);
         color c = color(rgb[0]*sbrightness,rgb[1]*sbrightness,rgb[2]*sbrightness); 
         pixels[XRES*(ja+j)+(ia+i)] = c;
        }
        
      }
  updatePixels();
  drawupdate = false;
}

void Render_Scene_CombinationSSA(int tile){
  
  float[] rgb = {0.0,0.0,0.0};//black
  
  //preperation stuff
  int numXtiles = (int)(XRES/TILESIZE);
  int numYtiles = (int)(YRES/TILESIZE);
  int numTiles =  numXtiles*numYtiles;
  if(tile>=numTiles){
    drawupdate = false;
    return;
  }
  loadPixels();
  
      int ia = TILESIZE*(tile%numXtiles);
      int ja = TILESIZE*(tile/numYtiles);
      for(int i = 0;i<TILESIZE;++i)
        for(int j = 0;j<TILESIZE;++j){
          
         rgb = sRenderer.calcPixelColor_STOCHASTICREGULARSSA_18(ia+i,ja+j,XRES,YRES,rSSOffset);
         color c = color(rgb[0]*sbrightness,rgb[1]*sbrightness,rgb[2]*sbrightness); 
         pixels[XRES*(ja+j)+(ia+i)] = c;
        }
        
  updatePixels();
  
}


void Render_Scene_Parts_RegularSSA9(int tile){
  
  float[] rgb = {0.0,0.0,0.0};//black
  
  //preperation stuff
  int numXtiles = (int)(XRES/TILESIZE);
  int numYtiles = (int)(YRES/TILESIZE);
  int numTiles =  numXtiles*numYtiles;
  if(tile>=numTiles){
    drawupdate = false;
    return;
  }
  loadPixels();
  
      int ia = TILESIZE*(tile%numXtiles);
      int ja = TILESIZE*(tile/numYtiles);
      for(int i = 0;i<TILESIZE;++i)
        for(int j = 0;j<TILESIZE;++j){
          
         rgb = sRenderer.calcPixelColor_REGULARSSA_9(ia+i,ja+j,XRES,YRES,rSSOffset);
         color c = color(rgb[0]*sbrightness,rgb[1]*sbrightness,rgb[2]*sbrightness); 
         pixels[XRES*(ja+j)+(ia+i)] = c;
        }
        
  updatePixels();
  
}

void Render_Scene_Parts_RegularSSA5(int tile){
  
  float[] rgb = {0.0,0.0,0.0};//black
  
  //preperation stuff
  int numXtiles = (int)(XRES/TILESIZE);
  int numYtiles = (int)(YRES/TILESIZE);
  int numTiles =  numXtiles*numYtiles;
  if(tile>=numTiles){
    drawupdate = false;
    return;
  }
  loadPixels();
  
      int ia = TILESIZE*(tile%numXtiles);
      int ja = TILESIZE*(tile/numYtiles);
      for(int i = 0;i<TILESIZE;++i)
        for(int j = 0;j<TILESIZE;++j){
          
         rgb = sRenderer.calcPixelColor_REGULARSSA_5(ia+i,ja+j,XRES,YRES,rSSOffset);
         color c = color(rgb[0]*sbrightness,rgb[1]*sbrightness,rgb[2]*sbrightness); 
         pixels[XRES*(ja+j)+(ia+i)] = c;
        }
        
  updatePixels();
  
}

void Render_Scene_StochasticSSA(int tile, int Samples){
  
  float[] rgb = {0.0,0.0,0.0};//black
  
  //preperation stuff
  int numXtiles = (int)(XRES/TILESIZE);
  int numYtiles = (int)(YRES/TILESIZE);
  int numTiles =  numXtiles*numYtiles;
  if(tile>=numTiles){
    drawupdate = false;
    return;
  }
  loadPixels();
  
      int ia = TILESIZE*(tile%numXtiles);
      int ja = TILESIZE*(tile/numYtiles);
      for(int i = 0;i<TILESIZE;++i)
        for(int j = 0;j<TILESIZE;++j){
          
         rgb = sRenderer.calcPixelColor_STOCHASTICSSA(ia+i,ja+j,XRES,YRES,Samples,-rSSOffset,rSSOffset);
         color c = color(rgb[0]*sbrightness,rgb[1]*sbrightness,rgb[2]*sbrightness); 
         pixels[XRES*(ja+j)+(ia+i)] = c;
        }
        
  updatePixels();
  
}

void RenderHalf1(){
  int nX = int(XRES);
  int nY = int(YRES/2);
  float[] rgb = {0.0,0.0,0.0};//black
  for(int i = 0;i<nX;i++)
      for(int j = 0;j<nY;j++){
        rgb = sRenderer.calcPixelColor_REGULARSSA_9(i,j,XRES,YRES,rSSOffset);
       
        color c = color(rgb[0]*sbrightness,rgb[1]*sbrightness,rgb[2]*sbrightness); 
        test.pixels[XRES*(j)+(i)] = c;
      }
   
}

void RenderHalf2(){
  int nY = int(YRES/2);
  float[] rgb = {0.0,0.0,0.0};//black
  for(int i = 0;i<XRES;i++)
      for(int j = nY;j<YRES;j++){
        rgb = sRenderer.calcPixelColor_REGULARSSA_9(i,j,XRES,YRES,rSSOffset);
       
        color c = color(rgb[0]*sbrightness,rgb[1]*sbrightness,rgb[2]*sbrightness); 
        test2.pixels[1] = c;
      }
    
}


void renderParallel(){
 ParallelTasks tasks = new ParallelTasks();
    final Runnable Half1 = new Runnable() {
        public void run()
        {
            try
            {
                RenderHalf1();
            }
            catch (Exception e)
            {
            }
        }
    };
    
    final Runnable Half2 = new Runnable() {
        public void run()
        {
            try
            {
                RenderHalf2();
            }
            catch (Exception e)
            {
            }
        }
    };
    
    tasks.add(Half1);
    tasks.add(Half2);
   
    
    
    try{
      tasks.go();
    }catch(Exception e){
      
    }
    
    System.err.println("Finished"); 
    drawupdate = false;
}




void mousePressed() {
  if(!drawupdate) { 
    drawupdate = true;
    mousedown = true;
  }


}

void mouseDragged() {
  if(mousedown) {
     sRenderer.updateCamMouse(new PVector(mouseX,mouseY),new PVector(XRES,YRES));
     drawupdate = true;
  }
}

void mouseReleased() {
  mousedown = false;
  drawupdate = true;
  inctiles = 0;
}
///parallel stuff
//http://www.flipcode.com/archives/Raytracing_Topics_Techniques-Part_3_Refractions_and_Beers_Law.shtml


public class ParallelTasks
{
    private final Collection<Runnable> tasks = new ArrayList<Runnable>();

    public ParallelTasks()
    {
    }

    public void add(final Runnable task)
    {
        tasks.add(task);
    }

    public void go() throws InterruptedException
    {
        final ExecutorService threads = Executors.newFixedThreadPool(Runtime.getRuntime()
                .availableProcessors());
        try
        {
            final CountDownLatch latch = new CountDownLatch(tasks.size());
            for (final Runnable task : tasks)
                threads.execute(new Runnable() {
                    public void run()
                    {
                        try
                        {
                            task.run();
                        }
                        finally
                        {
                            latch.countDown();
                        }
                    }
                });
            latch.await();
        }
        finally
        {
            threads.shutdown();
        }
    }
}

// ...

/*public static void main(final String[] args) throws Exception
{
    ParallelTasks tasks = new ParallelTasks();
    final Runnable waitOneSecond = new Runnable() {
        public void run()
        {
            try
            {
                Thread.sleep(1000);
            }
            catch (InterruptedException e)
            {
            }
        }
    };
    tasks.add(waitOneSecond);
    tasks.add(waitOneSecond);
    tasks.add(waitOneSecond);
    tasks.add(waitOneSecond);
    final long start = System.currentTimeMillis();
    tasks.go();
    System.err.println(System.currentTimeMillis() - start);
}*/
