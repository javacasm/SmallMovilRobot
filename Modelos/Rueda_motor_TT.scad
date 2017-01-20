//use <tyler.scad>;

E=0.05*1;

$fn=128*1;


// Cave for the external gun (mm)
cave_width = 5;

// Wheel diameter (mm)
wheel_dia = 65; // [10:150]

// Thickness of the outer rim (mm)
rim_thickness = 2.0;

// Width of the wheel rim (mm)
wheel_width = 5;

// Number of spokes
num_spokes = 16; // [2:16]

// How thick each spoke is (mm)
spoke_thickness = 2.0;

// Diameter of the round aspect of the shaft (mm)
shaft_dia = 5.37;

// Width between the flats of the shaft (mm)
shaft_flats_dia = 3.67;

// How much wider to make the bore to fit the shaft -- play with this value (mm)
shaft_tolerance = 0.4;

// Width of the center hub (the part that accepts the shaft) (mm)
hub_width = wheel_width;

// How thick around the shaft is the hub? (mm)
hub_thickness = 2.0;

// Diameter of the center hub
hub_dia = shaft_dia+2*hub_thickness;


module cube2(size,aligns="LLL",radius=0,xy_radius=0) {
    real_size = len(size) ? size : [size,size,size];
    tr = [
        aligns[0]=="C" ? 0 : aligns[0]=="R" ? (-real_size[0]/2) : (+real_size[0]/2),
        aligns[1]=="C" ? 0 : aligns[1]=="R" ? (-real_size[1]/2) : (+real_size[1]/2),
        aligns[2]=="C" ? 0 : aligns[2]=="R" ? (-real_size[2]/2) : (+real_size[2]/2)
    ];
    translate(tr) {
        if (xy_radius>0) {
            inner_size = [for (v=real_size) v-min(xy_radius*2,v)];
            linear_extrude(real_size[2], center=true) offset(r=xy_radius) square([inner_size[0],inner_size[1]], center=true);
        } else if (radius>0) {
            if (radius*2 >= max(real_size)) {
                resize(real_size) sphere(1);
            } else {
                inner_size = [for (v=real_size) v-min(radius*2,v)];
                minkowski() {
                    cube(inner_size,center=true);
                    sphere(r=radius);
                }
            }
        } else {
            cube(real_size,center=true);
        }
    } 
}

module tube(id, od, h) {
    linear_extrude(h) difference() {
        circle(d=od);
        circle(d=id);
    }
}

module double_flat_circle(dia, flats_dia) {
    difference() {
        circle(d=dia);
        for (m=[0,1]) mirror([0,m]) 
            translate([-dia,flats_dia/2]) square([2*dia,dia]);
    }
}




difference() {
    union() {
        difference()
        {
        // outer rim
        tube(od=wheel_dia, id=wheel_dia-rim_thickness*2, h=wheel_width);
        
            
        // External cave    
        rotate_extrude(convextity=5,$fn=100)
           translate([wheel_dia/2+cave_width*98/100,wheel_width/2,0])
           circle(r=cave_width,$fn=100);

            
           }
       
        // spokes
        for (i=[0:num_spokes-1]) {
            a = i/num_spokes*360;
            rotate(a) cube2([wheel_dia/2-rim_thickness/2, spoke_thickness, hub_width], aligns="LCL");
        }
        
        //hub
        cylinder(d=hub_dia, h=hub_width);
    }
    translate([0,0,-E]) linear_extrude(hub_width+2*E) offset(shaft_tolerance) double_flat_circle(shaft_dia,shaft_flats_dia);
}

%translate([0,0,-1]) linear_extrude(8.38) double_flat_circle(shaft_dia,shaft_flats_dia);
%translate([-10,0,-1]) cube2([60,30,20],aligns="CCR");

