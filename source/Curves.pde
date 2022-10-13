
import java.util.*;
// Java code to show implementation of 
// binomial(int n, int k) method of Guava's 
// IntMath class 
import java.math.RoundingMode; 
import com.google.common.math.IntMath;
import java.lang.Math;

//Map<PVector, Point> points;

List<PVector> points;
List<PVector> hull;
List<PVector> arrangedHull;
List<PVector> perturb;
Boolean pointUpdated;
Boolean pointsLocked;
Boolean setBezier;
Boolean showPoints;
//Boolean nextPoint;
//int loc;

void setup() {
  // Program made to run in fullscreen
  // initialise variables
  fullScreen() ;
  //frameRate(40) ;
  textSize(15) ;
  points = new ArrayList<PVector>();
  hull = new ArrayList<PVector>();
  arrangedHull = new ArrayList<PVector>();
  pointUpdated = false;
  pointsLocked = false;
  setBezier = false;
  showPoints = false;
  //nextPoint = false;
  //loc = 1;
  
  //points = new HashMap<PVector, Point>();
  
}

void draw() {
  background(220);

  // Draw points
  int index = 0;
  for (PVector point: points) {
    fill(255);
    circle(point.x, point.y, 10);
    fill(0);
    if (showPoints) {
      text("P" + index + "(" + point.x + "," + point.y + ")", point.x, point.y);
    }
    index++;
  }
  // Create the convex hull when a point is updated
  if (pointUpdated) {
    hull = convexHull(points);
    pointUpdated = false;
  }
  
  
  int p = 0;
  if (hull.size() != 0) {
    // Lines drawn to connect the points of the convex hull
    for (int i = 1; i < hull.size(); i++) {
      fill(255);
      line(hull.get(p).x, hull.get(p).y, hull.get(i).x, hull.get(i).y);
      p = i;
    }
    // Last line to connect the last point of the convex hull to the first point
    line(hull.get(p).x, hull.get(p).y, hull.get(0).x, hull.get(0).y);
    
    //// Arranges the points in the hull according to when they were added
    //arrangedHull = new ArrayList<PVector>();
    //for (PVector point: points) {
    //  if (hull.contains(point)) {
    //    arrangedHull.add(point);
    //  }
    //}
    
    // 36 points make the Bezier curve go out of control
    // Constructs Bezier curve based using the hull points in order
    // Incrementing t by 0.0001 so more points are plotted to simulate a smoother curve
    if (points.size() != 0) {
      for (float t = 0; t <= 1; t+=0.0001) {
        // curve order = number of points - 1
        PVector test = Bezier(points.size()-1, t, points);
        point(test.x, test.y);
      }
    }
    
    // Perturbation attempt 
    //perturb = arrangedHull;
    //if (pointsLocked) {
    //  PVector prev = PVector(perturb.get(loc-1).x - perturb.get(loc).x, perturb.get(loc-1).y - perturb.get(loc).y) ;
    //  PVector next = PVector(perturb.get(loc+1).x - perturb.get(loc).x, perturb.get(loc+1).y - perturb.get(loc).y) ;
    //  float rad = PVector.angleBetween(prev, next);
    //  float x = cos(rad) * 1000;
    //  float y = sin(rad) * 1000;
    //  line(0,0,x,y);
    //  if (nextPoint) {
    //    if (loc + 1 < perturb.size()-1)
    //    loc++;
    //    else loc = 1;
    //  }
    //  perturb.get(loc);
      //if (incSmall) {
      //  perturb.get(loc);
      //  PVector prev = perturb.get(loc-1);
      //  PVector next = perturb.get(loc+1);
      //  prev.normalize();
      //  next.normalize();
      //  PVector test;
      //  test.add(prev);
        
      //}
    //}
    //if (!pointsLocked) {
    //loc = 1;
    //}
  }
  
}

void mousePressed() {
  if (!pointsLocked) {
    // Creates a point when left clicked at the mouse position
    if (mouseButton == LEFT) {
      points.add(new PVector(mouseX, mouseY));
      pointUpdated = true;
      //print(points);
      //println();
    }
    // Removes the most recent point added when right clicked
    if (mouseButton == RIGHT) {
      if (points.size() == 0) {
        pointUpdated = false;
      } else {
        int index = points.size() - 1;
        points.remove(index);
        pointUpdated = true;
        //print(points);
        //println();
      }
    }
  }
}

void keyPressed(){
  // The key 'l' locks the addition and removal of points
  if (key == 'l') {
   pointsLocked = true; 
  }
  // The key 'u' unlocks the addition and removal of points
  if (key == 'u') {
   pointsLocked = false; 
  }
  if (key == 's') {
   if (showPoints) {
     showPoints = false;
   } else showPoints = true;
  }
  //if (key == CODED) {
  //  switch (keyCode) {
  //    case RIGHT :
  //    nextPoint = true;
  //    break;
  //  }
  //}
}

//void keyReleased() {
//  if (key == CODED) {
//   switch (keyCode) {
//    case RIGHT :
//    nextPoint = false;
//    break;
//   }
//  }
//}


// To find orientation of ordered triplet (p, q, r). 
public static int orientation(PVector p, PVector q, PVector r) { 
  float val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y); 
  if (val == 0) return 0;  // p, q and r are collinear 
  // val > 0 returns 1 which is clockwise and val < 0 returns 2 which is counterclockwise
  return (val > 0)? 1: 2; 
  
} 

public static List convexHull(List<PVector> points) {
  int length = points.size();
  
  // returns emptyList if there are less than 3 points
  List<PVector> emptyList = new ArrayList<PVector>();
  // must have at least 3 points to form a convex hull
  if (length < 3) return emptyList;
  
  // Results storage
  List<PVector> hull = new ArrayList<PVector>();
  
  // Finding leftmost point
  int j = 0;
  for (int i = 1; i < length; i++) {
    if (points.get(i).x < points.get(j).x) {
      j = i; 
    }
  }
  
  // From the left most point, move counterclockwise until back to the start point 
  // This loop runs O(nh) times where n is the total number of points and
  // h is number of points in result or output. 
  int k = j, l;
  do {
    // Add current point to result 
    hull.add(points.get(k));
      
    // l will be the last visited point
    // % length to ensure it does not go out of bounds
    l = (k + 1) % length; 
    
    // ensure 'l' is counterclockwise for all i with respect to k
    for (int i = 0; i < length; i++) {
      // If i is more counterclockwise than current l, update l 
      if (orientation(points.get(k), points.get(i), points.get(l)) == 2) {
        l = i;
      }
    }
    // Now l is the most counterclockwise with 
    // respect to k. Set k as l for next iteration,  
    // so that l is added to result 'hull' 
    k = l;
  } while (k != j); // While we don't come back to first point
  
  //// Print Result for testing
  //for (PVector temp : hull) { 
  //  System.out.println("(" + temp.x + ", " + temp.y + ")"); 
  //}
  return hull;
}

public static PVector Bezier(int n, float t, List<PVector> points) {
  float sumX = 0;
  float sumY = 0;
  for (int k = 0; k <= n; k++) {
    sumX += IntMath.binomial(n, k) * Math.pow((1-t), (n-k)) * Math.pow(t, k) * points.get(k).x;
    sumY += IntMath.binomial(n, k) * Math.pow((1-t), (n-k)) * Math.pow(t, k) * points.get(k).y;
  }
  PVector bezPoint = new PVector(sumX, sumY);
  return bezPoint;
}
