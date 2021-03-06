-- File generated by bch.exe program.
-- The constant package for BCH code (255,171), t=11
-- Option= 3,  Interleave= 1, -- with optimization= 1.
-- GF(2^8) is generated by polynomial [1+x+...] - 101110001;
-- Constant necessary for decoder and encoder

PACKAGE   const IS
	CONSTANT m: INTEGER:= 8;
	CONSTANT n: INTEGER:= 255;  -- n= 2^m -1  -size of block
	CONSTANT k: INTEGER:= 171;  -- BCH code (n,k) -no. of information bits
	CONSTANT nk: INTEGER:= 84; -- nk=n-k
	CONSTANT t: INTEGER:= 11;  -- no. of errors to be corrected

	CONSTANT sizea: INTEGER:= 4; -- size of counter ca
	CONSTANT sizeb: INTEGER:= 5; -- size of counter cb
		-- count = iteration* cb + ca
	CONSTANT sizel: INTEGER:= 4;
		-- size of l integer (degree of error polynomial BMA)
END const;
