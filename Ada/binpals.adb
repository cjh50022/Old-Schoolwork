-- Name: Chris Hill
-- Date: 2/1/2017, finished and submitted on 2/8/17.
-- Course: ITEC 320, 10:00 class

-- Purpose: Determines if a binary number and its reverse as well as the pruned 
-- 		version with extraneous zeroes removed are or are not palindromes.

-- Input is at first an integer representing the amount of numbers to be checked. 
-- This is followed by either a decimal or binary number to be checked.

-- Output is a new line with the decimal value followed by the binary value.
-- On this same line is either "Different" or "Same" representing whether the
-- 	original binary and reversed binary values are equal.
-- The second line of output shows the decimal value of the reversed number
--	followed by the binary value. 
-- The third line shows the decimal value of the pruned original input as well
--	as a "Different" or "Same" representing whether the pruned binary and 
--		reversed binary values are equal.
-- The last line shows the decimal value of the reversed pruned number and
--	it's binary value.

-- Sample Input:
-- 1
-- 13

-- Sample Output:
-- Original:         13  00000000000000000000000000001101 Different
-- Reversed: 2952790016  10110000000000000000000000000000
-- Pruned  :         13  1101                             Different
-- Reversed:         11  1011 

-- Help received: Dr. Okie and his website.

with Ada.Text_IO; use Ada.Text_IO; 
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with ada.exceptions; use ada.exceptions;

procedure binpals is
	
	type fourBillionType is mod 2**32; 
	package fourBillion_IO is new Ada.Text_IO.Modular_IO (Num => fourBillionType);
	use fourBillion_IO;
	
	amountofNumbers, i: fourBillionType;
	
	   -----------------------------------------------------------------------
        -- Purpose: Checks if 2^x from 31 to 0 is >= to decimalInput. Prints  
        -- Parameters: decimalInput: value to print in binary. 
        -- Precondition: decimalInput is an integer no greater than 2^32.
        -- Postcondition: Prints the binary representation of a decimal value.
        ---------------------------------------------------------------------
		
	procedure printBinaryNum(decimalInput:fourBillionType) is
		inputCopy: fourBillionType := decimalInput; -- Copy to modify.
		exponent: fourBillionType:= 31; -- Serves as an exponent for 2^x 
		-- operations.
	begin
		for exponent in reverse 0..31 loop
			if inputCopy < 2**exponent then  
				put("0");
			end if;
			if inputCopy >= 2**exponent then
				put("1");
				inputCopy := inputCopy - 2**exponent;
			end if;
		end loop;
	end printBinaryNum;
	
   -----------------------------------------------------------------------
        -- Purpose: When decimalInput >= 2^x, adds 2^y 
		-- (y is reverse digits place of 2^x) to value  
        -- Parameters: decimalInput: value to reverse. 
        -- Precondition: decimalInput is an integer no greater than 2^32.
        -- Postcondition: Returns reversed binary number.
   ---------------------------------------------------------------------
	
	function reverseBin(binaryInput:fourBillionType) return fourBillionType is
		exponent: Integer := 32; -- Serves as exponent for 2^x operations.
		reverseExponent: Integer := -1; -- Used to add 2^y to reverse place 
		-- value if 1 is found in regular loop 
		inputCopy: fourBillionType := binaryInput; -- Copy to modify.
		value: fourBillionType := 0; -- Value to return.
	begin
		for exponent in reverse 0..31 loop
			reverseExponent := reverseExponent + 1;
			if inputCopy >= 2**exponent then
				inputCopy := inputCopy - 2**exponent;
				value := value + 2**reverseExponent;
			end if;
		end loop;
	return value;	
	end reverseBin;
	
  -----------------------------------------------------------------------
        -- Purpose: Divides inputCopy by 2 until the number is odd. 
        -- Parameters: binaryInput: value to prune.
        -- Precondition: binaryInput is an integer no greater than 2^32.
        -- Postcondition: Returns a right pruned binary number.
  ---------------------------------------------------------------------
   
	function pruneBinary(binaryInput:fourBillionType) return fourBillionType is
	inputCopy: fourBillionType := binaryInput; -- Copy to modify.
	begin 
		while inputCopy mod 2 = 0 loop 
			inputCopy := inputCopy / 2;
		end loop;
	return inputCopy;
	end pruneBinary;
	
	-----------------------------------------------------------------------
        -- Purpose: Prints a partially pruned binary number without printing
		-- zeroes to the left, thus "pruning" the left side, printing a 
		-- fully pruned number. 
        -- Parameters: binaryInput: value to print/prune.
        -- Precondition: binaryInput is an integer no greater than 2^32 
		-- and is pruned to the right.
        -- Postcondition: Displays fully pruned binary number.
	---------------------------------------------------------------------
	
	procedure printPrunedBinary(binaryInput:fourBillionType) is
		exponent: Integer := 31;
		inputCopy: fourBillionType := binaryInput;
		havePassedOne: Integer:= 0; -- Sentinel variable turns on when 0's
		-- have become meaningful (a 1 has been passed).
		
	begin
		for exponent in reverse 0..31 loop
			if inputCopy < 2**exponent and havePassedOne = 1  then
				put("0"); -- Only prints zeroes that have come after a 1.
			end if;
			if inputCopy >= 2**exponent then
				havePassedOne := 1; 
				inputCopy := inputCopy - 2**exponent;
				put("1");
			end if;
		end loop;
	end printPrunedBinary;

	-----------------------------------------------------------------------
        -- Purpose: Prints the main output of our program.
        -- Parameters: decimalInput: value to print, reverse, and prune.
        -- Precondition: binaryInput is an integer no greater than 2^32 
        -- Postcondition: Displays main program output.
	---------------------------------------------------------------------
	
procedure printProgram(decimalInput:fourBillionType) is
		a: fourBillionType := decimalInput;
		b: fourBillionType; -- The reverse of the original input.
		c: fourBillionType; -- The pruned version of the original input.
		d: fourBillionType; -- The pruned version of the reverse input.
	begin
	
		b:= reverseBin(a);
		c := pruneBinary(a);
		d := pruneBinary(b);

		put("Original: "); put(a,11); put("  "); printBinaryNum(a); put(" "); 
		
		if a = b then
			put("Same");
		else
			put("Different");
		end if;	
		
		new_line;
		put("Reversed: "); put (b,11); put("  "); printBinaryNum(b);
		new_line;
		put("Pruned  :"); put (c,12); put("  "); printPrunedBinary(c); put(" ");
		if c = d then
			set_col(57);
			put("Same");
		else
			set_col(57);
			put("Different");
		end if;
		put_line("");
		put("Reversed:"); put(d,12); put("  "); printPrunedBinary(d); put(" ");
		new_line;
	end printProgram;

	
begin
	
	get(amountofNumbers);
	
	--Used to print correct amount of times based on first input in .txt.
	
	for number in 1..amountofNumbers loop
		get(i);
		put_line("");
		printProgram(i);
		put("");
	end loop;
	exception
	when others => new_line; put_line("Invalid input.");
end binpals;