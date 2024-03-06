include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
$fn=144;
rounded_prism(octagon(10), octagon(15), height=5,
              joint_top=[1,-3], joint_bot=[-1,2], joint_sides=1, k = 0.92, anchor = BOT, debug=false);
   

