import com.hamoid.*;
import processing.opengl.*;

VideoExport videoExport;

PImage[] images = new PImage[4];
PImage output;

int totalFrames = 360;
String LOC = "/Users/larodeev/Work/dubsinth/";

String[] captions = { "selected by", "Cinnamint", "pNDi", "arkana"  };
String welcome = "Absinthe bar\n\npresents\n\n DUBSINTHE \n\n 05 may 2023";

int currentIndex = 0;
int nextIndex = 1;
float morphProgress = 0;
float fadeAlpha = 0;  
float frequency =  4*PI / totalFrames;
PFont customFont;
PFont artNouveauFont;
PGraphics blendedBuffer; // this will hold the blended image

void setup() {
  videoExport = new VideoExport(this, LOC + "output.mp4"); // Create a new video export object
  videoExport.setFrameRate(20); // Set the frame rate for the video
  videoExport.startMovie(); // Begin the video export

  blendedBuffer = createGraphics(width, height);
  frameRate(20);
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
  int distTextSize= 23;
  textSize(distTextSize);
  textFont(artNouveauFont);
  
  String[] lines = split(welcome, '\n');
  float lineHeight = textAscent() + textDescent();
  float textHeight = lineHeight * lines.length;
  float textWidth  = textWidth(welcome);

  int randX = 230 + int(30 * sin(TWO_PI / frameCount / 4));
  color textColor = color(randX, randX, randX, 200);
  color glowColor = color(200, 255, 200);

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

  blendMode(ADD); // Change blend mode to ADD
  canvas = applyDistortion(canvas, 6, 4);
  canvas.filter(BLUR, 3);
  image(canvas, 30 + width/2 + (width/2 - textWidth)/2,  height - textHeight - 50 );

  blendMode(BLEND); // Change blend mode to ADD
  image(cloned, 30 + width/2 + (width/2 - textWidth)/2,   height - textHeight - 50 );
}

void glowText() {
  String txt = captions[int(frequency * ( frameCount % totalFrames) / PI)];
  float offsetY = 20-80 * cos(frequency * (frameCount % totalFrames) / PI/2);

  int glowSize = 5;
  color glowColor = color(70, 255, 110, (fadeAlpha*2) % 256);
  color textColor = color(242, 242, 242);

  textSize(50);
  textFont(customFont);

  float textWidth = textWidth(txt) + glowSize*2;
  float textHeight = textAscent() + textDescent();
  float textX = 50;
  float textY = height / 2 - textAscent() / 2;
  
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
  glow.filter(BLUR, glowSize/2);

  blendMode(ADD); // Change blend mode to SCREEN
  image(glow, textX, textY + offsetY);
  blendMode(BLEND); // Reset blend mode to default

  PGraphics textWithGlow = createGraphics(
    int(textWidth + glowSize * 2), 
    int(textHeight + glowSize * 2));
  textWithGlow.beginDraw();
  textWithGlow.background(0, 0); // Set the background to transparent
  //textWithGlow.image(glow, 0, -glowSize);
  textWithGlow.fill(textColor);
  textWithGlow.textSize(50);
  textWithGlow.textFont(customFont);
  textWithGlow.textAlign(CENTER, CENTER);
  textWithGlow.text(txt, textWithGlow.width / 2, textWithGlow.height / 2 - textDescent() / 2); // actual text
  textWithGlow.endDraw();

  fadeAlpha = 256 * abs(sin(frequency * (frameCount % totalFrames)));
  
  tint(255, fadeAlpha);
  blendMode(ADD); // Change blend mode to SCREEN for the glow effect
  image(textWithGlow, textX, textY + offsetY);
  blendMode(BLEND); // Reset blend mode to default
  tint(255,255);
}

void lerpImages() {
  images[currentIndex].loadPixels();
  images[nextIndex].loadPixels();
  output.loadPixels();
  
  for (int i = 0; i < images[currentIndex].width * images[currentIndex].height; i++) {  
    color c1 = images[currentIndex].pixels[i];
    color c2 = images[nextIndex].pixels[i];
    color blended = lerpColor(c1, c2, morphProgress);
  
    // Only update changed pixels
    if (blended != output.pixels[i]) {
      output.pixels[i] = blended;
    }
  }

  output.updatePixels();
  image(output, - (height - width )/2, 0);
}

void draw() {
  
  morphProgress += 1.0 / (totalFrames/4);
  if (morphProgress >= 1.0) {
    currentIndex = (currentIndex + 1) % 4;
    nextIndex = (nextIndex + 1) % 4;
    morphProgress = 0;
  }

  //background(0);

  lerpImages();  
  //glowText();
  //distortText();
  //showFPS();
  exportVideo();
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

color lerpColor(color c1, color c2, float amt) {
  float r = lerp(red(c1), red(c2), amt);
  float g = lerp(green(c1), green(c2), amt);
  float b = lerp(blue(c1), blue(c2), amt);
  return color(r, g, b);
}

/*

ffmpeg -i dubsinthe2.mp4 -vf "fps=20,scale=-1:-1:flags=lanczos,palettegen=stats_mode=diff" -y palette.png
ffmpeg -i dubsinthe2.mp4 -i palette.png -lavfi "fps=20,scale=-1:-1:flags=lanczos [x]; [x][1:v] paletteuse=dither=bayer" dubsinthe2.gif

*/
