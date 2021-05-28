#!/usr/bin/python3

import numpy as np
import matplotlib as mpl
from matplotlib import pyplot as plt

from statsmodels.base.model import GenericLikelihoodModel
from scipy.stats import binom

import sys

mpl.rcParams['font.size'] = 14
mpl.rcParams['savefig.format'] = 'pdf'
mpl.rcParams['savefig.directory'] = '../latex/imgs'

L = 1023
Nblocks = 1000
Npos = 8


def data2bits(data):
	bits = np.zeros(len(data) * 8, np.uint8)
	for i in range(len(data)):
		b = data[i]
		for j in range(8):
			bits[i * 8 + (7 - j)] = b % 2
			b >>= 1
	return bits

def hamming_dist(a, b):
	return int(np.sum((a + b) % 2))


def findsub(a, b):
	len_b = len(b)
	for i in range(len(a) - len_b):
		if (a[i:i+len_b] == b).all():
			yield i

def readfile(filename):
	with open(filename, 'rb') as file:
		file.readline()
		data = file.read()
	return data


references = np.zeros((Npos, L), np.uint8)
posblocks = []
for i in range(Npos):
	filename = 'pos{}'.format(i + 1)
	data = readfile(filename)
	bits = data2bits(data)
	bblocks = np.asarray(list(map(int, bits[: Nblocks * L])))
	blocks = bblocks.reshape((-1, L))
	reference = np.uint8(np.round(blocks.sum(axis=0) / Nblocks))

	posblocks.append(blocks)
	references[i, :] = reference

# Uniformity

uniformity = 0
for i in range(Npos):
	uniformity += posblocks[i].sum() / posblocks[i].size
uniformity /= Npos
print('Uniformity:', uniformity)

# Reliability

avgdistance = 0
for p in range(Npos):
	for i in range(Nblocks):
		d = hamming_dist(references[p], posblocks[p][i, :])
		avgdistance += d / L / Nblocks / Npos
print('Reliability:', 1 - avgdistance)

# Steadiness

logpl = 0
for i in range(Npos):
	pl = posblocks[i].sum(axis=0) / Nblocks
	logpl += np.log2(np.max([pl, 1 - pl], axis=0)).sum() / L / Npos
print('Steadiness:', 1 + logpl)

# Uniqueness

distance = 0
for i in range(Npos):
	for j in range(i, Npos):
		distance += hamming_dist(references[i], references[j]) / L
print('Uniqueness:', distance * 2 / (Npos * (Npos - 1)))

# Bit-aliasing

bitaliasing = np.zeros(L)
for i in range(Npos):
	bitaliasing += posblocks[i].sum(axis=0) / Nblocks / Npos
print('Mean bit-aliasing:', bitaliasing.mean())
hist, _ = np.histogram(bitaliasing, bins=Npos+1)
xvalues = np.linspace(0, 1, Npos + 1)
xbin = np.arange(Npos + 1)
binomial = binom.pmf(xbin, Npos, .5)
plt.plot(xvalues, hist / Nblocks, '*-')
plt.plot(xvalues, binomial)
plt.ylim((0, .35))
plt.legend(('Observed', 'Binomial distribution'))
plt.xlabel('Bit-aliasing value')
plt.ylabel('Probability', loc='top', rotation='horizontal')
plt.tight_layout()
plt.show()
