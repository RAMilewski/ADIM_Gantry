/*#################################################################################*\
   E3Dv6_Mount.scad
	-----------------------------------------------------------------------------

	Developed by:			Richard A. Milewski
	Description:            E3Dv6 mount for Spark Studio Big Dog printer.
   	
	Version:                1.0
	Creation Date:          12 Feb 2023
	Modification Date:       7 Mar 2023
	Email:                  richard+scad@milewski.org
	Copyright 				©2023 by Richard A. Milewski
    License - CC-BY-NC      https://creativecommons.org/licenses/by-nc/3.0/ 

\*#################################################################################*/


/*#################################################################################*\
    
    Notes

	Requires the BOSL2 library for OpenSCAD  https://github.com/revarbat/BOSL2/wiki

	After some research Big Dog turned out to be an ADIMlab Gantry or Gantry Pro
	printer.  Current Gantry Pro models have a very different hot end design from 
	the one at Spark Studio.  Best guess is that this is a Gantry.

\*#################################################################################*/


/*#################################################################################*\
    
    CONFIGURATION

\*#################################################################################*/
include <BOSL2/std.scad>	// https://github.com/revarbat/BOSL2/wiki

part = "plate";				//[front, back, both, plate, duct, assembly, duct_mount]

show_ghosts = false;		//Include phantom fans for spacing

module hide_variables () {}	// variables below hidden from Customizer

$fn = 72;				//openSCAD roundness variable
eps = 0.01;         	//fudge factor to display holes properly in preview mode

back = false;
front = true;

hex_nut = 6.5;			// for m3 hex (Allen) cap screws
hex_head = 6.5;
hex_hole = 3.5;

pan_head  = 0;			// for m3 pan-head self tapping screws
pan_hole  =  2.75;		// hole to tap
pan_hole2 =  3.5;		// clearance hole

access_hole = 4;

fan_case = [30, 30, 10];
duct_fan_mount = fan_case + [2, 2, 0];
fan = [28.5, 24];		//[dia, hole_spacing]
fan_pos = 16;
fan_hole = pan_hole;		// hole for mounting screw
fan_slop = 2.5;				// mounting hole elongation
fan_corner = 2;				// fan case rounding

v6_neck    = [16.5, undef, 17];		//[dia, undef, z]	
v6_collar  = [12.5, undef, 5.75];  	//[dia, undef, z]
v6_fins    = [22.3, undef, 26]; 	//[dia, undef, z]
v6_block   = [32, 32, v6_neck.z + v6_fins.z - 3];  
v6_corner  = 1.5; 
v6_collar_rounding = 1;
v6_collar_pos = v6_block.z - 4.2;
v6_clamp_span = (v6_block.x + v6_neck.x)/2.4;

mount_plate = [55, 52, 3];
plate_hole = [34, 32];
plate_hole_offset = 2.5;
plate_hole_rounding = [15, 5, 5, 15];
mount_hole = [2, 40, 2.8]; 			//[offset, spacing, dia];
plate_rounding = 5;
plate_pad_lift = 1;					// support under heatbreak fan.   
plate_v6_anchor = [3, 7 , mount_plate.z + 7];

ext_mount = [42, 10, 12.44]; 
ext_mount_hole =  pan_hole + 1;
ext_mount_span = 31;
ext_mount_pos = [(ext_mount.x - v6_block.x)/2, 10 - ext_mount.y/2, v6_block.z + ext_mount.z/2];

ext_size1 = [v6_block.x, 8];
ext_size2 = [v6_block.x, v6_block.y];
ext_support_base = [ext_size1.x, ext_size1.y, v6_block.z + mount_plate.z];
ext_support_yoffset = mount_hole.y/2 + 0.8;
 

duct_block = [duct_fan_mount.x, duct_fan_mount.y, 14];
duct_floor = 1.5;
duct_shift = [0,10];
duct_length = 16;

/*#################################################################################*\
    
    Main

\*#################################################################################*/
	
if (part == "back")  	  { mount_half(back); }
if (part == "front") 	  { mount_half(front); }
if (part == "both")  	  { right(v6_block.x/2 + 5) mount_half(front);
					   	    left(v6_block.x/2 + 5) mount_half(back); }
if (part == "plate") 	  { plate(); }
if (part == "duct_mount") { duct_mount(); }
if (part == "duct")  	  { rot([0,-0,0]) duct(); }
if (part == "assembly")	  { assembly();}

/*#################################################################################*\
    
    Modules

\*#################################################################################*/


module assembly() {
	plate();
    up(mount_plate.z) {
		mount_half(back);
		zrot(180) mount_half(front);
	}
	down(duct_block.z) fwd((mount_plate.x + duct_block.x)/2 - 1) zrot(0) duct();

}


module mount_half(is_front) {
	difference() {
		back_half() mount();
		up(v6_collar_pos - v6_collar.z/2)  
			union() {
				xcopies(v6_clamp_span) fwd(eps/2) ycyl(d = hex_hole, h = v6_block.y/2 + eps, circum = true, anchor = FWD);
				back(4) xcopies(v6_clamp_span) 
					if (is_front) {
						fwd(eps/2) ycyl(d = hex_head, h = v6_block.y/2 + eps, circum = true, anchor = FWD);
					} else {
						ycyl(d = hex_nut, h = v6_block.y/2 + eps, $fn = 6, anchor = FWD);  
					}
			}
	}
	if (is_front) {		//then we add the extruder mount
		difference() {
			union() {
				difference() {
					move(ext_mount_pos) extruder_mount();
					move([-v6_block.x/2 + ext_mount.x, ext_mount.y/2, v6_block.z]) rot([0,-90,90]) rounding_edge_mask(l= ext_mount.y, r = 2);
				}
				up(v6_block.z) zcyl(h = ext_mount.z + eps, d = 15, rounding2 = 2, anchor = BOT);
			}
			down(eps/2) #zcyl(h = 70, d = 4, circum = true, anchor = BOT);   // hole for PTFE tube
		}
		move([v6_block.x/2, ext_mount.y/2, v6_block.z]) rot([0,90,-90]) interior_fillet(l = ext_mount.y, r = 8);
		difference() {
			move([-v6_block.x/2 + 0.5, ext_mount.y/2, v6_block.z]) cuboid([1, ext_mount.y , ext_mount.z]);
			union() {
				move([-v6_block.x/2, ext_mount.y, v6_block.z + ext_mount.z/2 - 2]) zrot(-90) rounding_edge_mask(l= ext_mount.z, r = 2);
				move([-v6_block.x/2, 0, v6_block.z + ext_mount.z/2]) rounding_edge_mask(l= ext_mount.z, r = 2);
			}
		}
	}	
}



module mount() {
	difference() { 
		cuboid(v6_block, rounding = v6_corner,  anchor = BOT);
		union() {
			cyl(h = v6_fins.z, d = v6_fins.x, anchor = BOT);
			up(v6_fins.z) cyl(h = v6_neck.z, d = v6_neck.x,  anchor = BOT);
			up(fan_pos) {
				xcyl(h = v6_block.x + eps, d = fan.x);
				yrot(90) grid_copies(spacing = [fan.y, fan.y])  cyl(d = pan_hole, l = v6_block.x + eps, circum = true);
			}
		}
	}
	up(v6_collar_pos) difference(){
		tube(od = v6_neck.x + 1, id = v6_collar.x, h = v6_collar.z, anchor = UP);
		union() {
			rounding_hole_mask(d = v6_collar.x, rounding = v6_collar_rounding);
			down(v6_collar.z) xrot(180)rounding_hole_mask(d = v6_collar.x, rounding = v6_collar_rounding);
		}
	}

}

module extruder_mount() {
	difference() {
		cuboid(ext_mount, rounding = 2, except = BOT);
		xcopies(ext_mount_span) adj_yhole(ext_mount.y, ext_mount_hole, ext_mount_hole);
	}

}

module adj_yhole(len, dia, span) {		//adjustment mounting hole aligned with y axis
	hull() {
		left(span/2)  ycyl(l = len + eps, d = dia, circum = true);
		right(span/2) ycyl(l = len + eps, d = dia, circum = true);
	}
}


module plate() {
	tag_scope("plate")
	diff() {
		cuboid(mount_plate, rounding = plate_rounding, edges = "Z", anchor = BOT) {
			extruder_support();
			position(FWD+BOT) duct_mount();
			left(mount_hole.x) up(mount_plate.z/2) ycopies(mount_hole.y) 
				zcyl(h = mount_plate.z + 3, d = mount_hole.z + 2, rounding1 = -1, rounding2 = 2, anchor = BOT);
			position(RIGHT+BOT) {
				zrot(180) v6_block_anchor();
				left(v6_block.x + fan_case.z + plate_v6_anchor.x) v6_block_anchor();  	// tabs for mounting the v6-block
			}
			

			tag("remove") {
				position(BOT) down(eps/2) right(plate_hole_offset) 
					prismoid(size1 = plate_hole, size2 = plate_hole, h = mount_plate.z + eps, rounding = plate_hole_rounding, anchor = BOT);
					
				position(BOT) left(mount_hole.x) ycopies(mount_hole.y) zcyl(h = mount_plate.z + 5, d = mount_hole.z, anchor = BOT); 
				
			}
		}
	}
	if (show_ghosts) {
		color("skyblue",0.99) cuboid([v6_block.x, v6_block.y,mount_plate.z+7], anchor = BOT);			// dummy v6 block for spacing
		color("red",0.3) up(mount_plate.z + fan_pos)
			right(v6_block.x/2) yrot(90) cuboid(fan_case, anchor = BOT);				// dummy fan for spacing
	} 
	
}

module v6_block_anchor() {
	ycopies(fan.y) {
		difference() {
			cuboid(plate_v6_anchor, rounding = 2, edges = [TOP + FWD + BACK, "Z"], except = RIGHT, anchor = BOT);
			up(mount_plate.z + 4) xcyl(h = mount_plate.z * 2, d = pan_hole2);
		}
	}
}

module duct_mount() {
	tag_scope("duct_mount")
		diff() {
			cuboid([duct_fan_mount.x, duct_fan_mount.y, mount_plate.z], rounding = fan_corner, edges = [FWD+LEFT, FWD+RIGHT], anchor = BOT+BACK) {
				position(BACK+LEFT+BOT) fillet(l = mount_plate.z, r = 7, ang = 90, spin = 180, anchor = BOT);
				position(BACK+RIGHT+BOT) fillet(l = mount_plate.z, r = 7, ang = 90, spin = -90, anchor = BOT);
				if(show_ghosts) { color("red",0.5)  cuboid(fan_case, anchor = BOT); }
			
			force_tag("remove") position(BOT) down(eps/2) {
				zcyl(h = mount_plate.z + eps, d = fan.x, anchor = BOT);
				grid_copies(spacing = [fan.y, fan.y])  cyl(d = pan_hole2, h = mount_plate.z + eps, circum = true, anchor = BOT);
			}		
		}
	}
}


module extruder_support() {
	fwd(ext_support_yoffset)  {
		cuboid(ext_support_base, rounding = v6_corner, edges = [TOP, "Z"], anchor = BOT);
		up(fan_case.z + mount_plate.z) 
		difference() {
			prismoid(size1 = ext_size1, size2 = ext_size2, h = v6_block.z - fan_case.z, 
				shift = [0, -ext_size2.y/2], rounding = v6_corner, anchor = BOT);
			union() {
				move([v6_block.x/2, -ext_size2.y/2, v6_block.z - fan_case.z]) {
					rot([0, 90, 90]) rounding_edge_mask(l = ext_size2.y, r = v6_corner);
					left(ext_size2.x) xrot(-90) rounding_edge_mask(l = ext_size2.y, r = v6_corner);
					move([-ext_size2.x/2, -ext_size2.x/2, 0]) rot([90, 0, 90]) rounding_angled_edge_mask(ang = 45, h = ext_size2.x, r = v6_corner);
				}
				move([0, ext_support_yoffset - (mount_plate.y + duct_fan_mount.y)/2, mount_plate.z + eps])	
					grid_copies(spacing = fan.y) cyl(d = access_hole, h = v6_block.z, circum = true, anchor = BOT);	
			}
		}
	}
}


module duct() {
	tag_scope("duct")
	diff() {
		cuboid(duct_block, rounding = fan_corner, except = TOP, anchor = BOT) {
			tag("remove") {
				position(BOT) up(duct_floor) { 
					cyl(d = fan.x, h = duct_block.z,  anchor = BOT);
					grid_copies(spacing = fan.y) cyl(d = fan_hole, h = duct_block.z, circum = true, anchor = BOT);
				}
				position(BACK) back(1) cuboid([fan.y - fan_hole - 1, 8, duct_block.z - duct_floor - 1], anchor = BACK+CENTER);
			}		
			tag("keep") {
				position(BACK) fwd(1) xrot(-90)
				rect_tube(size1 = [fan.y - fan_hole, duct_block.z], isize1 = [fan.y - fan_hole - 1, duct_block.z - duct_floor],
					size2 = [duct_block.y/2, 4], isize2 = [duct_block.y/2 - 0.5, 3.5], shift = duct_shift,
					l = duct_length, rounding = fan_corner, anchor = BOT);
			}
		}
	}
}

module echo2(arg) {
	echo(str("\n\n", arg, "\n\n" ));
}