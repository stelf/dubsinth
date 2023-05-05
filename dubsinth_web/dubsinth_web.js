
const images = new Array(4);
let output;

p5.disableFriendlyErrors = true; //

const totalFrames = 360;
const LOC = "data/";
const PI = Math.PI;
const TWO_PI = 2 * PI;

const captions = ["05 MAY 23\nPlovdiv\n", "Cinnamint", "pNDi", "arkana\n"];
const welcome = "Absinthe\nHouse\npres.\n\nDUBSINTHE\n\n\n\n";
const allCaptions = captions.join("\n");

let currentIndex = 0;
let nextIndex = 1;
let morphProgress = 0;
let frequency = 4 * PI / totalFrames;
let clickStart = false;
let customFont;
let artNouveauFont;
let debug = false;
let song;

const [setupWidth, setupHeight] = [ 480, 854] ;

//const [setupWidth, setupHeight] = [ 240, 448 ] ;

function preload() {
  customFont = loadFont(LOC + "soria-font.ttf");
  artNouveauFont = loadFont(LOC + "ArtNouveau.ttf");
  soundFormats('m4a', 'mp3');
  song = loadSound(LOC + 'audio-cut-nomralize-18s', 
    () => console.log('sound loaded OK'),
    (e) => console.error(e));
  for (let i = 0; i < 4; i++) {
    images[i] = loadImage(LOC + "cup" + (i + 1) + ".png");
  }
}

function setup() {
  frameRate(20);
  createCanvas(setupWidth, setupHeight, P2D); // Set the size of the canvas to match your desired dimensions
  images.forEach(el => el.resize(setupHeight, setupHeight)); // Resize the image 
  output = createImage(height, height, RGB);
}


let distorted;

function applyDistortion(pg, amplitude, frequency) {
  distorted = createGraphics(pg.width, pg.height);
  //distorted.beginDraw();
  
  for (let y = 0; y < pg.height; y++) {
    for (let x = 0; x < pg.width; x++) {
      const offsetX = amplitude * Math.sin(TWO_PI * frequency * y / pg.height + frameCount * 0.0625);
      //const offsetY = amplitude * sin(TWO_PI * frequency * y / pg.height + frameCount * 0.125);
      const newX = x + int(offsetX);
      //int newY = y - int(offsetY);
      if (newX >= 0 && newX < pg.width) {
        const pixelColor = pg.get(newX, y);
        //const alpha = (int) random(200, 256); // Random alpha value between 100 and 200
        //const tintedColor = color(red(pixelColor), green(pixelColor), blue(pixelColor), alpha);
        distorted.set(x, y, pixelColor);
      }
    }
  }
  
  //distorted.endDraw();
  return distorted;
}


///////////// DISTORTED TEXT

let distCanvas;
let distCnt = 10;
let cloned;

function distortText() {
  const distTextSize= 25;
  textSize(distTextSize);
  textFont(artNouveauFont);

  const lines = split(welcome, '\n');
  let maxLine = "";
  lines.forEach( line => maxLine = maxLine.length > line.length ? maxLine : line);
  const lineHeight = textAscent() + textDescent();
  const tH = lineHeight * lines.length;
  let tW = textWidth(maxLine);
  const glowSize = 4;

  const randX = 100 + int(156 * Math.sin( frequency * ( frameCount % totalFrames) / 4));
  const textColor = color(230, 255, 220, randX);
  const glowColor = color(255, 255, 220);

  const yDistPos = height - tH - 80;
  const xDistPos = 20 + width/2 + (width/2 - tW)/2;

  if (!distCanvas) {
    distCanvas = createGraphics(
      int(tW + glowSize), 
      int(tH + glowSize));
  } else {
    distCnt++;
    if ( distCnt > 10 ) {    
      distCanvas.clear();
      distCnt = 0;
    } else {
      blendMode(ADD); // Change blend mode to ADD
      image(distCanvas, xDistPos, yDistPos );
      blendMode(BLEND); // Change blend mode to ADD
      image(cloned, xDistPos,  yDistPos );
      return;
    }
  }

  distCanvas.background(0, 0); // Set the background to transparent
  distCanvas.fill(textColor);
  distCanvas.textFont(artNouveauFont);
  distCanvas.textSize(distTextSize);
  distCanvas.textAlign(CENTER, TOP);
  distCanvas.text(welcome, tW/2 + glowSize/2, glowSize/2);  

  cloned = distCanvas.get();
  
  //canvas.background(0, 0); // Set the background to transparent
  distCanvas.fill(glowColor);
  distCanvas.text(welcome, tW/2 + glowSize/2, glowSize/2);  
  //canvas.endDraw();
    
  blendMode(ADD); // Change blend mode to ADD
  //distCanvas = applyDistortion(distCanvas, 6, 4);
  distCanvas.filter(BLUR, glowSize/2);
  image(distCanvas, xDistPos, yDistPos );

  blendMode(BLEND); // Change blend mode to ADD
  image(cloned, xDistPos,  yDistPos );
}

let glow, textWithGlow;

function glowText() {
  const loopFrame = frameCount % totalFrames;
  const textIdx = int(frequency * loopFrame / PI);
  let txt = captions[textIdx];
  let offsetY = 20 - 10 * textIdx - 80 * Math.cos(frequency * loopFrame / PI/2);
  let fadeAlpha = 256 * abs(Math.sin(frequency * loopFrame ));
   
  //if (2 > 1)  {
  if (frameCount > totalFrames)  {
    txt = allCaptions;
    offsetY = - 200 + 80 * Math.cos(frequency * loopFrame / PI/2);
  }
  
  const txtNumLines = txt.split('\n').length + 1;
  let maxLine = "";
  txt.split('\n').forEach( line => maxLine = maxLine.length > line.length ? maxLine : line);

  const glowSize = 5;
  const glowColor = color(170, 255, 110, (fadeAlpha*2) % 256);
  const textColor = color(242, 242, 242);
  const glowTextSize = 30;

  textFont(customFont);
  textSize(50);

  const tW = textWidth(maxLine) + glowSize*2;
  const tH = ( textAscent() + textDescent() ) * txtNumLines + 5;
  const textX = 10;
  const textY = height / 2 - (  textAscent() * 5 ) / 2;
  
  //if (2 > 1)  {
  if (frameCount > totalFrames)  {
    //textHeight = tH * ( captions.length + 1 );
    fadeAlpha = 256 * Math.sin((frequency / 4) * (frameCount % totalFrames));
  }

  //textSize(16);
  //text("fadeAlpha " + fadeAlpha, 10, 30); // Display the FPS at position (10, 20)

  if (glow === undefined ) {
    glow = createGraphics(
      int(tW + glowSize * 2), 
      int(tH + glowSize * 2));
  } else {
    glow.resizeCanvas(tW, tH);
  }
  glow.clear();
  glow.fill(glowColor);
  glow.textSize(glowTextSize);
  glow.textLeading(glowTextSize + 2);

  glow.textFont(customFont);
  glow.textAlign(LEFT, BASELINE); // Change text alignment
  glow.text(txt, glowSize*2, glow.height / 2 + textAscent() / 2); // Adjust text position
  //glow.endDraw();
  glow.filter(BLUR, glowSize/1.5);

  blendMode(ADD); // Change blend mode to SCREEN
  image(glow, textX, textY + offsetY);
  blendMode(BLEND); // Reset blend mode to default

  if (textWithGlow === undefined ) {
    textWithGlow = createGraphics(
      int(tW + glowSize * 2), 
      int(tH + glowSize * 2));
  } else {
    textWithGlow.resizeCanvas(tW, tH);
  }

  textWithGlow.clear();
  textWithGlow.background(0, 0); // Set the background to transparent
  textWithGlow.fill(textColor);
  textWithGlow.textSize(glowTextSize);
  textWithGlow.textLeading(glowTextSize + 2);

  textWithGlow.textFont(customFont);
  textWithGlow.textAlign(LEFT, BASELINE);
  textWithGlow.text(txt, glowSize*2, textWithGlow.height / 2 + textAscent() / 2); // actual text
  //textWithGlow.endDraw();
  
  tint(255, fadeAlpha);
  blendMode(ADD); // Change blend mode to SCREEN for the glow effect
  image(textWithGlow, textX, textY + offsetY);
  blendMode(BLEND); // Reset blend mode to default
  tint(255, 255);
}


function lerpImages() {
  let [currImg, nextImg] = [
    images[currentIndex], 
    images[nextIndex] 
   ];
  currImg.loadPixels();  nextImg.loadPixels();
  let [ curImgW, curImgH ] = [ 
    currImg.width, 
    currImg.height 
  ];
  output.loadPixels();
  const skewX = 0.85;

  const numBytes = curImgW * curImgH * 4;
  
  // Call the morphImages function
  //morphImages(currImg.pixels, nextImg.pixels, output.pixels, numBytes, morphProgress);

  let skip = 20 -  int(frameRate());
  if (skip < 2) { skip = 2; }
  if (skip > 10) { skip = 10; }
  
  for (let i = frameCount % skip; i < numBytes; i += skip) {
    const v1 = currImg.pixels[i];
    const v2 = nextImg.pixels[i];
    const cur =  output.pixels[i];
    let blended = v2;
    if (v1 !== v2 && v2 !== cur) {
      blended = v1 + (v2 - v1) * morphProgress;
    } 
    output.pixels[i]  = blended;
  }

  output.updatePixels();
  image(output, (width - output.width * skewX) / 2, 0, output.width * skewX, height);
  if (skip) {  
    text("skip: " + skip, 10, 35); // Display the FPS at position (10, 20)
  }
}

function mousePressed() {
  if (!clickStart) {
    clickStart = true;
    song.loop();
  }
}

function draw() {
  
  if (clickStart) {
    morphProgress += 1.0 / (totalFrames/4);
    if (morphProgress >= 1.0) {
      currentIndex = (currentIndex + 1) % 4;
      nextIndex = (nextIndex + 1) % 4;
      morphProgress = 0;
    }
  
    //background(128,128,128);
    lerpImages();  
    glowText();
    distortText();
    if (debug) {
      showFPS();
    }
    //exportVideo();
  } else {
    background(0,0,0);
    textFont(customFont);
    fill(255); // Set the text color to white
    textSize(24); // Set the text size
    text("click2play", (width - textWidth("click2play"))/2, height/2);
  }
  if (debug) {
    text("song: " + song.currentTime(), 10, 50); // Display the FPS at position (10, 20)
  }
}

function showFPS() {
  // Show FPS on screen
  textFont(customFont);
  fill(255); // Set the text color to white
  textSize(14); // Set the text size
  text("FPS: " + round(frameRate()), 10, 20); // Display the FPS at position (10, 20)
}
