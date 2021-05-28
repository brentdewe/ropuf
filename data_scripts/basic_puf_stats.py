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


data = readfile(sys.argv[1])
bits = data2bits(data)

print(len(bits), 'bits')


# Uniformity

print('Uniformity:', bits.sum() / len(bits))


# Split in blocks

Nblocks = int(len(bits) / L)
bblocks = np.asarray(list(map(int, bits[: Nblocks * L])))
blocks = bblocks.reshape((-1, L))

reference = np.uint8(np.round(blocks.sum(axis=0) / Nblocks))


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

SIZE = 171

class Binom(GenericLikelihoodModel):
	def loglike(self, params):
		return np.log(binom.pmf(self.endog, SIZE, *params)).sum()

ds = np.zeros(Nblocks)
distances = {}
for i in range(Nblocks):
	d = hamming_dist(reference[:SIZE], blocks[i, :SIZE])
	ds[i] = d
	distances[d] = distances.get(d, 0) + 1
dists = sorted(distances.items())
x = [d[0] for d in dists]
pdf = [d[1] / Nblocks for d in dists]
res = Binom(ds).fit((.009,), disp=False)
p_err = res.params[0]
print('Fitted binomial: B({}, {})'.format(SIZE, p_err))

plt.plot(x, pdf, '*-')
xn = np.arange(max(ds))
pdffit = binom.pmf(xn, SIZE, p_err)
plt.plot(xn, pdffit)
plt.legend(('Observed data', 'Fitted binomial distribution'))
plt.xlim((0, 40))
plt.xlabel('Hamming distance')
plt.ylabel('Probability', loc='top', rotation='horizontal')
plt.tight_layout()
#plt.show()
xfull = np.arange(L + 1)
cdf = binom.cdf(xfull, SIZE, p_err)
maxerr = np.flatnonzero(cdf > 1 - 1e-6)[0]
print('Max error 1 ppm at block size {}: {}'.format(SIZE, maxerr))
