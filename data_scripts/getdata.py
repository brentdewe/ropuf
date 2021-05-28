#!/usr/bin/python3

import serial

import math
import sys

L = 171
SYNDROME = '001111010111011111101100110001111101111111001100011100000110001011000010110100110101'
TYPE = bytes(sys.argv[1], 'ascii')

# Convert syndrome bits to byte array
syndromeL = math.ceil(len(SYNDROME) / 8)
SYNDROME_BYTES = int(SYNDROME, 2).to_bytes(syndromeL, 'little')

with (serial.Serial('/dev/ttyUSB1', 230400) as ser,
        open('bits', 'wb') as out):
    blocksize = math.ceil(L / 8)
    out.write(b'=~=~=~=~=~=~=~=~=~=~=~= PuTTY log 2021.04.09 17:10:31 =~=~=~=~=~=~=~=~=~=~=~=\r\n')
    while True:
        ser.write(TYPE)
        if TYPE == b's':
            ser.write(SYNDROME_BYTES)
        response = ser.read(blocksize)
        out.write(response)
