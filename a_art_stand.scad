display = "a"; // [a: assembled, s: for printing]
depth = 3; // [2:.2:4.4]
width_at_base = 70;
width_at_top = 18; // .1
back_height = 70;
shelf_depth = 12;
leg_height = 20;
stand_angle = 20;
shelf_tilt = 2;
tolerance = 0.18;
// use "/" for line break. Blank is OK.
label = "Property of/[Your Gallery Here]";
letter_height = 3; // .1
// cut an "rt" into it so it says "Art".
make_it_say_art = 1; // [1:Yes,2:No]

/* [Hidden] */
default_label = "Property of/[Your Gallery Here]";
debug = false;
leg_across = max(10, width_at_top);
crossbar_ht = leg_height - depth*2;
y_to_x_ratio = ((width_at_base-width_at_top)/2)/(leg_height+back_height);
width_at_shelf = width_at_base - 2*leg_height*y_to_x_ratio;
ahole_ht = crossbar_ht + depth * 4;
ahole_base_x = ahole_ht * y_to_x_ratio + leg_across;
ahole_width = (width_at_base/2-ahole_base_x) * 2;
ahole_top_y = min(leg_height + back_height - leg_across, ahole_ht + ahole_width/y_to_x_ratio/2);
ahole_top_x = ahole_base_x + (ahole_top_y - ahole_ht)*y_to_x_ratio;
slot_width = width_at_shelf*.4;
standLen = standlen(leg_height-depth+depth*sin(shelf_tilt), stand_angle, shelf_tilt);
leg_angle = atan(y_to_x_ratio);

use <ttsolids.scad>
use <ttutil.scad>

bigA = [
    [0,0],
    [(width_at_base-width_at_top)/2, back_height + leg_height],
    [(width_at_base+width_at_top)/2, back_height + leg_height],
    [width_at_base, 0],
    [width_at_base-leg_across, 0],
    [width_at_base-leg_across-crossbar_ht*y_to_x_ratio,crossbar_ht],
    [leg_across+crossbar_ht*y_to_x_ratio,crossbar_ht],
    [leg_across, 0]
];
holeA = [
    [ahole_base_x, ahole_ht],
    [width_at_base-ahole_base_x, ahole_ht],
    [ahole_top_x, ahole_top_y],
    [width_at_base-ahole_top_x, ahole_top_y]
];

function standlen(f, a, z) =
    let(tA = tan(a), tZ=tan(z), h=tZ*f/(tA+tZ))
    h/sin(z);
    
module bigA(production = false) {
    difference() {
        linear_extrude(height = depth, convexity = 3)
            difference() {
                polygon(bigA);
                polygon(holeA);
        }
        translate([width_at_base/2, leg_height, depth/2])
            rotate([-shelf_tilt,0,0])
            difference() {
                cube([slot_width+tolerance, depth+tolerance, depth+1], center = true);
                translate([slot_width/4,.5-depth/2-tolerance,0])
                    cube([2,1,depth+1.01], center=true);
            }
            
        // add "property of" text.
        if (label == default_label && production) {
            #//translate([width_at_shelf/2, shelf_depth + depth + standLen/2, -3])
            rotate([0,180,0])
            linear_extrude(.5)
            text("Customize label text.", size=15,halign="center", valign="center");
        } else if (label != "") {
            lines = strsplit(label,"/");
            #rotate([0,0,90-leg_angle])
            translate([(back_height+leg_height)/2, -leg_across/2, .49])
            rotate([180,0,0])
            linear_extrude(.5)
            textlines(lines, size=letter_height, halign="center", font="", lineheight=1.4);
        }
        
        // cut out "rt"
        if (make_it_say_art == 1) {
            translate([(ahole_width+width_at_base)/2+leg_across/10, ahole_ht,-.05])
            linear_extrude(depth+.1)
            text("rt", size=leg_across/1.7, spacing=1.2);
        }
    }
}

module shelf(production = false) {
    shelf_poke = (width_at_shelf - slot_width)/2;
    ox = (depth-1)/tan(stand_angle+shelf_tilt);

    difference() {
        color("#D0D000")
        difference() {
            union() {
                difference() {
                    union() {
                        // main section of back leg
                        translate([shelf_poke, shelf_depth-2, 0])
                            cube([slot_width, standLen+2+2*depth, depth]);

                        // protrusion for snap fit
                        translate([(width_at_shelf-slot_width)/2, shelf_depth+depth+tolerance, 0])
                        rotate([-shelf_tilt,0,0])
                        linear_extrude(height=depth+1)
                        polygon([
                            [-.5,0],
                            [slot_width+.5, 0],
                            [slot_width, 4],
                            [0,4]
                        ]);
                        
                        // angled bit at end of leg to sit flat on surface
                        translate([shelf_poke, shelf_depth+standLen+depth+depth,0])
                        rotate([0,90,0])
                            linear_extrude(slot_width)
                            polygon([
                                [0,-.1],
                                [-depth,-.1],
                                [-depth,ox],
                                [1-depth, ox],
                                [0,0]
                            ]);
                    }
                    // slot on bottom so it won't fit the wrong way.
                    lenn = standLen+ox+depth+4;
                    translate([width_at_shelf/2+slot_width/4, shelf_depth-2+lenn/2, .5])
                        cube([2+tolerance,lenn,1+2*tolerance], center=true);
                    
                    translate([width_at_shelf/2+slot_width/4, shelf_depth-8+lenn, .5])
                        linear_extrude(height=1+2*tolerance, center=true)
                        polygon([[-1,0], [1,0], [3,8], [-3,8]]);
                    
                    angu = atan(slot_width/(6*standLen));
                    translate([width_at_shelf-shelf_poke, shelf_depth+depth+5, -.1])
                    rotate([0,0,angu])
                    cube([slot_width/2, standLen+4, depth+1.2]);
                    translate([shelf_poke, shelf_depth+depth+5, depth+.1])
                    rotate([0,180,-angu])
                    cube([slot_width/2, standLen+4, depth+1.2]);
                }
                // actual shelf
                skewed_cube([width_at_shelf, shelf_depth, depth], angle=[0,shelf_tilt]);

            }
            // trim where angled bit protrudes above and below stand.
            translate([0,0,depth])
                cube([width_at_shelf, shelf_depth+depth+5,depth]);
            translate([0,0,-depth])
                cube([width_at_shelf, shelf_depth+depth+5,depth]);
        }
        // L-shaped cutouts to make snap clips
        translate([shelf_poke-1.5,shelf_depth+depth-.5+tolerance+tolerance,0])
            rotate([-shelf_tilt,0,0]) {
                cube([3,.5,depth+2]);
                translate([2.3,0,0]) rotate([0,0,-6]) cube([.7,4,depth+2]);
                translate([slot_width,0,0]) cube([3,.5,depth+2]);
                translate([slot_width,0,0]) rotate([0,0,6]) cube([.7,4,depth+2]);
            }
            

//        if (label == default_label && production) {
//            #translate([width_at_shelf/2, shelf_depth + depth + standLen/2, -3])
//            rotate([180,0,90])
//            linear_extrude(.5)
//            text("Customize label text.", size=15,halign="center", valign="center");
//        } else if (label != "") {
//            lines = strsplit(label,"/");
//            # translate([width_at_shelf/2, shelf_depth + depth + standLen/2, .49])
//            rotate([180,0,90])
//            linear_extrude(.5)
//            textlines(lines, size=letter_height, halign="center", font="", lineheight=1.4);
//        }
    }
}

module main() {
    if (display == "a") { // display assembled
        if (debug) {
            color("pink", .1)
                translate ([0,0,-1])
                cube([width_at_base*1.5, standLen*1.8, 1]);
        }
        
        translate([width_at_base/4, standLen/4, 0])
        rotate([-stand_angle,0,0])
        {
            rotate([90,0,0])
                bigA();
            translate([(width_at_base-width_at_shelf)/2, 0, leg_height-depth/2])
                rotate([-shelf_tilt,0,0])
                translate([0, -shelf_depth-depth, 0])
                shelf();
        }
    } else if (display == "s") { // for printing, separated.
        translate([0,0,depth])
        rotate([0,180,0])
        {
            bigA(true);
            
            translate([-2-width_at_shelf, 0, 0])
            shelf(production=true);
        }
    } else { // for printing, overlapping
        translate([0,0,depth])
        rotate([0,180,0])
        {
            bigA(true);
            translate([-1, -1, 0])
            rotate([0,0,-leg_angle])
            translate([-(slot_width+width_at_shelf)/2,-shelf_depth-4, 0])
            shelf(production=true);
        }
    }
}

main();