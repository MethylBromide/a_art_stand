/*
Parameterized A-shaped art stand script - v3.0

By Tyler Tork
Instagram: @tylertorkfictioneer
Email: tyler@tylertork.com
Website: tylertork.com

Copyright 2024 Tyler Tork

Attribution-NonCommercial-ShareAlike 4.0 International
 https://creativecommons.org/licenses/by-nc-sa/4.0/
*/

// set to "for printing" to flatten model for export.
display = "a"; // [a: assembled, s: for printing]
// thickness of the two flat pieces.
depth = 3; // [2:.2:4.4]
width_at_base = 70;
width_at_top = 18; // .1
// back height + leg height = total height of standing part.
back_height = 70;
leg_height = 20;
maximum_leg_width = 25; // [4:.5:30]
// how far the shelf sticks out
shelf_depth = 12;
// how far the stand tilts back
stand_angle = 20; // [10:1:30]
// slight additional tilt of shelf.
shelf_tilt = 2; // [0:.25:5]
// adjustment for printer precision
tolerance = 0.18;
// use "/" for line break. Blank is OK.
label = "Property of/[Your Gallery Here]";
letter_height = 3; // .1
// cut an "rt" into it so it says "Art".
make_it_say_art = true;
// hollow out the insides to make it lighter and print faster.
Hollow = true;

/* [Hidden] */
WAB = max(width_at_base, 30);
WAT = max(width_at_top, 0);
htBack = max(20, back_height);
htLegOrig = max(4, leg_height);
htText = max(2.5, min(letter_height, 10));
dpShelf = max(4, shelf_depth);
TOL = max(0, min(tolerance, .6));
default_label = "Property of/[Your Gallery Here]";
debug = false;
extrafoots = depth*tan(stand_angle);
leg_across = min(max(10, WAT), max(maximum_leg_width, 4));
htLeg = htLegOrig + extrafoots;
crossbar_ht = htLeg - depth*2;
y_to_x_ratio = ((WAB-WAT)/2)/(htLeg+htBack);
width_at_shelf = WAB - 2*htLeg*y_to_x_ratio;
ahole_ht = crossbar_ht + depth * 4;
ahole_base_x = ahole_ht * y_to_x_ratio + leg_across;
ahole_width = (WAB/2-ahole_base_x) * 2;
ahole_top_y = min(htLeg + htBack - leg_across, ahole_ht + ahole_width/y_to_x_ratio/2);
ahole_top_x = ahole_base_x + (ahole_top_y - ahole_ht)*y_to_x_ratio;
slot_width = width_at_shelf*.4;
standLen = standlen(htLegOrig-depth+depth*sin(shelf_tilt), stand_angle, shelf_tilt);
leg_angle = atan(y_to_x_ratio);
bUsableLabel = label != "" && label != default_label;

/* textlines is like text, except it takes an array of lines as
	input rather than a string. The group of lines is centered on the origin, facing up, or if the halign parameter is used to affect justification, with the specified edge at the Y axis. */
module textlines(texts, size=4, halign="center", font="", lineheight=1.4) {
    lines = is_list(texts) ? texts : [texts];
    delta_y = ((len(lines)-1)*size*lineheight - size)/2;
    for (i=[0:len(lines)-1]) {
        translate([0,delta_y-i*size*lineheight,0]) text( lines[i], font=font, size=size,halign=halign);
    }
}

/* strmid takes a substring of a given string argument based on the starting and ending character positions, zero-based. E.g. strmid("abcde", 2, 3) == "cd" */
function strmid(string, start, end) =
    start>end
    ? ""
    : start==end
      ? string[start]
      : (str(string[start],strmid(string,start+1,end)));

/* strsplit, given a string and a delimiter character, returns an array containing the input string divided into elements at the delimiter character. E.g. strsplit("lion,tiger,bear", ",") returns ["lion", "tiger", "bear"]. If delimiter not found, the return value is an array containing the input string as its single element. */
function strsplit(string, delim="/") =
    let(points = search(delim, string, num_returns_per_match=0)[0])
    [ for(i = [0:len(points)])
        len(points)==0
        ?string
        :(
            i==0
            ? strmid(string,0,points[0]-1)
            : (
                i == len(points)
                ? strmid(string, points[i-1]+1, len(string)-1)
                : strmid(string,points[i-1]+1,points[i]-1)))
        ];

/* trapeziod creates an object whose top and bottom are rectangles parallel to the XY plane, and whose other sides connect those rectangles. Parameters are:

	height: the z-dimension of the resulting solid.
	x: either a number which is the x-dimension of both the top and bottom rectangular faces, or a two-element array containing the x-dimensions of the bottom and top rectangles.
	y: similar ro x parameter for the y dimension.
	skew: if 0, the rectangular faces are centered on the same xy coordinate. Skew tell how much to adjust the top rectangle's center position in both dimensions. If a two-element array, the first element is the x-adjustment and the second is y.
	center: If center=false, one corner of the bottom rectangle will be at the xy origin. If center=true, the bottom rectangle will be centered at the XY origin and at -height/2 in z. Depending on skew, the shape may not be centered relative to its bounding box.
*/
module trapezoid(height=10, x=[30,20], y=[45,40], skew = 0, center=false) {
    kskew = is_list(skew)?skew:[skew,skew];
    kx = is_list(x)?x:[x,x];
    ky = is_list(y)?y:[y,y];
    off = [kx[0]-kx[1],ky[0]-ky[1]]/2 + kskew;
    points = [
        // bottom rectangle
        [0,0,0],
        [kx[0],0,0],
        [kx[0],ky[0],0],
        [0, ky[0], 0],
        // top rectangle
        [off.x,off.y,height],
        [off.x+kx[1],off.y,height],
        [off.x+kx[1],off.y+ky[1], height],
        [off.x,off.y+ky[1],height]
    ];
    faces = [
        [0,1,2,3],  // bottom
  [4,5,1,0],  // front
  [7,6,5,4],  // top
  [5,6,2,1],  // right
  [6,7,3,2],  // back
  [7,4,0,3]]; // left

    translate(center?[-kx[0]/2,-ky[0]/2,-height/2]:[0,0,0])
    polyhedron(points, faces,convexity=2);
}

/* a skewed cube is a subset of the class of trapezoids (per the trapezoid method), whose top and bottom rectangles are the same dimensions. The angle parameter specifies the tilt from the vertical of the sides. If angle is a number, it causes a tilt only in the y direction. If a two-element array, it gives separatel tilt angles for x and y. */
module skewed_cube(size, angle=5, center = false) {
    cSize = is_list(size) ? [size.x, size.y] : [size, size];
    cAngle = is_list(angle) ? angle : [0,angle];
    ht = is_list(size) ? size.z : size;
    skew = [ht * tan(cAngle.x), ht * tan(cAngle.y)];
    trapezoid(ht, x=cSize.x, y=cSize.y, skew=skew, center=center);
}

/* Calculate the polygon vertices for the "A" outline of the standing part. */
bigApoints = [
    [0,0],
    [(WAB-WAT)/2, htBack + htLegOrig],
    [(WAB+WAT)/2, htBack + htLegOrig],
    [WAB, 0],
    [WAB-leg_across, 0],
    [WAB-leg_across-crossbar_ht*y_to_x_ratio,crossbar_ht],
    [leg_across+crossbar_ht*y_to_x_ratio,crossbar_ht],
    [leg_across, 0]
];
/* ... and the triangular hole in the A, which might have a flat top. */
holeA = [
    [ahole_base_x, ahole_ht],
    [WAB-ahole_base_x, ahole_ht],
    [WAB-ahole_top_x, ahole_top_y],
    [ahole_top_x, ahole_top_y]
];

// how long does the sticking-out leg of the stand need to be to reach the ground, considering its height and the desired angle for the stand to tilt back?
function standlen(f, a, z) =
    let(tA = tan(a), tZ=tan(z), h=tZ*f/(tA+tZ))
    h/sin(z);
    
/* bigA generates the upright part of the stand. Which is shaped like a big "A". */
module bigA(production = false) {
	lines = strsplit(label,"/");
    difference() {
		// The basic A shape
        linear_extrude(height = depth, convexity = 3)
            difference() {
                polygon(bigApoints);
                polygon(holeA);
        }
		// minus the tilted hole that the shelf/leg part slides into
        translate([WAB/2, htLeg, depth/2])
            rotate([-shelf_tilt,0,0])
            difference() {
				// the hole
                cube([slot_width+TOL, depth+TOL, depth+1], center = true);
				// minus a little notch to make it impossible for the shelf to be inserted wrong.
                translate([slot_width/4,.5-depth/2-TOL,0])
                    cube([2,1,depth+1.01], center=true);
            }
            
        // engrave "property of" text if the back of the A isn't hollowed out
        if (bUsableLabel && !Hollow) {
            rotate([0,0,90-leg_angle])
            translate([(htBack+htLegOrig)/2, -leg_across/2, .49])
            rotate([180,0,0])
            linear_extrude(.5)
            textlines(lines, size=htText, halign="center", font="", lineheight=1.4);
        }
        
        // cut out the "rt" of "Art"
        if (make_it_say_art) {
            translate([(ahole_width+WAB)/2+leg_across/10, ahole_ht,-.05])
            linear_extrude(depth+.1)
            text("rt", size=leg_across/1.7, spacing=1.2);
        }
		
		if (Hollow) {
			// hollow the piece out from the back. This is a complex shape we're subtracting from the solid A.
			difference() {
				// use offset to repeat the overall A shape, but smaller.
				translate([0,0,-1])
				linear_extrude(depth)
				offset(delta=-1)
				difference() {
					polygon(bigApoints);
					polygon(holeA);
					// the slot for the leg -- technically this should be tilted a couple degrees but honestly it will not matter.
					translate([WAB/2, htLeg, 0])
					square([slot_width+TOL, depth+TOL], center = true);
				}
				// at the base of the A shape the hollow-out hole needs to slope inward to match the angle at which we shave off the base.
				translate([-.5,extrafoots,0])
				rotate([stand_angle,0,0])
				translate([0,0,-depth])
				cube([WAB+1,1,2*depth]);
			}
		}
		
		// we've made the A slightly taller than requested so we can slice off a bit to make the feet angled to the stand tilt angle, so they sit flat.
		translate([0,0,depth])
		rotate([stand_angle, 0, 0])
		translate([0,-depth, -depth*180])
		cube([WAB + 2, depth, depth*200]);

    }
	// if the inside of the A is hollow, emboss the label text on the inside of the cavity.
	if (bUsableLabel && Hollow) {
		rotate([0,0,90-leg_angle])
		translate([(htBack+htLegOrig)/2, -leg_across/2, depth-.99])
            rotate([180,0,0])
            linear_extrude(.5)
            textlines(lines, size=htText, halign="center", font="", lineheight=1.4);
	}
	
	// if things are not as they should be for printing, show a warning.
	if (label == default_label && production) {
		color("red")
		translate([0,-24,0])
		rotate([0,180,0])
		linear_extrude(.5)
		textlines(["Customize label text","before export"], size=15,halign="center");
	}
	if (!production) {
		message = label==default_label
			? ["Customize label and change", "display to \"for printing\"", "before export."]
			: ["Change display to", "\"for printing\" before export."];
		color("red")
		translate([WAB/2,-10*len(message)-10,0])
		linear_extrude(.5)
		textlines(message, size=10,halign="center");
	}
}

/* the shelf module is the T-shaped piece that includes both a shelf and a back foot. */
module shelf(production = false) {
    shelf_poke = (width_at_shelf - slot_width)/2;
    ox = (depth-1)/tan(stand_angle+shelf_tilt);

    difference() {
        difference() {
            union() {
                difference() {
                    union() {
                        // main section of back leg
                        translate([shelf_poke, dpShelf-2, 0])
                            cube([slot_width, standLen+2+2*depth, depth]);

                        // protrusion for snap fit
                        translate([(width_at_shelf-slot_width)/2, dpShelf+depth+TOL, 0])
                        rotate([shelf_tilt,0,0])
						translate([0,0,-.5])
                        linear_extrude(height=depth+1)
                        polygon([
                            [-.5,0],
                            [slot_width+.5, 0],
                            [slot_width, 4],
                            [0,4]
                        ]);
                        
                        // angled bit at end of leg to sit flat on surface
                        translate([shelf_poke, dpShelf+standLen+depth+depth,0])
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
                    // groove on underside so it can't be inserted the wrong way.
                    lenn = standLen+ox+depth+4;
                    translate([width_at_shelf/2+slot_width/4, dpShelf-2+lenn/2, .5])
                        cube([2+TOL,lenn,1+2*TOL], center=true);
                    // to make it easier to insert correctly, flare the groove out at the back end.
                    translate([width_at_shelf/2+slot_width/4, dpShelf-8+lenn, .5])
                        linear_extrude(height=1+2*TOL, center=true)
                        polygon([[-1,0], [1,0], [3,8], [-3,8]]);

					// carve off both sides of the "leg" of the T shape to taper it. This is for ease of assembly, because it looks better, and to save material.
                    angu = atan(slot_width/(6*standLen));
                    translate([width_at_shelf-shelf_poke, dpShelf+depth+5, -.1])
                    rotate([0,0,angu])
                    cube([slot_width/2, standLen*1.1, depth+1.2]);
                    translate([shelf_poke, dpShelf+depth+5, depth+.1])
                    rotate([0,180,-angu])
                    cube([slot_width/2, standLen*1.1, depth+1.2]);
                }
                // shelf (top bar of T) is skewed according to the shelf tilt, usually 2 degrees, so it will sit flat against the stand.
                skewed_cube([width_at_shelf, dpShelf, depth], angle=[0,-shelf_tilt]);

            }
            // trim excess of snap catch, which protrudes above and below.
            translate([0,0,depth]) cube([width_at_shelf, dpShelf+depth+5,depth]);
            translate([0,0,-depth])
                cube([width_at_shelf, dpShelf+depth+5,depth]);
        }
        // L-shaped cutouts to make snap clips
        translate([shelf_poke-1.5,dpShelf+depth-.5+TOL+TOL,0])
            rotate([shelf_tilt,0,0])
				translate([0,0,-1]) {
                cube([3,.5,depth+2]);
                translate([2.3,0,0]) rotate([0,0,-6]) cube([.7,4,depth+2]);
                translate([slot_width,0,0]) cube([3,.5,depth+2]);
                translate([slot_width,0,0]) rotate([0,0,6]) cube([.7,4,depth+2]);
            }
			
		// hollow out shelf
		if (Hollow) {
			translate([1, 1, -1])
			cube([width_at_shelf-2,dpShelf-2,depth]);
			
			translate([shelf_poke+2, dpShelf-1.001, depth-1])
			rotate([-90,0,0])
			trapezoid(height=standLen+1+depth, x=[slot_width-4, slot_width/2], depth, skew = 0, center=false);
		}
		
    }
}

module main() {
    if (display == "a") { // display assembled
        if (debug) {
            color("pink", .1)
                translate ([0,0,-1])
                cube([WAB*1.5, standLen*1.8, 1]);
        }
        
        translate([WAB/4, standLen/4, 0])
        rotate([-stand_angle,0,0])
        {
            rotate([90,0,0])
                bigA();
            translate([(WAB-width_at_shelf)/2, 0, htLeg-depth/2])
                rotate([-shelf_tilt,0,0])
                translate([0, -dpShelf-depth, 0])
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
            translate([-(slot_width+width_at_shelf)/2,-dpShelf-4, 0])
            shelf(production=true);
        }
    }
}

main();
echo("all done");
/* extra line just for fun */
