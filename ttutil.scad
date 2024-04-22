module textlines(texts, size=4, halign="center", font="", lineheight=1.4) {
    lines = is_list(texts) ? texts : [texts];
    delta_y = ((len(lines)-1)*size*lineheight - size)/2;
    for (i=[0:len(lines)-1]) {
        translate([0,delta_y-i*size*lineheight,0]) text( lines[i], font=font, size=size,halign=halign);
    }
}

function strmid(string, start, end) =
    start>end
    ? ""
    : start==end
      ? string[start]
      : (str(string[start],strmid(string,start+1,end)));
    
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
        
