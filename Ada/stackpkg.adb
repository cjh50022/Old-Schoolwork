-- Chris Hill 

package body StackPkg is

    function IsEmpty (s : Stack) return Boolean is
    begin
        return s.Top = 0;
    end IsEmpty;

    function IsFull (s : Stack) return Boolean is
    begin
        return s.Top = MaxSize;
    end IsFull;

    function top  (s : Stack) return ItemType is
    begin
        return s.Elements(s.Top);
    end Top;
	
	function length (s:Stack) return Integer is 
		begin
			return s.Top;
		end length;

    procedure push (item : ItemType; s : in out Stack) is
    begin
		s.Top := s.Top + 1;
		s.Elements(s.Top) := item;
    end Push;

    procedure pop  (S : in out Stack) is
    begin
		S.Top := S.Top - 1;      
    end Pop;

end StackPkg;