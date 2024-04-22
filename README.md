# A_art_stand

This project is implemented in OpenSCAD 3D modeling software, available free at [openscad.org](https://openscad.org/). The project is parameterized so you can select the dimensions of the stand, whether it has an "rt" cut into it to say "Art", and what text, if any, you would like to engrave on the back (e.g. "Property of Roosevelt Street FLAG").

<img src="https://github.com/users/MethylBromide/projects/2/assets/12117008/3ec24d12-d187-4a65-b1b5-4470e3f10b00" width="400" alt="project as viewed in OpenSCAD program"/>
<img src="https://github.com/users/MethylBromide/projects/2/assets/12117008/2ca74358-36ac-4ded-8b23-593976e9e497" width="400" alt="printed model front view"/>
<img src="https://github.com/users/MethylBromide/projects/2/assets/12117008/c5ec18d1-7d2a-493d-b367-d8877440e20f" width="400" alt="printed model rear view" />

# Instructions for Customization
This assumes you've installed the OpenSCAD software and have some idea how to use it. When you open the main source file, **a_art_stand.scad**, the model will be shown with its default settings. It's shown in its assembled configuration, as in the above illustration. The model is actually composed of two flat parts which snap together, for easier printing and compact storage until you're ready to use it. Once you have it looking the way you want in this "assembled" view, change the **display** parameter to the "for printing" selection to lay the parts out flat for exporting.

As shown in the illustration, if you neglect to change the default value of the "label" text, a big red warning is displayed in the "for printing" view. If you proceed with exporting the model, there will be no label.

<img src="https://github.com/users/MethylBromide/projects/2/assets/12117008/38a495de-0913-4802-831a-54056fb1776b" width="400" alt="Parts laid out for printing, with message 'Customize label text' shown above them"/>

## Descriptions of Parameters

All measurements are in mm or degrees.

- **depth** refers to the thickness of the two pieces.
- **width at base** is the side-to-side measurement of the bottom of the "A" shape.
- **width at top** is the width of the flat part at the top of the "A".
- **back height** is the height of the part of the stand above the front legs.
- **shelf depth** is the distance the shelf you rest the artwork on, projects from the standing part.
- **leg height** is the lengths of the two front legs (so back height + leg height = height of model, if not tilted).
- **stand angle** is how many degrees the stand tilts back from the vertical.
- **shelf tilt** is how much the shelf tilts upward in addition to the stand angle -- zero would put the shelf at a right angle with the front.
- **tolerance** is a property of your 3D printer. The default value is a good one for typical FDM printers. You might need to experiment to find a good value for your own printer.
- **label** is the text to engrave on the back. You can leave it blank, or put whatever you want. The character "/" (forward slash) serves as a line break.
- **letter height** refers to the height from baseline to the top of a capital letter of the label text (so the height of an "A", for instance).
- **make it say art** controls whether the letters "rt" will be cut into the front to the right of the triangular hole.

Once you have the model configured the way you like, set **display** to "for printing, and use the F6 function (menu **Design > Render**), then F7 (menu **File > Export > Export as STL**) to export a file in STL format, which you can then use in a Slider program to prepare the model for 3D printing.

# Notes on Printing

The model is designed to be easy to print in the default orientation. There's plenty of flat surface in contact with the build plate, so you shouldn't need a brim. There are no overhanging parts, so supports aren't needed. Just go for it.

# Notes on Assembling the Stand

The slot in the standing part contains a protrusion that matches up to a groove in the shelf part. This is offset from the center so it's impossible to assemble the stand backwards or with the shelf upside-down.

When pushed fully into place, the shelf should lock into position because of the little snap fittings on either side of the "leg" of the T-shaped shelf part.

![Image](https://github.com/users/MethylBromide/projects/2/assets/12117008/ce4eb3ce-4e9c-42e1-9702-58f808dd0d32)

It may be difficult to disassemble the model once the pieces are locked together, so I encourage you to store it flat until you're ready to start using it.
