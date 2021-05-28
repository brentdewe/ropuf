#!/usr/bin/python3

from Crypto.Cipher import AES  #> pip install pycrypto

from base64 import b16decode, b64encode
import math


MESSAGE = b'Hello World!'


def pad(data):
    L = AES.block_size * math.ceil(len(data) / AES.block_size)
    Nzeros = L - len(data)
    return data + bytes(Nzeros)


print('Message:', MESSAGE.decode())

hexkey = input('Input key: ')
key = b16decode(hexkey.upper())

cipher = AES.new(key, AES.MODE_ECB)
encrypted = cipher.encrypt(pad(MESSAGE))
print('Encrypted message:', b64encode(encrypted))
