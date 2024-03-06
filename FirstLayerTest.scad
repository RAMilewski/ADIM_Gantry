/*#################################################################################*\
   FirstLayerTest.scad
	-----------------------------------------------------------------------------

	Developed by:			Richard A. Milewski
	Description:            First Layer Test for ADIM_Gantry
   	

	Version:                1.0
	Creation Date:          22 April 2023
	Modification Date:      
	Email:                  richard+scad@milewski.org
	Copyright 				©2022 by Richard A. Milewski
    License - CC-BY-NC      https://creativecommons.org/licenses/by-nc/3.0/ 

\*#################################################################################*/


/*#################################################################################*\
    
    Notes

\*#################################################################################*/


/*#################################################################################*\
    
    CONFIGURATION

\*#################################################################################*/
include <BOSL2/std.scad>

module hide_variables () {}  // variables below hidden from Customizer

size = [200, 20];

layer = 0.2;

/*#################################################################################*\
    
    Main

\*#################################################################################*/
	
    rot_copies(n = 5)
    cuboid([size.x, size.y, layer], anchor = BOT);
   

/*#################################################################################*\
    
    Modules

\*#################################################################################*/

module echo2(arg) {
	echo(str("\n\n", arg, "\n\n" ));
}