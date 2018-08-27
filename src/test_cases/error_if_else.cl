class Main inherits IO {
    main() : Object {{
        out_string("Enter two numbers \n");
        let k : Int <- in_int() in 
        if 4 < k then out_string ("Wrong choice \n") fi;    --missing else statement
    }};

};

-- "error_if_else.cl", line 5: syntax error at or near FI