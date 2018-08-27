-- Trivial
-- This file demonstrates the if-else rule
-- if expr then expr else expr fi

class Main inherits IO {
	main() : Object {{
		out_string("Enter length and breadth to find the area of the rectangle\n");

		let length: Int <- in_int() in
		let breadth: Int <- in_int() in
			if length < 0 then
    			out_string("Error.. Area cannot be found.\n")
    		else if breadth < 0 then
    			out_string("Error.. Area cannot be found.\n")
    		else {
    			out_string("The area is ").out_int(area(length, breadth));
    			out_string("\n");
    		}
    		fi fi;
	}};

	area(num1:Int, num2:Int): Int{
		num1 * num2
	};
};