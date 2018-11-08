-- Name: Chris Hill
-- Date: 3/22/2017, finished and submitted on 3/23/17.
-- Course: ITEC 320, 10:00 class

-- Purpose: Checks if a group (or singular string) of strings are palindromes.

-- Input is a file with a list of strings, no more than 100 strings. 

-- Output is a line marked Palindrome as is: followed by palindromes.
-- Then Palindrome when converted to upper case: 
-- Which thenshows uppercase palindromes. Then on a new line..
-- Not a palindrome followed by strings that are not palindromes.

-- Sample Input:
-- olapapalo
-- kek
-- Kek
-- YAMERO
-- The goal of this sentence is to almost pass 60 characters.

-- Sample Output:
--Palindrome as is:
--    "kek"
--    "olapapalo"
--Palindrome when converted to upper case:
--    "Kek"
--Not a palindrome:
--    "Thegoalofthissentenceistoalmostpasscharacters"
--    "YAMERO"

-- Help received: Dr. Okie and his website. 
-- An edited sorting algorithm function from rosettacode.
-- Some random forum for one tiny syntax thing.
 
with Ada.Text_IO; use Ada.Text_IO; 
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Characters.Conversions;  use Ada.Characters.Conversions;
with Ada.Characters.Handling; use Ada.Characters.Handling;

procedure do_pals is 

-- New type StringRecord contains length of "actual" string and the string.

	type StringRecord is record
		length: Natural;
		word: String (1..61);
	end record;
	
-- An array of StringRecords the max is 101.
	
	type recordArray is array (1..101) of StringRecord;

-- Record of the above, contains a length field measuring array elements. 	
	
	type recordOfRecordArray is record 
		length: Natural;
		thearray: recordArray;
	end record;
		
-- A record consisting of 3 recordOfRecordArrays used to categorize all strings
		
	type palindromeRecord is record
		palindrome: recordOfRecordArray;
		capPalindrome: recordOfRecordArray;
		regular: recordOfRecordArray;
	end record;


-------------------------------------------------------------------------------
     -- Purpose: Sorts recordOfRecordArrays (rather the arrays inside of them) 
     -- Parameters: a: recordOfRecordArray. 
     -- Precondition: recordOfRecordArray is already "trimmed".
     -- Postcondition: Values should stay the same after sorting.
-------------------------------------------------------------------------------
	
-- Based/Taken from:
-- https://rosettacode.org/wiki/Sorting_algorithms/Selection_sort#Ada

procedure sort (a : in out recordOfRecordArray) is
      min  : Positive;
      temp : StringRecord;
   begin
      for i in 1..a.length - 1 loop
         min := i;
         for j in i + 1..a.length loop
            if a.thearray(min).word > a.thearray(j).word then
               min := j;
			   --put("Min "); put(min); put("is now equal to "); put(j);
            end if;
         end loop;
         if Min /= I then
            temp:= a.thearray(i);
            a.thearray(i):= a.thearray(min);
            a.thearray(min):= temp;
         end if;
      end loop;
   end sort;
   
-------------------------------------------------------------------------------
     -- Purpose: Checks if string is a palindrome. Returns true if yes. 
     -- Parameters: recordToCheck.  
     -- Precondition: String isn't greater than size 60.
     -- Postcondition: None.
-------------------------------------------------------------------------------
	
function isPalindrome(recordToCheck:StringRecord) return Boolean is

reverseCounter: Natural:= recordToCheck.length; -- Counts down from length.

-- Starts at 1 one direction, then length in another. Compares the two.
-- If they match, then it's a palindrome.

begin
	for i in 1..recordToCheck.length loop
		if recordToCheck.word(i) /= recordToCheck.word(reverseCounter) then
			return False;
		end if;
		reverseCounter:= reverseCounter - 1;
	end loop;
	return True;
	
end isPalindrome;

-------------------------------------------------------------------------------
     -- Purpose: Returns true if string is a palindrome ignoring case (a-Z).  
     -- Parameters: recordToCheck.  
     -- Precondition: String isn't greater than size 60.
     -- Postcondition: None.
-------------------------------------------------------------------------------
	
function isCapPalindrome (recordToCheck:StringRecord) return Boolean is
	
	-- The only thing this function does is make the string all uppercase
	-- then calls the above function.
	
	copy: StringRecord:= recordToCheck; --Copy for modification.
	begin
	copy.word:= To_Upper(copy.word); 
	if isPalindrome(copy) then 
		return True;
	end if;
	return False;
	end isCapPalindrome;

-------------------------------------------------------------------------------
     -- Purpose: Removes spaces, special characters and numbers from a string.  
     -- Parameters: records of type recordOfRecordArray
     -- Precondition: String isn't greater than size 60.
     -- Postcondition: None.
-------------------------------------------------------------------------------	
	
function removeStringJunk (records: recordOfRecordArray) 
return recordOfRecordArray is 
	copy: recordOfRecordArray:= records; -- Copy for modification.
	stringCopy: String (1..61); -- String to copy valid characters into.
-- This string is necessary to reset stringCopy for the next loop iteration.	
	emptyString: String (1..61):= "                                                             ";
	counter: Integer:= 1;
	
-- This set of loops, loops through each element of the array, and then checks
-- each character value of each string for junk. It will only copy a character
-- to string copy if the character is not junk. Once the loop is complete, the
-- stringCopy is now the junk free string which is added to the array/record.
	
	begin
		for i in 1..records.length loop
			for j in 1..copy.thearray(i).length loop
				if copy.thearray(i).word(j) in 'A'..'z'  then 
					stringCopy(counter):=copy.thearray(i).word(j);
					counter:= counter + 1;
				end if;
			end loop;
			copy.thearray(i).word:= stringCopy;
			copy.thearray(i).length:= counter -1;
			counter:= 1;
			stringCopy:=emptyString;
		end loop;
		return copy;
	
	end removeStringJunk;	
	
-------------------------------------------------------------------------------
     -- Purpose: Gets words from .txt file, removes junk, and sorts.  
     -- Parameters: records of type recordOfRecordArray
     -- Precondition: String isn't greater than size 60.
     -- Postcondition: None.
-------------------------------------------------------------------------------		

function getWords return recordOfRecordArray is 

sr: StringRecord; -- What is added to the array of records.
records:recordArray; -- What is added to the record of records.
recordofrecords: recordOfRecordArray; -- What is eventually returned.
s: String (1..61); -- This is what is received from .txt.
len: Natural; -- Length of word received from .txt
counter: Natural:= 1;

begin 

-- This loop loops through file adding all records to the record array.

	while (not End_Of_File) loop
		get_line(s,len);
		sr.length:=len;
		sr.word:= s;
		records(counter):= sr;
		counter:=counter+1;	
	end loop;
	
-- Adds record array and length to recordofrecords, removes junk, and sorts.
	
	recordofrecords.thearray:=records;
	recordofrecords.length:=counter-1;
	recordofrecords:= removeStringJunk(recordofrecords);
	sort(recordofrecords);
	
	return recordofrecords;
	
end getWords;

-------------------------------------------------------------------------------
     -- Purpose: Determines status of word (palindrome or not)  
     -- Parameters: records of type recordOfRecordArray
     -- Precondition: String isn't greater than size 60.
     -- Postcondition: None.
-------------------------------------------------------------------------------		

function determinePalindromes (words:recordOfRecordArray) 
return palindromeRecord is 

	palindromes: palindromeRecord; -- This is what is returned.
	part1: recordOfRecordArray; -- Part one, the regular palindromes.
	part2: recordOfRecordArray; -- Part two, the ALLCAPS palindromes.
	part3: recordOfRecordArray; -- Part three, the non palindromes.
	counterone: Natural:= 1; -- Counter for each respective part.
	countertwo: Natural:= 1;
	counterthree: Natural:= 1;
	
begin

-- Loops through all words, checks what they are, and places them in 
-- the appropriate area.  

	for i in 1..words.length loop
		
		if isPalindrome(words.thearray(i)) then
			part1.thearray(counterone):=words.thearray(i);
			counterone:= counterone + 1;
		elsif
			isCapPalindrome(words.thearray(i)) then
			part2.thearray(countertwo):=words.thearray(i);
			countertwo:= countertwo + 1;
		else
			part3.thearray(counterthree):=words.thearray(i);
			counterthree:= counterthree + 1;
		end if;
	end loop;
	
-- Length is equal to the counter (how many times a word was added to category)
-- minus one because it starts at one.
	
	part1.length:=counterone-1; 
	part2.length:=countertwo-1;
	part3.length:=counterthree-1;

	palindromes.palindrome:= part1;
	palindromes.capPalindrome:= part2;
	palindromes.regular:= part3;

	return palindromes;

end determinePalindromes; 

-------------------------------------------------------------------------------
     -- Purpose: Prints the final output of the program.  
     -- Parameters: palindromeRecord
     -- Precondition: String isn't greater than size 60.
     -- Postcondition: None.
-------------------------------------------------------------------------------		

procedure printPalindromes (palindromes:palindromeRecord) is begin
	
	-- Loops through the regular palindromes and prints them.
	
	put_line("Palindrome as is:");

	for i in 1..palindromes.palindrome.length loop
		put("    ");
		put("""");
		put_line(palindromes.palindrome.thearray(i).word
		(1..palindromes.palindrome.thearray(i).length)&"""");
	end loop;

	-- Loops through the ALLCAPS palindromes and prints them.
	
	put_line("Palindrome when converted to upper case:");
	
	for i in 1..palindromes.capPalindrome.length loop
		put("    ");
		put("""");
		put_line(palindromes.capPalindrome.thearray(i).word
		(1..palindromes.capPalindrome.thearray(i).length)&"""");
	end loop;
	
	-- Loops through the NON palindromes and prints them.

	put_line("Not a palindrome:");
	
	for i in 1..palindromes.regular.length loop
		put("    ");
		put("""");
		put_line(palindromes.regular.thearray(i).word
		(1..palindromes.regular.thearray(i).length)&"""");
	end loop;

end printPalindromes;

a: recordOfRecordArray;

-- Main program starts here. Calls getWords and assigns it to a.
-- Prints the determined palindromes.

begin

a:= getWords;
printPalindromes(determinePalindromes(a));
		
end do_pals;