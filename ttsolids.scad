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

module skewed_cube(size, angle=5, center = false) {
    cSize = is_list(size) ? [size.x, size.y] : [size, size];
    cAngle = is_list(angle) ? angle : [0,angle];
    ht = is_list(size) ? size.z : size;
    skew = [ht * tan(cAngle.x), ht * tan(cAngle.y)];
    trapezoid(ht, x=cSize.x, y=cSize.y, skew=skew, center=center);
}

module skewed_cylinder(h=20, d=10, angle=5) {
    cosA = cos(angle);
    tanA = tan(angle);
    xFace = -d/cosA;
    r=d/2;
    echo(cosA, xFace);
//    render(convexity=1)
    difference() {
        rotate([angle,0,0]) cylinder(h = h/cosA+d*tanA, d=d, center=true);
//        #translate([0,(xFace-sign(xFace))/2, h/2+1]) cube([d+2,abs(xFace)+2,d+1], center=true);
 translate([0, (-tanA*h-sign(h))/2, 1+(h+d)/2]) cube([d,abs(xFace)+2,d+2], center=true);
 translate([0, (tanA*h+sign(h))/2, -1-(h+d)/2]) cube([d,abs(xFace)+2,d+2], center=true);
    }
}

skewed_cube(size=10);
//trapezoid(height=16,x=[10,23],y=[10,5],skew=[-2.5,0],center=true);
////translate([0,0,20]) trapezoid(10, 20, 30, 20);
//double_trapezoid(10, [20,30], [40,20], false);
//translate([0, 0, -5.1]) square([20,30], true);
//translate([0, 0, 5.1]) square([40,20], true);