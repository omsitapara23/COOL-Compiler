class Main inherits IO {
	main() : Object {{ 
		out_string("Enter 1 no-");
		l et a : In t <- in_int()in    -- There should not be whitespaces between alphabets of variable and keyword name
		out_int(a);

	}};
};

--compilation error

--"incorrect5.cl", line 4: syntax error at or near OBJECTID = et
--Compilation halted due to lex and parse errors