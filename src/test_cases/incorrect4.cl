class Main inherits IO {
	main() : Object {{
		let n : Bool <- True in       -- Predifined Keyword name not specified correct. Expected "true" not "True" 
		out_string("Enter 1 no-");
		let if : Int <- in_int()in    -- Predifined Keyword name used as a variable name
		out_int(if);

	}};
};

--compilation error

--"incorrect4.cl", line 3: syntax error at or near TYPEID = True
--"incorrect4.cl", line 5: syntax error at or near IF
--"incorrect4.cl", line 6: syntax error at or near ')'
--Compilation halted due to lex and parse errors