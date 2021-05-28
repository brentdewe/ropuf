#!/usr/bin/python3

import sys

width = int(sys.argv[1])
height = int(sys.argv[2])
startx = int(sys.argv[3])
starty = int(sys.argv[4])

print('#ROs: 2 x', width * height)

for w in range(width):
    for h in range(height):
        print('set_property LOC SLICE_X{}Y{} [get_cells {{puf_i/ro_array_0/U0/gen_ro[{}].r/u0}}]'
                .format(startx + w, starty + h, h * width + w))
        print('set_property LOC SLICE_X{}Y{} [get_cells {{puf_i/ro_array_1/U0/gen_ro[{}].r/u0}}]'
                .format(startx + w, starty + height + h, h * width + w))
