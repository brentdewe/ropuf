#!/usr/bin/python3

import matplotlib as mpl
import matplotlib.pyplot as plt

mpl.rcParams['font.size'] = 14
mpl.rcParams['savefig.format'] = 'pdf'
mpl.rcParams['savefig.directory'] = '../latex/imgs'

refcounts = [
	100,
	200,
	500,
	1000,
	2000,
	5000,
]
reliabilities = [
	0.9873513478493668,
	0.9922175715226351,
	0.9957592437431149,
	0.9973688497882046,
	0.9986137549804782,
	0.9990788347635438,
]

plt.semilogx(refcounts, reliabilities, '*-')
plt.xticks(refcounts, list(map(str, refcounts)))
plt.xlabel('Number of clock cycles')
plt.ylabel('Reliability', loc='top', rotation='horizontal')
plt.tight_layout()
plt.show()
