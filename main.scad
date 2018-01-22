include <util.scad>;

resolution = 64;

endmill_diam = (1/8)*inch;

m5_tap_diam  = 4.2;

column_height   = 500;
plate_thickness = (1/4)*inch;
countersink_depth = 3;

motor_width       = 42.3;

belt_opening_width = 18;
belt_opening_depth = 14;

belt_width = 8;

column_radius   = 150;

build_diam      = 170;
build_height    = 240;

// assuming 40mm x 40mm extrusions
column_width    = 40;
column_depth    = 40;
column_hole_spacing = 20;
column_screw_diam    = 5;
column_screw_head_diam = 9;

// guessing, based on http://www.makerstore.com.au/wp-content/uploads/2014/07/Solid-V-Wheel-5.jpg
carriage_wheel_diam = 9.77*2;
carriage_wheel_screw_diam = 5;
carriage_wheel_spacing = column_width + carriage_wheel_diam;
carriage_width = carriage_wheel_spacing + carriage_wheel_diam;

plate_rounded   = (1/2)*inch;

belt_column_dist = 5+belt_width/2;

module carriage_plate() {
  difference() {
    rounded_square(carriage_width,carriage_width,carriage_wheel_diam);
  }
}

module rounded_square(width,depth,diam=endmill_diam) {
  module body() {
    hull() {
      for(x=[left,right]) {
        for(y=[front,rear]) {
          translate([x*(width/2-diam/2),y*(depth/2-diam/2),0]) {
            accurate_circle(diam,resolution);
          }
        }
      }
    }
  }

  module holes() {
    for(x=[left,right]) {
      for(y=[left,0,right]) {
        translate([carriage_wheel_spacing/2*x,carriage_wheel_spacing/2*y,0]) {
          accurate_circle(carriage_wheel_screw_diam);
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module position_columns() {
  for (r=[0,120,240]) {
    rotate([0,0,r]) {
      translate([0,column_radius,0]) {
        children();
      }
    }
  }
}

module column() {
  linear_extrude(height=column_height,center=true,convexity=3) {
    difference() {
      square([column_width,column_depth],center=true);

      // simplified v-groove slots, based on http://ooznest.co.uk/image/data/vslot/designs/DESIGN-V-SLOT-2020.jpg
      for(r=[0:3]) {
        rotate([0,0,90*r]) {
          translate([0,0,0]) {
            for(side=[left,right]) {
              translate([column_hole_spacing/2*side,column_depth/2,0]) {
                square([5.68,2+10],center=true);

                hull() {
                  translate([0,1,0]) {
                    square([5.68+(1.8*2),2],center=true);
                  }
                  translate([0,0,0]) {
                    square([5.68,1.8*2],center=true);
                  }
                }
              }
            }
          }
        }
      }

      // center void
      accurate_circle(column_hole_spacing,resolution);

      // mounting holes
      for(x=[left,right]) {
        for(y=[front,rear]) {
          translate([column_hole_spacing/2*x,column_hole_spacing/2*y,0]) {
            accurate_circle(m5_tap_diam,resolution);
          }
        }
      }
    }
  }
}

module plate() {
  module body() {
    hull() {
      position_columns() {
        for(side=[left,right]) {
          translate([side*column_width/2,column_depth/2,0]) {
            accurate_circle(plate_rounded,resolution);
          }
        }
      }
    }
  }

  module holes() {
    position_columns() {
      for(x=[left,right]) {
        for(y=[front,rear]) {
          translate([column_hole_spacing/2*x,column_hole_spacing/2*y,0]) {
            accurate_circle(column_screw_diam,resolution);
          }
        }
      }
    }

    // hole to feed heated bed cabling through
    translate([0,column_radius,0]) {
      rotate([0,0,45]) {
        rounded_square(12,12);
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module plate_countersinks() {
  position_columns() {
    for(x=[left,right]) {
      for(y=[front,rear]) {
        translate([column_hole_spacing/2*x,column_hole_spacing/2*y,0]) {
          accurate_circle(column_screw_head_diam,resolution);
        }
      }
    }
  }
}

module top_plate() {
  motor_mount_hole_spacing = motor_width + 10*2;

  difference() {
    plate();

    position_columns() {
      translate([0,-column_depth/2-belt_column_dist,0]) {
        rounded_square(belt_opening_width,belt_opening_depth);

        // motor mounting holes
        translate([0,0,0]) {
          for(x=[left,right]) {
            for(y=[-5,-25]) {
              translate([motor_mount_hole_spacing/2*x,y-belt_opening_depth/2,0]) {
                accurate_circle(m5_tap_diam);
              }
            }
          }
        }
      }
    }
  }
}

module bottom_plate() {
  difference() {
    plate();


    // heated build plates:
    // * https://reprapchampion.com/collections/kossel-parts/products/3d-printer-110v-120w-silicone-heater-w-ntc-thermistor-for-kossel-delta-hot-bed

    // orion heated build plate holes : https://www.seemecnc.com/collections/parts-accessories/products/orion-heated-bed
    for(r=[0:5]) {
      rotate([0,0,30+60*r]) {
        translate([0,210/2,0]) {
          accurate_circle(m5_tap_diam,resolution/2);
        }
      }
    }

    // hole to feed heated bed cables through
    translate([0,column_radius-column_depth/2-5-12/2,0]) {
      rotate([0,0,45]) {
        rounded_square(12,12);
      }
    }

    // foot holes
    position_columns() {
      for(side=[left,right]) {
        translate([side*(column_width/2+10),-column_depth/2+10,0]) {
          accurate_circle(m5_tap_diam,resolution/2);
        }
      }
    }
  }
}

module assembly() {
  translate([0,0,(column_height/2+plate_thickness/2)*top]) {
    difference() {
      linear_extrude(height=plate_thickness,center=true,convexity=3) {
        top_plate();
      }
      translate([0,0,plate_thickness/2]) {
        linear_extrude(height=countersink_depth*2,center=true,convexity=3) {
          plate_countersinks();
        }
      }
    }
  }
  translate([0,0,(column_height/2+plate_thickness/2)*bottom]) {
    translate([0,0,plate_thickness/2+build_height/2+1]) {
      % hole(build_diam,build_height,resolution);
    }
    difference() {
      linear_extrude(height=plate_thickness,center=true,convexity=3) {
        bottom_plate();
      }
      translate([0,0,-plate_thickness/2]) {
        linear_extrude(height=countersink_depth*2,center=true,convexity=3) {
          plate_countersinks();
        }
      }
    }
  }

  position_columns() {
    translate([0,-column_depth/2-1-plate_thickness/2,0]) {
      rotate([90,0,0]) {
        linear_extrude(height=plate_thickness,center=true,convexity=3) {
          carriage_plate();
        }
      }
    }

    color("silver") {
      column();
    }

    translate([0,-column_depth/2-belt_opening_depth-10,column_height/2+plate_thickness/2+motor_side/2]) {
      rotate([-90,0,0]) {
        % motor();
      }
    }
  }
}


/*

shopping list?
* pretty sure
  * wheels:            http://openbuildspartstore.com/delrin-mini-v-wheel/
  * eccentric spacers: http://openbuildspartstore.com/eccentric-spacer/
  * normal spacers:    http://openbuildspartstore.com/aluminum-spacers/
  * 40x40 openbuild:   http://openbuildspartstore.com/v-slot-40x40-linear-rail/
  * aluminum plate:    https://www.discountsteel.com/items/6061_Aluminum_Plate.cfm?item_id=137&size_no=3&pieceLength=cut&wid_ft=1&wid_in=0&wid_fraction=0&len_ft=2&len_in=0&len_fraction=0&pieceCutType=30%7C1&itemComments=&qty=1#skus
* not so sure
  * heated build plate
    * https://reprapchampion.com/collections/kossel-parts/products/3d-printer-110v-120w-silicone-heater-w-ntc-thermistor-for-kossel-delta-hot-bed
      * and a MIC6 aluminum plate?
        * https://www.discountsteel.com/items/C250_Aluminum_Cast_Tooling_Plate.cfm?item_id=152&size_no=2#skus
    * https://www.seemecnc.com/collections/parts-accessories/products/orion-heated-bed
  * arms
    * use seemecnc orion arms? -- https://www.seemecnc.com/products/orion-delta-ball-cup-delta-arm-kit

* washers
* bearings





*/
