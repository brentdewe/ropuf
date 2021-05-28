function bch(reference)

n = 255;
k = 187;

%reference = '10001101101100101100011000001010111101001000101001001101001110100110010011100001111101101100101111001111000101011111001001110000110000010101011100001111010';
%reference = input('', 's');

bits = str2num(fliplr(reference)')';

b = gf(bits);
enc = bchenc(b, n, k);

syndrome = (enc(k + 1 : end) == ones(1, n - k));
disp(char(fliplr(syndrome) + '0'));
