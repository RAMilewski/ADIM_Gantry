/*#################################################################################*\
   Spool_Holder.scad
	-----------------------------------------------------------------------------

	Developed by:			Richard A. Milewski
	Description:            Spool Holder for 20mm T-Frame
   	

	Version:                1.0
	Creation Date:          12 Mar 2023
	Modification Date:      
	Email:                  richard+scad@milewski.org
	Copyright 				©2023 by Richard A. Milewski
    License - CC-BY-NC      https://creativecommons.org/licenses/by-nc/3.0/ 

\*#################################################################################*/


/*#################################################################################*\
    
    Notes

	Requires the BOSL2 library for OpenSCAD  https://github.com/revarbat/BOSL2/wiki

\*#################################################################################*/


/*#################################################################################*\
    
    CONFIGURATION

\*#################################################################################*/
include <BOSL2/std.scad>	// https://github.com/revarbat/BOSL2/wiki

part = "mast";          // [mount, mast, spindle]

rail = 20;              // [20,30]

module hide_variables () {}  // variables below hidden from Customizer

$fn = 72;               //openSCAD roundness variable
eps = 0.01;             //fudge factor to display holes properly in preview mode
$slop = 0.025;          //printer dependent slop factor for part nesting

screw = [3, 6, 3.2];    //dia, head_dia, head.z
clearance = 0.5;

wall = 4;
mount = [rail * 2.5, rail + 2 * wall, rail + 2 * wall];
mast_scale = 0.8;
mast = [(20 + 2 * wall) * mast_scale, (20 + 2 * wall) * mast_scale, 150];
mast_seat = [mast.x + 2 * $slop, mast.y + 2 * $slop, wall/2];
roundness = 2;

spindle = [mast.x * 0.7, mast.x * 1.75, 70];     //[dia, end_stop_dia, length]

echo2([mast_seat]);
/*#################################################################################*\
    
    Main

\*#################################################################################*/

if (part == "mount")    mount();
if (part == "mast")     mast();
if (part == "spindle")  spindle();



/*#################################################################################*\
    
    Modules

\*#################################################################################*/

module mount() {
    tag_scope()
    diff() {
        cuboid(mount, rounding = roundness, anchor = BOT)
            attach(TOP) tag("remove") recolor("white") up(eps/2) cuboid([mount.x + eps, rail + $slop, mount.z - 2 * wall], anchor = TOP)
            xcopies(l = mount.x/2.5) attach(BOT) tag("remove") cyl(d = screw.x + clearance, h = wall * 2 + eps, anchor = BOT);
            xcopies(l = mount.x/2.5) down(eps/2) tag("remove") up($idx * wall) cyl(d = screw.y, h = wall + 1, anchor = BOT);
            tag("remove") move([mount.x/5, 0,-eps/2]) cuboid(mast_seat, rounding = roundness, edges = "Z", anchor = BOT);  //mast seat
    }
}

module mast() {
    diff() {
        cuboid([mast.x, mast.y, 2 * wall], rounding = roundness, edges = "Z", anchor = BOT);
        tag("remove") cyl(d = screw.x, h = 2 * wall, anchor = BOT);
        tag("base") rect_tube(size = [mast.x, mast.y], h = mast.z, wall = wall/2, rounding = roundness, irounding = roundness, anchor = BOT)
            { attach(TOP) tag("base") color("skyblue") cuboid([mast.x, mast.y, 5], rounding = roundness, edges = [TOP, "Z"] )
              down(10) tag("remove"){
                    right(wall + eps) xcyl(d = spindle.x + 2 * $slop, circum = true, h = mast.x);
                    xcyl(d = screw.x + clearance, h = mast.x + eps);
              }  
            }
    }
        
}

module spindle() { 
    cyl(d = spindle.y, h = 4, rounding = roundness, anchor = BOT);
    diff() {
        up(4) cyl(d = spindle.x, h = spindle.z, rounding1 = -9, anchor = BOT)
            attach(TOP) tag("remove") cyl(d = screw.x, l = 20);
    } 


}


module echo2(arg) {						// for debugging - puts space around the echo.
	echo(str("\n\n", arg, "\n\n" ));
}