-- Chris Hill

with Ada.Strings.Unbounded.Text_IO; use Ada.Strings.Unbounded.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_io; use Ada.Text_IO;

with Wordpkg; use Wordpkg;
with StackPkg;

package calcpkg is
   type Calculation is limited private;

	procedure get(c: out Calculation);
	procedure put(c: Calculation);
	function to_String(c: Calculation) return String;
	function length(c: Calculation) return Natural;
	type Operator is limited private;
	
		function isOperator (w: Word) return Boolean;
		function toOperator (w: Word) return Operator;
		function lowerPrecedence (a: Operator; b: Operator) return Boolean;
		function operatorEval (n: Integer; z: Integer; l: Operator) return Integer;
		function Result(c: Calculation) return Integer;

private
	
-- New type wordArray, an array of words.
	
	type wordArray is array (1..200) of Word;
		
-- New type calculation, a record with two fields, a word array and length.
		
	type calculation is record
	
	words: wordArray;
	length: Integer;
	
	end record;
	
-- Enumeration type used to define various operands.
		
type Operator is (plus, minus, multiply, divide, power, leftp, rightp, equal);

	package Operator_IO is new Enumeration_IO(Operator);
	use Operator_IO;
			
end calcpkg;
