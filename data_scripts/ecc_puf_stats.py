#!/usr/bin/python3

import numpy as np
from matplotlib import pyplot as plt

import sys
import math

L = 171
blockL = math.ceil(L / 8) * 8


def data2bits(data):
	bits = np.zeros(len(data) * 8, np.uint8)
	for i in range(len(data)):
		b = data[i]
		for j in range(8):
			bits[i * 8 + j] = b % 2
			b >>= 1
	return bits


def hamming_dist(a, b):
	return int(np.sum((a + b) % 2))


def readfile(filename):
	with open(filename, 'rb') as file:
		file.readline()
		data = file.read()
	return data


def bits2str(bits):
	return ''.join(map(str, reversed(bits)))


# Load and process data

data = readfile(sys.argv[1])
bits = data2bits(data)

Nblocks = int(len(bits) / blockL)
bblocks = np.asarray(list(map(int, bits[: Nblocks * blockL])))
blocks = bblocks.reshape((-1, blockL))
blocks = blocks[:, :L]

bits = blocks.reshape((-1,))

reference = np.uint8(np.round(blocks.sum(axis=0) / Nblocks))


print(len(bits), 'bits')
print('Reference block:', bits2str(reference))


# Uniformity

print('Uniformity:', bits.sum() / len(bits))


# Reliability

avgdistance = 0
for i in range(Nblocks):
	d = hamming_dist(reference, blocks[i, :])
	avgdistance += d / L / Nblocks
print('Reliability:', 1 - avgdistance)


# Steadiness

pl = blocks.sum(axis=0) / Nblocks
steadiness = 1 + np.log2(np.max([pl, 1 - pl], axis=0)).sum() / L
print('Steadiness:', steadiness)


# Max error

ds = np.zeros(Nblocks)
distances = {}
for i in range(Nblocks):
	d = hamming_dist(reference, blocks[i, :])
	ds[i] = d
	distances[d] = distances.get(d, 0) + 1
dists = sorted(distances.items())
