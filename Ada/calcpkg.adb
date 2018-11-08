--Chris Hill

with WordPkg; use WordPkg;
with StackPkg;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with StackPkg;

package body calcpkg is

-------------------------------------------------------------------------------
-- Purpose: Gets a calculation from input, stores it in parameter. 
-- Parameters: One calculation variable.
-- Precondition: Valid input from .txt file. Length cannot be greater than 200.
-- Postcondition: None.
-------------------------------------------------------------------------------

procedure get(c: out Calculation) is 
	
	i: Integer:= 1;
	Item: Word;
	
	begin
		loop -- No condition for loop. Condition defined in loop.
			get(Item);
			c.words(i):= Item;
			
			--If an operator is =, we have reached the end.
			
			if isOperator(Item) and toOperator(Item) = equal then
				exit;
			end if;
			i:= i + 1;
		 end loop;
		c.length:= i;
   end get;
   
-------------------------------------------------------------------------------
-- Purpose: Returns a string value of calculation. One space after each item. 
-- Parameters: One calculation variable.
-- Precondition: Not a null value.
-- Postcondition: None.
-------------------------------------------------------------------------------
	
	function to_String (c: Calculation) return String is
	s: unbounded_string:= null_unbounded_string;
	begin
	for i in 1..c.length loop
		s:= s & to_unbounded_string(to_string(c.words(i),length(c.words(i))));
		s:= s & " ";
	end loop;
	
	return(to_string(s));
	
	end to_String;

-------------------------------------------------------------------------------
-- Purpose: Prints a calculation, no spaces in between items. 
-- Parameters: One calculation variable.
-- Precondition: Not a null value.
-- Postcondition: None.
-------------------------------------------------------------------------------
	
	procedure put(c: Calculation) is begin
	
			for i in 1..c.length loop
				put(c.words(i));
			end loop;
			
	end put;

-------------------------------------------------------------------------------
-- Purpose: Returns total number of operands + operators. 
-- Parameters: One calculation variable.
-- Precondition: Not a null value.
-- Postcondition: None.
-------------------------------------------------------------------------------
	
	function length (c: Calculation) return Natural is
	begin
	
	return c.length;
	
	end length;
	
-------------------------------------------------------------------------------
-- Purpose: Checks if a word is an operator.
-- Parameters: One word variable.
-- Precondition: Not a null value.
-- Postcondition: None.
-------------------------------------------------------------------------------	
	
	function isOperator (w: Word) return Boolean is
	
	s: String (1..1);
	s2: String(1..2);
	cw: Word;
	
	begin
	
--s is set to an operator, converted to a word, then checked for all operators. 

		s:= "+";
		cw:= new_Word(s);
		
		if(w = cw) then
			return true;
		end if;
		
		s:= "-";
		cw:= new_Word(s);
		
		if(w = cw) then
			return true;
		end if;
		
		s:= "*";
		cw:= new_Word(s);
		
		if(w = cw) then
			return true;
		end if;
		
		s:= "/";
		cw:= new_Word(s);
		
		if(w = cw) then
			return true;
		end if;
		
		s:= "=";
		cw:= new_Word(s);
		
		if(w = cw) then
			return true;
		end if;
		
		s:= "(";
		cw:= new_Word(s);
		
		if(w = cw) then
			return true;
		end if;
		
		s:= ")";
		cw:= new_Word(s);
		
		if(w = cw) then
			return true;
		end if;
		
		s2:= "**";
		cw:= new_Word(s2);
		
		if(w = cw) then
			return true;
		end if;
	
		return false;
	end isOperator;
	
-------------------------------------------------------------------------------
-- Purpose: Converts a word to an operator. 
-- Parameters: One word.
-- Precondition: The word is actually an operator (use isOperator) and not null
-- Postcondition: None.
-------------------------------------------------------------------------------
	
	function toOperator (w:Word) return Operator is
	
	s: String (1..1);
	s2: String(1..2);
	cw: Word;
	
	begin
	
		s:= "+";
		cw:= new_Word(s);
		
		if(w = cw) then
			return plus;
		end if;
		
		s:= "-";
		cw:= new_Word(s);
		
		if(w = cw) then
			return minus;
		end if;
		
		s:= "*";
		cw:= new_Word(s);
		
		if(w = cw) then
			return multiply;
		end if;
		
		s:= "/";
		cw:= new_Word(s);
		
		if(w = cw) then
			return divide;
		end if;
		
		s:= "=";
		cw:= new_Word(s);
		
		if(w = cw) then
			return equal;
		end if;
		
		s:= "(";
		cw:= new_Word(s);
		
		if(w = cw) then
			return leftp;
		end if;
		
		s:= ")";
		cw:= new_Word(s);
		
		if(w = cw) then
			return rightp;
		end if;
		
		s2:= "**";
		cw:= new_Word(s2);
		
		if(w = cw) then
			return power;
		end if;
		
		return plus;
		
	end toOperator;
	
-------------------------------------------------------------------------------
-- Purpose: Checks if operator a is of lower precedence compared to b. 
-- Parameters: Two operators, the first a and second b.
-- Precondition: None.
-- Postcondition: None.
-------------------------------------------------------------------------------
	
	function lowerPrecedence (a: Operator; b: Operator) return Boolean is 
	begin
		
		if a = equal then
			return false;
		end if;
	
		if (a = power) and (b = plus or b = minus or b = multiply or b = divide) then 
			return false;
		end if;
		
		if (a = multiply or a = divide) and (b = plus or b = minus) then 
			return false;
		end if;
		
		if b = leftp then 
			return false;
		end if;
		
		return true;
		
	end lowerPrecedence;
	
-------------------------------------------------------------------------------
-- Purpose: Does basic calculations using operators. 
-- Parameters: Two integers to operate on and an operation.
-- Precondition: None.
-- Postcondition: None.
-------------------------------------------------------------------------------
	
function operatorEval (n: Integer; z: Integer; l: Operator) return Integer is
	
	begin
	
	if (l = plus) then
		return n + z;
	end if;
	
	if (l = minus) then
		return n - z;
	end if;
	
	if (l = multiply) then
		return n * z;
	end if;
	
	if (l = divide) then
		return z / n;
	end if;
	
	if (l = power) then
		return n ** z;
	end if;
	
	return 0;

end operatorEval;
	
-------------------------------------------------------------------------------
-- Purpose: Returns result of calculation.
-- Parameters: One calculation.
-- Precondition: None.
-- Postcondition: None.
-------------------------------------------------------------------------------
	
	function result (c: Calculation) return Integer is
	
	package intStk is new StackPkg(100, Integer);
	package operatorStk is new Stackpkg(100, Operator);
	use intStk;
	use operatorStk;
		
	intStack : IntStk.Stack;
	operatorStack: operatorStk.Stack;
	number: Integer; -- Variable to store integer value of string value of word
	z: Integer:= 0; -- First variable in operation handling.
	n: Integer:= 0; -- Second variable in operation handling.
	result: Integer:= 0; -- Value to return and solution to equation.
	currentOp: Operator; -- Current operator running through loop section 1.
	hasPushed: Boolean; -- Most likely unneeded. No time to refactor!
	whileControl: Boolean:= false; -- Controls loop section 2.
	begin

--Here begins loop section one. The purpose of this section is to add values to
--the two stacks. Also handles evaluation of stacks until can be handled without
--conditionals. Example: (1+1) * 2 = would evaluate up to 2 * 2, then move on 
--to section 2.
	
	for i in 1..c.length loop
	hasPushed:= false;
	if isOperator(c.words(i)) then -- If word is an operator.
				currentOp:= toOperator(c.words(i));

--If the operator is a left parenthesis immediately add to the stack.
				
				if currentOp = leftp then
					push(currentOp,operatorStack);
					hasPushed:= true;
				end if;
				
--If the operator is a right parenthesis, immediately evaluate stacks.				
				
				if currentOp = rightp then
					currentOp:= toOperator(c.words(i));
					
--Continously evaluates until a left parenthesis is found.	
	
					while top(operatorStack) /= leftp loop
					n:= top(intStack); 
						pop(intStack); 
						z:= top(intStack);
						pop(intStack);
						result:= operatorEval(n,z,top(operatorStack));
						pop(operatorStack);
						push(result,intStack);
					end loop;
				haspushed:= true;
				
-- If the operator stack is empty, immediately add operator to stack.				
				
				elsif isEmpty(operatorStack) then 
					currentOp:= toOperator(c.words(i));
					push(currentOp,operatorStack);
					hasPushed:= true;
				elsif 
				
-- If the operator stack isn't empty.				
								
					isEmpty(operatorStack) = false and hasPushed = false then 
					
--If the current operator is lower in precedence than the top operator evaluate				
					
					if lowerPrecedence(currentOp,top(operatorStack)) then
						n:= top(intStack);
						pop(intStack);
						z:= top(intStack);
						pop(intStack);
						result:= operatorEval(n,z,top(operatorStack));
						pop(operatorStack);
						push(result,intStack);
						if currentOp /= rightp then
							push(currentOp,operatorStack);
						end if;
						hasPushed := true;
			
--If the current operator isn't lower in precedence, then add to stack.			
						
					elsif lowerPrecedence(currentOp,top(operatorStack)) = false and hasPushed = false then
						push(currentOp,operatorStack);
					end if;															
				end if;
				
--If the word is not an operator, add it to the number stack.				
				
			elsif isOperator(c.words(i)) = false then
				number:= Integer'Value(to_string(c.words(i),length(c.words(i)))(1..Length(c.words(i))));
				push(number,intStack);
			end if;
	end loop;
	
		pop(operatorStack); -- Get rid of the equals.
	
-- Loop section two. Evaluates the stacks to completion and returns a result.	
	
	while whileControl = false loop
			
-- If in the last loop, the stack was fully evaluated return the value of that.
			
			if length(intStack) = 1 then
				return top(intStack);
			end if;
			
-- Get rid of left parenthesis, don't try to use them in an evaluation.			
			
			if top(operatorStack) = leftp then
				pop(operatorStack);
			end if;
			
			n:= top(intStack); 
			pop(intStack); 
			z:= top(intStack); 
			pop(intStack);
			result:= operatorEval(n,z,top(operatorStack));
			push(result,intStack);
			pop(operatorStack);
			
--If there are no more operators left, or we have our answer, exit the loop.			
			
			if isEmpty(operatorStack) or length(intStack) = 1 then
				whileControl:= true;
			end if;
	end loop;

result:= (top(intStack));
return result;
	
end result;
		
end calcpkg;