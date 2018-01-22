include <main.scad>;

translate([-column_radius*.75,-column_radius*.225,0]) {
  color("red") {
    top_plate();
  }
}
translate([column_radius*.75,column_radius*.225,0]) {
  rotate([0,0,180]) {
    color("red") {
      bottom_plate();
    }
  }
}

module debug_cut_plate() {
  width = column_radius*4;
  depth = column_radius*2;

  echo("WIDTH/DEPTH: ", width/inch, depth/inch);

  translate([0,0,-1]) {
    % square([width,depth],center=true);
  }
}

debug_cut_plate();
