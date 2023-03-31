/*#################################################################################*\
   Spool_Holder2.scad
	-----------------------------------------------------------------------------

	Developed by:			Richard A. Milewski
	Description:            Spool Holder for 20mm T-Frame
   	

	Version:                2.0
	Creation Date:          12 Mar 2023
	Modification Date:      15 Mar 2023
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

part = "set";            // [mast, spindle, set]
rail = 20;              // [20,30]

module hide_variables () {}  // variables below hidden from Customizer

$fn = 72;               //openSCAD roundness variable
eps = 0.01;             //fudge factor to display holes properly in preview mode
$slop = 0.04;          //printer dependent slop factor for part nesting

screw = [3, 6, 3.2];    //dia, head_dia, head.z
clearance = 0.5;

wall = 4;
mount = [rail * 2.5, rail + 2 * wall, rail * 0.75 + 2 * wall];
mast_scale = 0.8;
mast = [(20 + 2 * wall) * mast_scale, (20 + 2 * wall) * mast_scale, 150];
mast_seat = [mast.x + 2 * $slop, mast.y + 2 * $slop, wall/2];
roundness = 2;

spindle = [mast.x * 0.75, mast.x * 1.75, 75 + mast.x];     //[dia, end_stop_dia, length]

/*#################################################################################*\
    
    Main

\*#################################################################################*/

if (part == "mast" || part == "set") {
        up(mount.x/2) yrot(90) mount();
        up(mast.x/2)  right(roundness) yrot(-90) mast();
}

if (part == "spindle" || part == "set") {
    move([-mast.z/2, spindle.y, 0]) spindle();
}

/*#################################################################################*\
    
    Modules

\*#################################################################################*/

module mount() {
    diff() {
        cuboid(mount, rounding = roundness, anchor = BOT)
            tag("remove") attach(TOP) up(eps/2) cuboid([mount.x + eps, rail + $slop, mount.z - 2 * wall], anchor = TOP);
        tag("remove")  left( mast.x/2) {
            #cyl(d = screw.x + clearance, h = wall * 2 + eps, anchor = BOT);
            down(eps/2) #cyl(d = screw.y, h = wall + 1, anchor = BOT);    
        }
    }
}

module mast() {
    diff() {
        cuboid(mast, rounding = roundness, except = BOT, anchor = BOT)
            attach(TOP) xcyl(d = mast.x, h = mast.x, rounding = roundness)
            tag("remove"){
                right(wall + eps) xcyl(d = spindle.x + 2 * $slop, circum = true, h = mast.x);
            }  
    }
}   

module spindle() { 
    cyl(d = spindle.y, h = 4, rounding = roundness, anchor = BOT);
    diff() {
        up(4) cyl(d = spindle.x, h = spindle.z, rounding1 = -9, rounding2 = 2, anchor = BOT)
            attach(TOP) tag("remove") cyl(d = screw.x, l = 20);
    } 
}

module echo2(arg) {						// for debugging - puts space around the echo.
	echo(str("\n\n", arg, "\n\n" ));
}