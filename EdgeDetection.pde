//detects edges for adaptive Supersampling

class SobelEdgeDetection
{
 
  // Sobel Edge Detection strandard, this applies the edge detection algorithm across the entire image and returns the edge image
  public PImage findEdgesAll(PImage img, int tolerance) //http://homepages.inf.ed.ac.uk/rbf/HIPR2/sobel.htm
  {
    PImage buf = createImage( img.width, img.height, ARGB );
 
    int GX[][] = new int[3][3];
    int GY[][] = new int[3][3];
    int sumRx = 0;
    int sumGx = 0;
    int sumBx = 0;
    int sumRy = 0;
    int sumGy = 0;
    int sumBy = 0;
    int finalSumR = 0;
    int finalSumG = 0;
    int finalSumB = 0;
 
    // 3x3 Sobel Mask for X
    GX[0][0] = -1;
    GX[0][1] = 0;
    GX[0][2] = 1;
    GX[1][0] = -2;
    GX[1][1] = 0;
    GX[1][2] = 2;
    GX[2][0] = -1;
    GX[2][1] = 0;
    GX[2][2] = 1;
 
    // 3x3 Sobel Mask for Y
    GY[0][0] =  1;
    GY[0][1] =  2;
    GY[0][2] =  1;
    GY[1][0] =  0;
    GY[1][1] =  0;
    GY[1][2] =  0;
    GY[2][0] = -1;
    GY[2][1] = -2;
    GY[2][2] = -1;
 
    buf.loadPixels(); 
 
    for(int y = 0; y < img.height; y++)
    {
      for(int x = 0; x < img.width; x++)
      {
        if(y==0 || y==img.height-1) {
        }
        else if( x==0 || x == img.width-1 ) {
        }
        else
        {
 
          // Convolve across the X axis and return gradiant aproximation
          for(int i = -1; i <= 1; i++)
            for(int j = -1; j <= 1; j++)
            {
              color col =  img.get(x + i, y + j);
              float r = red(col);
              float g = green(col);
              float b = blue(col);
 
 
              sumRx += r * GX[ i + 1][ j + 1];
              sumGx += g * GX[ i + 1][ j + 1];
              sumBx += b * GX[ i + 1][ j + 1];
 
            }
 
          // Convolve across the Y axis and return gradiant aproximation
          for(int i = -1; i <= 1; i++)
            for(int j = -1; j <= 1; j++)
            {
              color col =  img.get(x + i, y + j);
              float r = red(col);
              float g = green(col);
              float b = blue(col);
 
 
              sumRy += r * GY[ i + 1][ j + 1];
              sumGy += g * GY[ i + 1][ j + 1];
              sumBy += b * GY[ i + 1][ j + 1];
 
            }
 
          finalSumR = abs(sumRx) + abs(sumRy);
          finalSumG = abs(sumGx) + abs(sumGy);
          finalSumB = abs(sumBx) + abs(sumBy);
 
 
          // I only want to return a black or a white value, here I determine the greyscale value,
          // and if it is above a tolerance, then set the colour to white
 
          float gray = (finalSumR + finalSumG + finalSumB) / 3;
          if(gray > tolerance)
          {
            finalSumR = 0;
            finalSumG = 0;
            finalSumB = 0;
          }
          else
          {
            finalSumR = 255;
            finalSumG = 255;
            finalSumB = 255;
          }
 
 
 
          buf.pixels[ x + (y * img.width) ] = color(finalSumR, finalSumG, finalSumB);
 
          sumRx=0;
          sumGx=0;
          sumBx=0;
          sumRy=0;
          sumGy=0;
          sumBy=0;
 
        }
 
      }
 
    }
 
    buf.updatePixels();
 
    return buf;
  }
 
 
}
