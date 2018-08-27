-- Trivial

-- This code checks rule named
-- while expr loop expr pool

class Main inherits IO{
	main(): Object {{
		out_string("Enter a string to reverse ");
		let str : String <- in_string() in
		
		let rev : String <- "" in
		let i : Int <- str.length() - 1 in
		let j : Int <- str.length() - 2 in

		(while 0 <= i loop
		{
			out_string(str.substr(i,1));
			i <- i-1;
		}
		pool
		);
		out_string("\n");
	}};

	
	
	
};