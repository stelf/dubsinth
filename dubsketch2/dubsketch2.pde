import com.hamoid.*;
import processing.opengl.*;

VideoExport videoExport;

PImage[] images = new PImage[4];
PImage output;

int totalFrames = 360;
String LOC = "";

String[] captions = { "05 MAY 23\nPlovdiv", "Cinnamint", "pNDi", "arkana"  };
String welcome = "Absinthe\nHouse\npres.\n\nDUBSINTHE\n\n\n\n";
String  allCaptions = join(captions, "\n");

int currentIndex = 0;
int nextIndex = 1;
float morphProgress = 0;
float frequency =  4*PI / totalFrames;
PFont customFont;
PFont artNouveauFont;
PGraphics blendedBuffer; // this will hold the blended image

void setup() {
  videoExport = new VideoExport(this, LOC + "output-vertical.mp4"); // Create a new video export object
  videoExport.setFrameRate(20); // Set the frame rate for the video
  videoExport.startMovie(); // Begin the video export

  blendedBuffer = createGraphics(width, height);
  frameRate(21);
  size(480, 854, P3D); // Set the size of the canvas to match your desired dimensions
  customFont = createFont("soria-font.ttf", 30);
  artNouveauFont = createFont("ArtNouveau.ttf", 50);
  for (int i = 0; i < 4; i++) {
    images[i] = loadImage(LOC + "cup" + (i+1) + ".png");
    images[i].resize(height, height); // Resize the image to the desired dimensions
  }
  output = createImage(height, height, RGB);
}

PGraphics applyDistortion(PGraphics pg, float amplitude, float frequency) {
  PGraphics distorted = createGraphics(pg.width, pg.height);
  distorted.beginDraw();
  
  for (int y = 0; y < pg.height; y++) {
    for (int x = 0; x < pg.width; x++) {
      float offsetX = amplitude * sin(TWO_PI * frequency * y / pg.height + frameCount * 0.0625);
      //float offsetY = amplitude * sin(TWO_PI * frequency * y / pg.height + frameCount * 0.125);
      int newX = x + int(offsetX);
      //int newY = y - int(offsetY);
      if (newX >= 0 && newX < pg.width) {
        color pixelColor = pg.get(newX, y);
        //int alpha = (int) random(200, 256); // Random alpha value between 100 and 200
        //color tintedColor = color(red(pixelColor), green(pixelColor), blue(pixelColor), alpha);
        distorted.set(x, y, pixelColor);
      }
    }
  }
  
  distorted.endDraw();
  return distorted;
}

void distortText() {
  int distTextSize= 24;
  textSize(distTextSize);
  textFont(artNouveauFont);
  
  String[] lines = split(welcome, '\n');
  float lineHeight = textAscent() + textDescent();
  float textHeight = lineHeight * lines.length;
  float textWidth  = textWidth(welcome);

  int randX = 230 + int(30 * sin(TWO_PI / frameCount / 4));
  color textColor = color(randX, randX, randX, 200);
  color glowColor = color(255, 255, 220);

  PGraphics canvas = createGraphics(
    int(textWidth), 
    int(textHeight));
  canvas.beginDraw();
  canvas.background(0, 0); // Set the background to transparent
  canvas.fill(textColor);
  canvas.textFont(artNouveauFont);
  canvas.textSize(distTextSize);
  canvas.textAlign(CENTER, CENTER);
  canvas.text(welcome, textWidth/2, textHeight / 2);  

  PImage cloned = canvas.get();
  
  //canvas.background(0, 0); // Set the background to transparent
  canvas.fill(glowColor);
  canvas.text(welcome, textWidth/2, textHeight / 2);  
  canvas.endDraw();
  
  float yDistPos = height - (textHeight - lineHeight) + 10;
  float xDistPos = 20 + width/2 + (width/2 - textWidth)/2;
  
  blendMode(ADD); // Change blend mode to ADD
  canvas = applyDistortion(canvas, 6, 4);
  canvas.filter(BLUR, 3);
  image(canvas, xDistPos ,  yDistPos );

  blendMode(BLEND); // Change blend mode to ADD
  image(cloned, xDistPos,  yDistPos );
}

void glowText() {
  int loopFrame = frameCount % totalFrames;
  int textIdx = int(frequency * loopFrame / PI);
  String txt = captions[textIdx];
  float offsetY = 20 - 10 * textIdx - 80 * cos(frequency * loopFrame / PI/2);
  float fadeAlpha = 256 * abs(sin(frequency * loopFrame ));
 
  long txtNumLines = txt.chars().filter(ch -> ch == '\n').count() + 1;
  
  //if (2 > 1)  {
  if (frameCount > totalFrames)  {
    txt = allCaptions;
    offsetY = - 20 + 80 * cos(frequency * loopFrame / PI/2);
  }

  int glowSize = 5;
  color glowColor = color(170, 255, 110, (fadeAlpha*2) % 256);
  color textColor = color(242, 242, 242);

  textFont(customFont);
  textSize(50);

  float textWidth = textWidth(txt) + glowSize*2;
  float textHeight = ( textAscent() + textDescent() ) * txtNumLines;
  float textX = 10;
  float textY = height / 2 - (  textAscent() * 5 ) / 2;
  
  //if (2 > 1)  {
  if (frameCount > totalFrames)  {
    textHeight = textHeight * ( captions.length + 1 );
    fadeAlpha = 256 * sin((frequency / 4) * (frameCount % totalFrames));
  }

  //textSize(16);
  //text("fadeAlpha " + fadeAlpha, 10, 30); // Display the FPS at position (10, 20)

  PGraphics glow = createGraphics(
    int(textWidth + glowSize * 2), 
    int(textHeight + glowSize * 2));
  glow.beginDraw();
  glow.fill(glowColor);
  glow.textSize(50);
  glow.textFont(customFont);
  glow.textAlign(LEFT, BASELINE); // Change text alignment
  glow.text(txt, glowSize*2, glow.height / 2 + textAscent() / 2); // Adjust text position
  glow.endDraw();
  glow.filter(BLUR, glowSize/1.5);

  blendMode(ADD); // Change blend mode to SCREEN
  image(glow, textX, textY + offsetY);
  blendMode(BLEND); // Reset blend mode to default

  PGraphics textWithGlow = createGraphics(
    int(textWidth + glowSize * 2), 
    int(textHeight + glowSize * 2));
  textWithGlow.beginDraw();
  textWithGlow.background(0, 0); // Set the background to transparent
  textWithGlow.fill(textColor);
  textWithGlow.textSize(50);
  textWithGlow.textFont(customFont);
  textWithGlow.textAlign(LEFT, BASELINE);
  textWithGlow.text(txt, glowSize*2, textWithGlow.height / 2 + textAscent() / 2); // actual text
  textWithGlow.endDraw();
  
  tint(255, fadeAlpha);
  blendMode(ADD); // Change blend mode to SCREEN for the glow effect
  image(textWithGlow, textX, textY + offsetY);
  blendMode(BLEND); // Reset blend mode to default
  tint(255, 255);
}

int step = 3;

void lerpImages() {
  images[currentIndex].loadPixels();
  images[nextIndex].loadPixels();
  output.loadPixels();
  float skewX = 0.85;
  
  step = (int(frameRate) < 20) ? (20 - int(frameRate)) : 1;
  //step = 16;
   
  //float rf = 0.8 + morphProgress/2 % 0.2;
  //float gf = 0.9 + morphProgress/2 % 0.2;
  
  //if (rf > 1) rf =  2 - rf;
  //if (gf > 1) gf =  2 - gf;
    float ih = images[currentIndex].height;  
    float iw = images[currentIndex].width;

  for (int i = frameCount % step; i < images[currentIndex].pixels.length; i+= step) {
    int pixelValue1 = images[currentIndex].pixels[i];
    int pixelValue2 = images[nextIndex].pixels[i];
  
    // Interpolate the RGBA components using an inline expression and morphProgress
    int aMorphed = (int)(((pixelValue1 >> 24) & 0xFF) * (1 - morphProgress) + ((pixelValue2 >> 24) & 0xFF) * morphProgress);
    int rMorphed = (int)(((pixelValue1 >> 16) & 0xFF) * (1 - morphProgress) + ((pixelValue2 >> 16) & 0xFF) * morphProgress);
    int gMorphed = (int)(((pixelValue1 >> 8) & 0xFF) * (1 - morphProgress) + ((pixelValue2 >> 8) & 0xFF) * morphProgress);
    int bMorphed = (int)((pixelValue1 & 0xFF) * (1 - morphProgress) + (pixelValue2 & 0xFF) * morphProgress);

    float rf = abs(sin(radians(frameCount + i/ih)));
    float gf = abs(cos(radians((frameCount + i)%iw)));
        
    //if (rMorphed + bMorphed + gMorphed < 50) 
    //  rMorphed = bMorphed = gMorphed = 0;
    // Combine the interpolated RGBA components back into an integer
    int morphedPixelValue = (aMorphed << 24) | (int(rf*rMorphed) << 16) | (int(gf*gMorphed) << 8) | bMorphed;

    // Set the new pixel value in the morphedImage
    output.pixels[i] = morphedPixelValue;
  }

  output.updatePixels();
  image(output, (width - output.width * skewX) / 2, 0, output.width * skewX, height);
  
  output.filter(THRESHOLD, 0.3);
 // output.filter(BLUR, 4);
 // blendMode(ADD); // Change blend mode to SCREEN for the glow effect
//  image(output, (width - output.width * skewX) / 2, 0, output.width * skewX, height);
//text("rf: " + rf, 10, 60); // Display the FPS at position (10, 20)
}

void draw() {
  
  morphProgress += 1.0 / (totalFrames/4);
  if (morphProgress >= 1.0) {
    currentIndex = (currentIndex + 1) % 4;
    nextIndex = (nextIndex + 1) % 4;
    morphProgress = 0;
  }

  int startTime = millis();

  background(0);
  lerpImages();  
  //glowText();
  distortText();
  showFPS();
 
//  exportVideo();
  int endTime = millis();
  showCost(startTime, endTime);
  text("Step: " + step, 10, 40); 

}

void exportVideo() {   
   if (frameCount < totalFrames) {  
    videoExport.saveFrame();
  }
  
  if (frameCount == totalFrames ) {
    videoExport.endMovie();
  }
}

void showFPS() {
  // Show FPS on screen
  fill(255); // Set the text color to white
  textSize(12); // Set the text size
  text("FPS: " + round(frameRate), 10, 20); // Display the FPS at position (10, 20)
}

void showCost(int startTime, int endTime) {
  int processingTime = endTime - startTime;
  text("Processing time: " + processingTime, 10, 50); 
}

color lerpColor(color c1, color c2, float amt) {
  float r = lerp(red(c1), red(c2), amt);
  float g = lerp(green(c1), green(c2), amt);
  float b = lerp(blue(c1), blue(c2), amt);
  return color(r, g, b);
}

/*

ffmpeg -i output.mp4 -vf "fps=20,scale=-1:-1:flags=lanczos,palettegen=stats_mode=diff" -y palette.png
ffmpeg -i output.mp4 -i palette.png -lavfi "fps=20,scale=-1:-1:flags=lanczos [x]; [x][1:v] paletteuse=dither=bayer" cuponly.gif

*/
