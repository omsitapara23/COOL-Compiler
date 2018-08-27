parser grammar CoolParser;

options {
    tokenVocab = CoolLexer;
}

@header{
    import java.util.List;
}

@members{
    String filename;
    public void setFilename(String f){
        filename = f;
    }

/*
    DO NOT EDIT THE FILE ABOVE THIS LINE
    Add member functions, variables below.
*/

}

/*
    Add appropriate actions to grammar rules for building AST below.
*/

/*
 	program = [[class;]]+
	program is a class_list
*/
program returns [AST.program program_value] : 
            cl=class_list EOF 
                {
                    $program_value = new AST.program($cl.class_list_value, $cl.class_list_value.get(0).lineNo);
                }
        ;

/*
	class_list = [[class]]+
	An array list of classes.
	To declare an arrayList first we need to inititalize it using @init
 */
class_list returns [ArrayList<AST.class_> class_list_value]
        @init 
        {
            $class_list_value = new ArrayList<AST.class_>();
        }
        :
            (c = class_ SEMICOLON 
                {
                    $class_list_value.add($c.class_value);
                }
            )+
        ;


/* class = class TYPE [inherits TYPE] { [[feature; ]]∗ } */
class_ returns [AST.class_ class_value] :

		/* class = class TYPE { [[feature;]]* } */
        st = CLASS type = TYPEID LBRACE fl = feature_list RBRACE
        {
            $class_value = new AST.class_($type.getText(), filename, "Object", $feature_list.feature_list_value, $st.getLine());
        }

		/* class = class TYPE [inherits TYPE] { [[feature;]]* }  */
        | st = CLASS type = TYPEID INHERITS p_type = TYPEID LBRACE fl = feature_list RBRACE

        {
            $class_value = new AST.class_($type.getText(), filename, $p_type.getText(), $feature_list.feature_list_value, $st.getLine());
        }
        ;


/* feature_list = [[feature]]+ */
feature_list returns [ArrayList<AST.feature> feature_list_value]

        @init
        {
            $feature_list_value = new ArrayList<AST.feature>();
        }
        :
            (c = feature SEMICOLON
                {
                    $feature_list_value.add($c.feature_value);
                }
            )*
        ;

/*
	feature ::= ID( [formal [[,formal]]∗ ] ) : TYPE { expr }
			| ID : TYPE [<- expr]
*/
feature returns [AST.feature feature_value] :

		/* feature = ID( [formal [[,formal]]∗ ] ) : TYPE { expr } */
        func = method 
        {
            $feature_value = $func.method_value;
        }
		
		/* feature = ID : TYPE [<- expr] */
        | var = attr
        {
            $feature_value = $var.attr_value
        }
        ;

attr returns [AST.attr attr_value] :

		/* attr = ID : TYPE */
        id = OBJECTID COLON type = TYPEID
        {
            $attr_value = new AST.attr($id.getText(), $type.getText(), new AST.no_expr($id.getLine()), $id.getLine());
        }

		/* attr = ID : TYPE [<- expr] */
        | id = OBJECTID COLON type = TYPEID ASSIGN expr = expression
        {
            $attr_value = new AST.attr($id.getText(), $type.getText(), $expr.expression_value, $id.getLine()); 
        }
        ;

method returns [AST.method method_value] :

		/* feature = ID( ) : TYPE { expr } */
        id=OBJECTID LPAREN RPAREN COLON type=TYPEID LBRACE expr=expression RBRACE
        {
            $method_value = new AST.method($id.getText(), new ArrayList<AST.formal>(), $type.getText(), $expr.expression_value, $id.getLine());
        }

		/* feature = ID( [formal [[,formal]]∗ ] ) : TYPE { expr } */
        | id=OBJECTID LPAREN fr_list=formal_list RPAREN COLON type=TYPEID LBRACE expr=expression RBRACE
        {
            $method_value = AST.method($id.getText(), $fr_list.formal_list_value, $type.getText(), $expr.expression_value, $id.getLine());
        }
        ;


/* formal_list = [formal [[,formal]]∗ ] */
formal_list returns [ArrayList<AST.formal> formal_list_value]

        @init
        {
            $formal_list_value = new ArrayList<AST.formal>();
        }
        :
            fm = formal 
            {
                $formal_list_value.add($fm.formal_value);
            }

            (COMMA fml = formal 
                {
                    $formal_list_value.add($fml.formal_value);
                }
            )*
        ;


/* formal = ID : TYPE */
formal returns [AST.formal formal_value]  :

        id = OBJECTID COLON type = TYPEID
        {
            $formal_value = new AST.formal($id.getText(), $type.getText(), $id.getText());

        }
        ;

/* expression_list = [ expr [[,expr]]∗ ] */
expression_list returns [ArrayList<AST.expression> expression_list_value] 

        @init
        {
            $expression_list_value = new ArrayList<AST.expression>();
        }
        :

            (expr = expression 
                {
                    $expression_list_value.add($expr.expression_value);
                }

                (COMMA expr = expression 
                    {
                        $expression_list_value.add($expr.expression_value);
                    }
                )*
            )?
        
        ;


/* block_expr_list = { [[expr; ]]+ } */
block_expr_list returns [ArrayList<AST.expression> block_expr_list_value]

        @init
        {
            $block_expr_list_value = new ArrayList<AST.expression>();
        }
        :
            (expr = expression SEMICOLON 
                {
                    block_expr_list_value.add($expr.expression_value);
                }
            )+
        ;

/* branch_list = { [[ branch; ]]+ } */
branch_list returns [ArrayList<AST.branch> branch_list_value]
    @init
    {
        $branch_list_value = new ArrayList<AST.branch>();   
    }
    :
        (br = branch SEMICOLON 
            {
                $value,add($br.branch_value);
            }
        )+
    ;

/* branch = ID:TYPE => expr;  */
branch returns [AST.branch branch_value]:
    id = OBJECTID COLON type=TYPEID DARROW expr=expression SEMICOLON
    {
        $branch_value = new AST.branch($id.getText(), $type.getText(), $expr.expression_value, $id.getLine());
    }
    ; 

/* let_list = { TYPE [<-expr] [[, ID:TYPE [ <- expr ]]]∗ } */
let_list returns [ArrayList<AST.attr> let_list_value]
    @init
    {
        $let_list_value = new ArrayList<AST.attr>();
    }
    :
    at_un = attr
    {
          $let_list_value.add($at_un.attr_value);
    }
    (COMMA at_deux = attr 
        {
            $let_list_value.add($at_deux.attr_value);
        }
    )*
    ;


expression returns [AST.expression expression_value]:

	/* expression =  expr.ID( [ expr [[, expr]]∗ ])  */
    expr = expression DOT id = OBJECTID LPAREN expr_list = expression_list RPAREN
    {
        $expression_value  = new AST.dispatch($expr.expression_value, $id.getText(), $expr_list.expression_list_value, $expr.expression_value.lineNo);
    }

	/* expression =  expr[@TYPE].ID( [ expr [[, expr]]∗ ])  */
    | expr = expression ATSYM type = TYPEID DOT id = OBJECTID LPAREN expr_list = expression_list RPAREN
    {
        $expression_value = new AST.dispatch(new AST.object("self", $id.getLine(), $id.getText(), $expr_list.expression_list_value, $id.getLine()))
    } 

	/* expression = ~expr */
    | st = TILDE e1 = expression
    {
        $expression_value = new AST.comp($e1.expression_value, $st.getLine());
    }

	/* expression = isvoid expr */
    | st = ISVOID expr=expression
    {
        $expression_value = new AST.isvoid($expr.expresssion_value, $st.getLine());
    }

	/* expression = expr * expr  */
    | e1 = expression STAR e2 = expression
    {
        $expression_value = new AST.mul($e1.expresssion_value, $e2.expresssion_value, $e1.expresssion_value.lineNo);
    }

	/* expression = expr / expr  */
    | e1 = expression SLASH e2 = expression
    {
        $expression_value = new AST.divide($e1.expresssion_value, $e2.expresssion_value, $e1.expresssion_value.lineNo);
    }

	/* expression = expr + expr  */
    | e1 = expression PLUS e2 = expression
    {
        $expression_value = new AST.plus($e1.expresssion_value, $e2.expresssion_value, $e1.expresssion_value.lineNo);
    }

	/* expression = expr - expr  */
    | e1 = expression MINUS e2 = expression
    {
        $expression_value = new AST.sub($e1.expresssion_value, $e2.expresssion_value, $e1.expresssion_value.lineNo);
    }

	/* expression = expr < expr  */
    | e1 = expression LT e2 = expression
    {
        $expression_value = new AST.lt($e1.expresssion_value, $e2.expresssion_value, $e1.expresssion_value.lineNo);
    }

	/* expression = expr <= expr  */
    | e1 = expression LE e2 = expression
    {
        $expression_value = new AST.leq($e1.expresssion_value, $e2.expresssion_value, $e1.expresssion_value.lineNo);
    }

	/* expression = expr = expr  */
    | e1 = expression EQUALS e2 = expression
    {
        $expression_value = new AST.eq($e1.expresssion_value, $e2.expresssion_value, $e1.expresssion_value.lineNo);
    }

	/* expression = not expr */
    | st = NOT e1 = expression
    {
        $expression_value = new AST.neg($e1.expresssion_value, $st.getLine());
    }

	/* expression = ID <- expr */
    | id = OBJECTID ASSIGN expr = expression
    {
        $expression_value = new AST.assign($id.getText(), $expr.expresssion_value, $id.getLine());
    }

	/* expression = if expr then expr else expr fi */
    | st = IF predicate = expression THEN ifbody = expression ELSE elsebody = expression FI
    {
        $expression_value = new AST.cond($predicate.expresssion_value, $ifbody.expresssion_value, $elsebody.expresssion_value, $st.getLine());
    }

	/* expression = while expr loop expr pool */
    | st = WHILE predicate = expression LOOP body = expression POOL
    {
        $expression_value = new AST.loop($predicate.expresssion_value, $body.expresssion_value, $st.getLine());
    }

	/* expression = let ID : TYPE [ <- expr ] [[, ID : TYPE [ <- expr ]]]∗ in expr */
	/* let_list = ID : TYPE [ <- expr ] [[, ID : TYPE [ <- expr ]]]∗   */
    | st = LET ll=let_list IN e1 = expression
    {
        $expression_value = $e1.expresssion_value;
        AST.attr this_attr;
        for(int i = $ll.let_list_value.size()-1, i>=0; --i)
        {
            this_attr = $ll.let_list_value.get(i);
            $expression_value = new AST.let(this_attr.name, this_attr.typeid, this_attr.attr_value, $expression_value, $st.getLine());
        }
    }

	/* expression = case expr of [[ID : TYPE => expr; ]]+ esac   */
	/* branch_list = [[ID : TYPE => expr; ]]+   */
    | st = CASE predicate = expression OF b1 = branch_list ESAC
    {
        $expression_value = new AST.typcase($predicate.expresssion_value, $b1.branch_list_value, $st.getLine());
    }

	/* expression = new TYPE */
    | st = NEW type = TYPEID
    {
        $expression_value = new AST.new_($type.getText(), $st.getLine());
    }

	/* expression = (expr) */
    | st = LPAREN e1 = expression RPAREN
    {
        $expression_value = $e1.expresssion_value;
    }

	/* expression = ID */
    | id = OBJECTID
    {
        $expression_value = new AST.object($id.getText(), $id.getLine());
    }

	/* expression = integer */
    | intv = INT_CONST
    {
        $expression_value = new AST.int_const(Integer.parseInt($intv.getText()), $intv.getLine());
    }

	/* expression = string */
    | strv = STR_CONST
    {
        $expression_value = new AST.string_const($intv.getText(), $intv.getLine());
    }

	/* expression = true/false */
    | boolv = BOOL_CONST
    {
        $expression_value = new AST.bool_const($intv.getText().charAt(0)=='t', $intv.getLine());
    }

    ;