-- Name: Chris Hill
-- Date: 2/19/2017, finished and submitted on 2/23/17.
-- Course: ITEC 320, 10:00 class

-- Purpose: Prints floating point numbers in binary and prints variations of
-- floating point numbers by reversing all bits and reversing exponent bits.

-- Input is a floating point or sequence of floating point numbers from file. 
-- Output is the original fp number in decimal and binary scientific notation
-- Followed by the original number f with its bits reversed
-- Followed by the orignal number f, but with its exponent bits reversed and 
--   its (non-hidden) mantissa bits reversed 

-- Sample Input:
-- .99

-- Sample Output:
-- 9.90000010E-1   1.1111 1010 1110 0001 0100 100E   -1  0:0111 1110:1111 1010 1110 0001 0100 100
-- 1.23812447E-16  1.0001 1101 0111 1101 1111 100E  -53  0:0100 1010:0001 1101 0111 1101 1111 100
-- 5.72378099E-1   1.0010 0101 0000 1110 1011 111E   -1  0:0111 1110:0010 0101 0000 1110 1011 111
-----------------------------------------------------------------------------------------------
-- Help received: Dr. Okie and his website.

-- Console size is of width 98, to fit all output.
-- I started this assignment too late, the "last day" I reserve for cleaning
--	and reviewing code is gone. Probably some redundancies and minor illogical
--	 things. 

with Ada.Text_IO; use Ada.Text_IO; 
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with unchecked_conversion;

	
procedure floatflip is 

-- New type unsigned32, is self explanatory.

type unsigned32 is mod 2**32;
package unsigned32_io is new Ada.Text_IO.Modular_IO(unsigned32);

--Procedure for unchecked_conversion from float to unsigned 32.

function convert is new unchecked_conversion(source => float, target => unsigned32);
use unsigned32_IO;

-- New type Bit, an Integer restricted to 0 or 1.

subtype Bit is Integer range 0 .. 1;

-- New type BitString, an array of Bits from 1 to 32.

type BitString is array(1 .. 32) of Bit with component_size => 1, size => 32;
	
	------------------------------------------------------------------------
     -- Purpose: Prints floating point in decimal scientific notation. 
     -- Parameters: f: value to print. 
     -- Precondition: f is a floating point.
     -- Postcondition: Prints floating point in decimal scientific notation.
     -----------------------------------------------------------------------
	
	procedure printLeft (f:float) is --printLeft because it prints Left column.
	begin
		put(f,2,8,2);
	end printLeft;

-- Converts BitString to floating point;	
	
function convertBitString is new unchecked_conversion(source => BitString, target => float);
use unsigned32_IO;

	 ------------------------------------------------------------------------
     -- Purpose: Sticks 1 or 0 in indexes of BitString depending on what f is. 
	 --			Then returns the BitString.  
     -- Parameters: f: value to "convert" to binary. 
     -- Precondition: f is a floating point.
     -- Postcondition: Returns binary value of floating point number.
     -----------------------------------------------------------------------
	
	function copyBits (f:float) return BitString is
	
		a: BitString; -- The BitString to be returned.
		i: unsigned32 := convert(f);
		counter: Integer := 1; -- Counter for the loop.
		
	begin
	
		for exponent in reverse 0..31 loop
		
			if i < 2**exponent then  
				a(counter):= 0;
				
			end if;
			
			if i >= 2**exponent then
				a(counter):= 1;
				i := i - 2**exponent;
			end if;
			
		counter := counter + 1;
		
		end loop;
		
	return a;	
	end copyBits;
	
	------------------------------------------------------------------------
    -- Purpose: Loops through bitString prints all elements with specific
	-- 			format for readibility.
    -- Parameters: a: BitString to print. 
    -- Precondition: a is a bitString.
    -- Postcondition: Prints bitString in right column with punctuation.
     -----------------------------------------------------------------------
	
	procedure printRight (a:BitString) is --printRight, it prints right column.
		counter: Integer :=1; -- Counter for loops.
	begin
	set_col(56);
		for i of a (1..32) loop
			if counter = 2 or counter = 10 then -- So colon is in right place.
				put(":");
			end if;
			
			-- Puts spaces in the appropriate places.
			if counter = 6 or counter = 14 or counter = 18 or counter = 22 or counter = 26 or counter = 30 then 
				put(" ");
			end if;
			
			put(i,1);
			counter := counter+1;
		end loop;
		
	end printRight;
	
	------------------------------------------------------------------------
    -- Purpose: Loops through indexes of BitString determining the exponent
	--			and printing exponent + Significand. Checks for special
	--			cases as well.
    -- Parameters: a: BitString to manipulate and print. 
    -- Precondition: a is a bitString.
    -- Postcondition: The middle column is printed.
     -----------------------------------------------------------------------
	
	procedure printMiddle (a: Bitstring) is 
		
		counter: Integer :=0; -- Counter for loops.
		exponent: Integer:= 0; -- Value of exponent before applying bias.
		sum: Integer:=0; -- Sum of bits in significand, used for below variables.
		
		-- These are all boolean (though I used int?) values for special cases.
		
		exponentIsAllZero: Integer:= 0;
		exponentIsAllOne: Integer:= 0;
		sigIsAllZero: Integer:= 0; --sig stands for significand.
		sigIsAllOne: Integer:= 0;
		
		f:float:=convertBitString(a);

		begin 
			-- Loop for determining exponent without bias.
			for i in reverse 2..9 loop
				exponent:= exponent + (a(i) * (2 ** counter));
				counter:= counter + 1;
			end loop;
			
			exponent:= exponent-127; -- Applying bias to exponent.
			
			-- These sets of if statements are used to check if the 4 boolean
			-- values have become true.
			
			if exponent = -127 then -- 
				exponentIsAllZero:= 1;
			end if;
			
			if exponent = 128 then
				exponentIsAllOne:= 1;
			end if;
				
			for i in 10..32 loop
				sum:= a(i) + sum;
			end loop;
			
			if sum = 0 then
				sigIsAllZero:= 1;
			end if;
			
			if sum = 24 then 
				sigIsAllOne := 1;
			end if;
			
			set_col(18);
			
			-- These if statements are for printing the middle column 
			-- depending on whether or not there is a special case.
			
			if exponentIsAllOne = 1 and sigIsAllZero = 0 then --NaN
				 put("NaN");
				 put("*********************************");
			elsif
				exponentIsAllOne = 1  and sigIsAllZero = 1 then --Inf
				put("Inf");
				put("********************************");
			elsif
				exponentIsAllZero = 1 and sigIsAllZero = 1 then --Zero
				exponent := 0;
				
				-- Loop is for printing significand with right formatting.
				
				for i in 10..32 loop
			
					if i = 6 or i = 14 or i = 18 or i = 22 or i = 26 or i = 30 then 
						put(" ");
					end if;
					put(a(i),1);
				end loop;
				
			put("E ");
			put(exponent,4);
				
			elsif
			exponentIsAllZero = 1 and sigIsAllZero = 0 then -- Denormalized
				put("0.");
				exponent := -126;
				
--Probably a better way than copy/pasting the same loop, not enough time though.
				
				for i in 10..32 loop
			
					if i = 6 or i = 14 or i = 18 or i = 22 or i = 26 or i = 30 then 
						put(" ");
					end if;
					put(a(i),1);
				end loop;
				
			put("E ");
			put(exponent,4);
				
			else -- Regular 
				put("1.");
				
				for i in 10..32 loop
			
					if i = 6 or i = 14 or i = 18 or i = 22 or i = 26 or i = 30 then 
						put(" ");
					end if;
					put(a(i),1);
				end loop;
			
			put("E ");
			put(exponent,4);
				
			end if;
				
		end printMiddle;

	------------------------------------------------------------------------
    -- Purpose: Reverses an entire BitString then returns reversed bitString.
    -- Parameters: a: BitString to reverse and print. 
    -- Precondition: a is a bitString.
    -- Postcondition: Returns reversed bitString.
    -----------------------------------------------------------------------
	
	function reverseBit(a:BitString) return BitString is
		
		b:BitString; -- BitString to return.
		lowCounter: Integer := 1; -- Counter for starting at first index
		highCounter: Integer := 32; -- Counter for starting at last index.
	
	begin
	
		for i of a (1..32) loop
			b(lowCounter):= a(highCounter);
			lowCounter:= lowCounter+1;
			highCounter:= highCounter-1;
		end loop;	
		
	return b;
	
	end reverseBit;	
	
------------------------------------------------------------------------
-- Purpose: Converts reversed BitString to float and prints in decimal scientific notation.
-- Parameters: a: BitString to reverse and print. 
-- Precondition: a is a bitString.
-- Postcondition: Prints converted BitString.
-----------------------------------------------------------------------
	
procedure printLeftReversed(a:BitString) is 
		f:float:= convertBitString(a); -- Float to convert.
	begin
		put(f,2,8,2);
		if f < 0.0 then
			set_col(17);
			put("-");
		end if;
	end printLeftReversed;	
	
------------------------------------------------------------------------
-- Purpose: Reverses exponent bits, then reverses significand. 
--			Returns reversed bitString.
-- Parameters: a: BitString to reverse and print. 
-- Precondition: a is a bitString.
-- Postcondition: returns converted BitString.
-----------------------------------------------------------------------	
	
function reverseExponent (a:BitString) return BitString is
	b: BitString:=a; --BitString to return.
	lowCounter: Integer := 2; --Counter for far right exponent place.
	highCounter: Integer := 9; -- Counter for far left exponent place.
	
	begin
		for i of a (2..9) loop
			b(lowCounter):= a(highCounter);
			lowCounter:= lowCounter+1;
			highCounter:= highCounter-1;
		end loop;	
	
		lowcounter := 10; -- Counters need new values for next loop.
		highCounter := 32;
	
		for i of a (10..32) loop
			b(lowCounter):= a(highCounter);
			lowCounter:= lowCounter+1;
			highCounter:= highCounter-1;
		end loop;	
	
	return b;
	
	end reverseExponent;

------------------------------------------------------------------------
-- Purpose: Converts bitString to fp and prints left column of 3rd row. 
-- Parameters: a: BitString to convert and print. 
-- Precondition: a is a bitString.
-- Postcondition: prints left column of 3rd row..
-----------------------------------------------------------------------		
	
procedure printLeftExponent(a:BitString) is
		b: BitString := reverseBit(a); --BitString to convert.
		f:float:=convertBitString(b); -- Converting to float.
	begin
		put(f,2,8,2);
	end printLeftExponent;
	
-----------------------------------------------------------------------
        -- Purpose: Prints the main output of our program.
        -- Parameters: f: value to print, reverse, print again.
        -- Precondition: f is a floating point.
        -- Postcondition: Displays main program output.
---------------------------------------------------------------------
		
procedure printProgram (f: float) is
		b: Bitstring := copyBits(f); --1st line.
		c: BitString := reverseBit(b); -- 2nd line.
		d: BitString := reverseExponent(b); -- 3rd line.
	begin	
	
	-- Printing everything with proper formatting.
	
		printLeft(f);
		printMiddle(b);
		printRight(b);
		put_line(" ");
		printLeftReversed(b);
		printMiddle(c);
		printRight(c);
		put_line("");
		printLeftExponent(d);
        printMiddle(d);
		printRight(d);
		put_line("");
		put("-----------------------------------------------------------------------------------------------"); 
		put_line("");

	end printProgram;

		f: float; -- Float to run through printProgram.
		
begin

	while (not End_Of_File) loop
             get(f);
			 printProgram(f);
    end loop;
	
exception -- Error checking.
	when data_error => new_line; put_line("Invalid input.");
	when end_error => 
	put_line("Unexpected end of input. No white space after final value.");

end floatflip;