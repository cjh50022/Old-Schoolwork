-- Name: Chris Hill
-- Date: 4/17/2017, finished and submitted on 4/21/17.
-- Course: ITEC 320, 10:00 class

-- Purpose: Does basic calculations using +, -, *, /, **, and (). 

-- Input is a file with a list of equations. 

-- Output is the solved equation in a readable format. One space after each operand
-- excluding parenthesis.

-- Sample Input:
-- ( 3 + 2 ) * 5 =

-- Sample Output:
-- 3 + 2 * 5 =  13

-- Help received: Dr. Okie and his website. 
-- Some random place on the internet I forgot for some syntactical thing.

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with calcpkg; use calcpkg;

procedure calc is 

c : Calculation;

begin

while (not End_Of_File) loop
	get(c);
	put_line(to_string(c) & result(c)'img);
end loop
;
end calc;
