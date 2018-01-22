left   = -1;
right  = 1;
front  = -1;
rear   = 1;
top    = 1;
bottom = -1;

inch = 25.4;

x = 0;
y = 1;
z = 2;

width  = x;
depth  = y;
height = z;

m3_diam = 3;

function accurate_diam(diam,sides) = 1 / cos(180/sides) / 2 * diam;

module hole(diam,len,sides=8) {
  rotate([0,0,180/sides]) {
    cylinder(r=accurate_diam(diam,sides),h=len,center=true,$fn=sides);
  }
}

module accurate_circle(diam,sides=8) {
  rotate([0,0,180/sides]) {
    circle(r=accurate_diam(diam,sides),center=true,$fn=sides);
  }
}

module debug_axes() {
  color("red") {
    translate([50,0,0]) cube([100,.2,.2],center=true);
    translate([0,50,0]) cube([.2,100,.2],center=true);
    translate([0,0,50]) cube([.2,.2,100],center=true);
  }
}

// Motors
nema17_side = 42.5;
nema17_diam = 55.5;
nema17_len = 36; // "half-length" nema 17
nema17_len = 48;
nema17_hole_spacing = 31;
nema17_screw_diam = m3_diam;
nema17_shaft_diam = 5;
nema17_shaft_len = 22;
nema17_short_shaft_len = 0;
nema17_shoulder_height = 2;
nema17_shoulder_diam = nema17_hole_spacing*.75;

nema14_side = 35.3;
nema14_len = 36;
nema14_hole_spacing = 26;
nema14_screw_diam = m3_diam;
nema14_shaft_diam = 5;
nema14_shaft_len = 20;
nema14_short_shaft_len = 20;
nema14_shoulder_height = 2;
nema14_shoulder_diam = 22;

motor_side = nema17_side;
motor_diam = nema17_diam;
motor_len = nema17_len;
motor_hole_spacing = nema17_hole_spacing;
motor_shaft_diam = nema17_shaft_diam;
motor_shaft_len = nema17_shaft_len;
motor_short_shaft_len = nema17_short_shaft_len;
motor_shoulder_height = nema17_shoulder_height;
motor_shoulder_diam = nema17_shoulder_diam;


module motor() {
  module body() {
    translate([0,0,-motor_len/2]) {
      cube([motor_side,motor_side,motor_len],center=true);

      // shaft
      translate([0,0,motor_len/2+motor_shaft_len/2+motor_shoulder_height])
        cylinder(r=5/2,h=motor_shaft_len,center=true,$fn=16);

      // shoulder
      translate([0,0,motor_len/2+motor_shoulder_height/2-0.05])
        cylinder(r=motor_shoulder_diam/2,h=motor_shoulder_height+0.05,center=true); // shoulder

      // short shaft
      translate([0,0,-motor_len/2-motor_short_shaft_len/2])
        cylinder(r=5/2,h=motor_short_shaft_len,center=true);
    }
  }

  module holes() {
    // mount holes
    for (side=[left,right]) {
      for(end=[top, bottom]) {
        translate([motor_hole_spacing/2*side,motor_hole_spacing/2*end,0]) {
          hole(3,motor_len*3,12);
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}
