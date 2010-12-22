 /*
  Copyright (c) 2010 by Dan O'Shea (http://djoshea.com/), Ryan O'Shea (http://ryanoshea.com/). 
 
  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

int screenX = 1440;
int screenY = 900;
int MAX_BRANCH_LENGTH = 100;
float fractionSingleBranchPoints = 0.6;

SnowflakeManager mgr;
PFont fontGreeting, fontFooter;

void setup() {
  size(screenX, screenY);
   
  // initialize greeting font
  fontGreeting = loadFont("ScriptMTBold-72.vlw");
  fontFooter = loadFont("MyriadWebPro-12.vlw");
   
  mgr = new SnowflakeManager();
  for(int i = 0; i < 30; i++)
    mgr.spawnSnowflake(true);
}

void draw() {
  background(20, 0, 20);
  smooth();
  
  // draw merry christmas text in center
  drawGreeting();
  
  mgr.drawAll();
}

void drawGreeting() {
  float startFade = 2000;
  float endFade = 5000;
  float time = millis();
  
  float alpha;
  float r1 = 255;
  float g1;
  float b1;
  float r2;
  float g2 = 255;
  float b2;
    
  if(time <= startFade) {
    alpha = 255;
    g1 = 150;
    b1 = 150;
    r2 = 150;
    b2 = 150;
  } else if(time > endFade) {
    alpha = 55;
    r1 = 255;
    g1 = 255;
    b1 = 255;
    r2 = 255; 
    g2 = 255;
    b2 = 255;
  } else {
    alpha = 255 - 200.0*(time - startFade)/(endFade-startFade);
    g1 = 150.0 + 105.0*(time - startFade)/(endFade-startFade);
    b1 = 150.0 + 105.0*(time - startFade)/(endFade-startFade);
    r2 = 150.0 + 105.0*(time - startFade)/(endFade-startFade);
    b2 = 150.0 + 105.0*(time - startFade)/(endFade-startFade);
  }
    
  textFont(fontGreeting);
  textAlign(CENTER, BASELINE);
  fill(r1, g1, b1, alpha);
  textSize(80);
  text("Merry Christmas",screenX/2, screenY/2-100);
  fill(r2, g2, b2, alpha);
  textSize(50);
  text("From the O'Shea Family!", screenX/2, screenY/2-35);
 
 textFont(fontFooter);
 textAlign(RIGHT, BOTTOM);
 fill(255, 200);
 textSize(12);
 text("christmas 2010", screenX-5, screenY-5);
}

float animationPhase(float periodSec, float offset) {
  //based on time elapsed, returns a value that gradually increases from 0 to TWO_PI (and cycles back to 0)
  //every periodSec seconds, starting with an initial offset
  return (TWO_PI/periodSec*millis()/1000.0 + offset) % TWO_PI;
}

class SnowflakeManager {
  
  ArrayList<Snowflake> flakes = new ArrayList<Snowflake>();
  
  void spawnSnowflake(boolean firstSpawning) {
    int upperLimit = firstSpawning ? -2*screenY : -screenY;
    Vector center = new Vector(random(screenX), random(upperLimit,-MAX_BRANCH_LENGTH));
    Snowflake flake = new Snowflake(center);
    flakes.add(flake);
  }
  
  void drawAll() {
    Iterator<Snowflake> itr = flakes.iterator();
    ArrayList<Snowflake> deadFlakes = new ArrayList<Snowflake>();
    
    while(itr.hasNext()) {
      Snowflake flake = itr.next();
      flake.descend();
      //check to see if flake has fallen off screen, mark as dead
      if (flake.isBelowScreen()) {
        deadFlakes.add(flake);
      } else {
        flake.draw();
      }
    }
    
    // remove flakes marked as dead and add new one (can't do this iterating over flakes)
    itr = deadFlakes.iterator();
    while(itr.hasNext()) {
      flakes.remove(flakes.indexOf(itr.next()));
      spawnSnowflake(false);
    }
  }
}

class Snowflake {
  Vector center;
  Vector origCenter;
  float birthTime;//in milliseconds
  float speed;//in pixels per second
  float angleOffsetBaseline;
  float lateralMotionAmplitude, lateralMotionOffset;
  float lengthMainBranches;
  float angularSpeed;
  float branchFraction = random(0.2, 0.8); // + 0.2*sin(animationPhase(8,0));
  float lengthFraction = random(0.4, 0.6);
  float angle = random(PI/4, PI/2.5); // + PI/12.0*sin(animationPhase(4,0));
  float myColor;
  int numBranchPoints;
  int nMainBranches = Math.round(random(5, 7));
  
  Snowflake(Vector _center){
    center = _center.clone();
    origCenter = _center.clone();
    birthTime = millis();
    angleOffsetBaseline = random(TWO_PI);
    speed = random(50,100);
    lateralMotionAmplitude = random(10,50);
    lateralMotionOffset = random(TWO_PI);
    descend();
    lengthMainBranches = random(30, MAX_BRANCH_LENGTH);
    angularSpeed = random(-.25, .25);
    myColor = random(100, 255);
    if(random(1) > fractionSingleBranchPoints)
      numBranchPoints = 2;
    else
      numBranchPoints = 1;
  }
  
  void descend() {
    float age = (millis() - birthTime)/1000.0;
    center.y = origCenter.y + speed*age;    
    center.x = origCenter.x + lateralMotionAmplitude*sin(animationPhase(3,lateralMotionOffset));
  }
  
  boolean isBelowScreen() {
    return center.y > (screenY + 1.5*lengthMainBranches);
  }
  
  void draw() {
    int maxRecursionDepth = 3;
    float angleOffset = animationPhase(1/angularSpeed,angleOffsetBaseline);
    
    Vector end;
    
    for(int i = 0; i < nMainBranches; i++) {
      end = new Vector(i*(TWO_PI / nMainBranches)+angleOffset).times(lengthMainBranches).plus(center);
      drawBranch(center, end, 0, maxRecursionDepth);
    }
  }
  
  void drawBranch(Vector start, Vector end, int recursionDepth, int maxRecursionDepth) {
    
    strokeWeight(max(4-1*recursionDepth, 1));
    strokeCap(SQUARE);
    stroke(255, myColor);
    
    line(start.x, start.y, end.x, end.y);
    
    // check to see if we're too deep in the recursion
    if(recursionDepth < maxRecursionDepth) {
      for(int i = 0; i < numBranchPoints; i++) {
          drawSubbranch(start, end, branchFraction/(i+1), lengthFraction/(i+1), angle, recursionDepth, maxRecursionDepth);
          drawSubbranch(start, end, branchFraction/(i+1), lengthFraction/(i+1), -angle, recursionDepth, maxRecursionDepth);
      }
    }
  }
  
  void drawSubbranch(Vector start, Vector end, float branchFraction, float lengthFraction, float angle, int recursionDepth, int maxRecursionDepth) {
    // computes coordinates for and draws (using snowflakeDrawBranch) a subbranch which exits the main start -> end branch at branchFraction along the way
    // from start to end, having length lengthFraction times the original branch length, and jutting out at angle from the main branch's vector
    
    Vector branchStart, unitParallel, unitNormal, branchEnd;
    float branchLength, subBranchLength;
    
    branchStart = start.interpolate(end, branchFraction);
    branchLength = end.minus(start).length();
    subBranchLength = lengthFraction * branchLength;
  
    unitParallel = end.minus(start).unit();
    unitNormal = unitParallel.normal();
    
    branchEnd = branchStart.plus( unitNormal.times(subBranchLength*sin(angle)) ).plus(unitParallel.times(subBranchLength*cos(angle)));
    drawBranch(branchStart, branchEnd, recursionDepth+1, maxRecursionDepth);
  }
  
}

class Vector {
  float x;
  float y;
  
  Vector(float _x, float _y) {
    x = _x; 
    y = _y;
  }
  
  Vector(float angle) {
    x = cos(angle);
    y = sin(angle);
  }
  
  Vector clone() {
    return new Vector(x,y);
  }
  
  Vector times(float multiplier) {
    return new Vector(multiplier*x, multiplier*y);
  }
  
  Vector plus(Vector vec) {
    return new Vector(x+vec.x, y+vec.y);
  }
  
  Vector plus(float xoff, float yoff) {
    return new Vector(x+xoff, y+yoff);
  }
  
  Vector minus(Vector vec) {
    return new Vector(x-vec.x, y-vec.y);
  }
  
  Vector interpolate(Vector vec, float fraction) {
    // go fraction of the way from me to vec (e.g. 0.5 would be midpoint)
    return this.times(1-fraction).plus( vec.times(fraction) );
  }
  
  float length() {
    return sqrt(x*x + y*y);
  }
  
  Vector unit() {
    // return back a unit-length normalized version of this vector
    return this.times( 1.0/this.length() );
  }
  
  Vector normal() {
    // return a perpendicular vector to me with the same length
    return new Vector(-y, x);
  }
}
