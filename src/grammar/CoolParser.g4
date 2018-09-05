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
program returns [AST.program value] : 
            cl=class_list EOF 
                {
                    $value = new AST.program($cl.class_list_value, $cl.class_list_value.get(0).lineNo);
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
	feature ::= ID( [formal [[,formal]]∗ ] ) : TYPE { curr_expr }
			| ID : TYPE [<- curr_expr]
*/
feature returns [AST.feature feature_value] :

		/* feature = ID( [formal [[,formal]]∗ ] ) : TYPE { curr_expr } */
        func = method 
        {
            $feature_value = $func.value;
        }
		
		/* feature = ID : TYPE [<- curr_expr] */
        | var = attr
        {
            $feature_value = $var.value;
        }
        ;

attr returns [AST.attr value] :

		/* attr = ID : TYPE */
        id = OBJECTID COLON type = TYPEID
        {
            $value = new AST.attr($id.getText(), $type.getText(), new AST.no_expr($id.getLine()), $id.getLine());
        }

		/* attr = ID : TYPE [<- curr_expr] */
        | id = OBJECTID COLON type = TYPEID ASSIGN curr_expr = expression
        {
            $value = new AST.attr($id.getText(), $type.getText(), $curr_expr.value, $id.getLine()); 
        }
        ;

method returns [AST.method value] :

		/* feature = ID( ) : TYPE { curr_expr } */
        id=OBJECTID LPAREN RPAREN COLON type=TYPEID LBRACE curr_expr=expression RBRACE
        {
            $value = new AST.method($id.getText(), new ArrayList<AST.formal>(), $type.getText(), $curr_expr.value, $id.getLine());
        }

		/* feature = ID( [formal [[,formal]]∗ ] ) : TYPE { curr_expr } */
        | id=OBJECTID LPAREN fr_list=formal_list RPAREN COLON type=TYPEID LBRACE curr_expr=expression RBRACE
        {
            $value = new AST.method($id.getText(), $fr_list.value, $type.getText(), $curr_expr.value, $id.getLine());
        }
        ;


/* formal_list = [formal [[,formal]]∗ ] */
formal_list returns [ArrayList<AST.formal> value]

        @init
        {
            $value = new ArrayList<AST.formal>();
        }
        :
            c = formal 
				{ 
					$value.add($c.value);
				}

            (COMMA y = formal 
				{
					$value.add($y.value);
				}
			)*
        ;


/* formal = ID : TYPE */
formal returns [AST.formal value]  :

        id = OBJECTID COLON type = TYPEID
        {
            $value = new AST.formal($id.getText(), $type.getText(), $id.getLine());

        }
        ;

/* expression_list = [ curr_expr [[,curr_expr]]∗ ] */
expression_list returns [ArrayList<AST.expression> value] 

        @init
        {
            $value = new ArrayList<AST.expression>();
        }
        :

            (curr_expr = expression 
				{
					$value.add($curr_expr.value);
				} 
				(COMMA curr_expr = expression 
					{ 
						$value.add($curr_expr.value);
					}
				)*
			)?
        
        ;


/* block_expr_list = { [[curr_expr; ]]+ } */
block_expr_list returns [ArrayList<AST.expression> value]

        @init
        {
            $value = new ArrayList<AST.expression>();
        }
        :
            (curr_expr = expression SEMICOLON 
				{ 
					$value.add($curr_expr.value);
				}
			)+
        ;

/* branch_list = { [[ branch; ]]+ } */
branch_list returns [ArrayList<AST.branch> value]
    @init
    {
        $value = new ArrayList<AST.branch>();   
    }
    :
        (br = branch SEMICOLON 
				{
					$value.add($br.value);
				}
		)+
    ;

/* branch = ID:TYPE => curr_expr;  */
branch returns [AST.branch value]:
    id = OBJECTID COLON type=TYPEID DARROW curr_expr=expression SEMICOLON
    {
        $value = new AST.branch($id.getText(), $type.getText(), $curr_expr.value, $id.getLine());
    }
    ; 

/* let_list = { TYPE [<-curr_expr] [[, ID:TYPE [ <- curr_expr ]]]∗ } */
let_list returns [ArrayList<AST.attr> value]
    @init
    {
        $value = new ArrayList<AST.attr>();
    }
    :
    attr_un = attr 
		{
			$value.add($attr_un.value);
		}
    (COMMA attr_deux = attr 
			{
				$value.add($attr_deux.value);
			}
	)*
    ;


expression returns [AST.expression value]   :
	/*curr_expr.ID([curr_expr [[, curr_expr]]* ]) */
	curr_expr=expression DOT id=OBJECTID LPAREN expr_list = expression_list RPAREN
	{
		$value = new AST.dispatch($curr_expr.value, $id.getText(), $expr_list.value, $curr_expr.value.lineNo);
	}
	/*curr_expr[@TYPE].ID([curr_expr [[, curr_expr]]* ]) */
	| curr_expr=expression ATSYM type=TYPEID DOT id=OBJECTID LPAREN expr_list = expression_list RPAREN
	{
		$value = new AST.static_dispatch($curr_expr.value, $type.getText(), $id.getText(), $expr_list.value, $curr_expr.value.lineNo);
	}
	/*ID ( [curr_expr [[, curr_expr]]* ]) */
	| id=OBJECTID LPAREN expr_list = expression_list RPAREN
	{
		$value = new AST.dispatch(new AST.object("self" , $id.getLine()) , $id.getText() , $expr_list.value , $id.getLine()); 
	}
	/* ~ curr_expr */
	| st=TILDE expression_1=expression
		{
			$value = new AST.comp($expression_1.value, $st.getLine());
		}
	/* isvoid curr_expr */
	| st=ISVOID curr_expr=expression
		{
			$value = new AST.isvoid($curr_expr.value, $st.getLine());
		}
	/* curr_expr * curr_expr */
	| expression_1=expression STAR expression_2=expression
		{
			$value = new AST.mul($expression_1.value, $expression_2.value, $expression_1.value.lineNo);
		}
	/* curr_expr / curr_expr */
	| expression_1=expression SLASH expression_2=expression
		{
			$value = new AST.divide($expression_1.value, $expression_2.value, $expression_1.value.lineNo);
		}
	/* curr_expr + curr_expr */
	| expression_1=expression PLUS expression_2=expression
		{
			$value = new AST.plus($expression_1.value, $expression_2.value, $expression_1.value.lineNo);
		}
	/* curr_expr - curr_expr */
	| expression_1=expression MINUS expression_2=expression
		{
			$value = new AST.sub($expression_1.value, $expression_2.value, $expression_1.value.lineNo);
		}
	/* curr_expr < curr_expr */
	| expression_1=expression LT expression_2=expression
		{
			$value = new AST.lt($expression_1.value, $expression_2.value, $expression_1.value.lineNo);
		}
	/* curr_expr <= curr_expr */
	| expression_1=expression LE expression_2=expression
		{
			$value = new AST.leq($expression_1.value, $expression_2.value, $expression_1.value.lineNo);
		}
	/* curr_expr = curr_expr */
	| expression_1=expression EQUALS expression_2=expression
		{
			$value = new AST.eq($expression_1.value, $expression_2.value, $expression_1.value.lineNo);
		}
	/* not curr_expr */
	| st=NOT expression_1=expression
		{
			$value = new AST.neg($expression_1.value, $st.getLine());
		}
	/* ID <- curr_expr */
	| id=OBJECTID ASSIGN curr_expr=expression
		{
			$value = new AST.assign($id.getText(), $curr_expr.value, $id.getLine());  
		}
	/* if curr_expr then curr_expr else curr_expr fi*/
	| st=IF predicate=expression THEN ifbody=expression ELSE elsebody=expression FI 
		{
			$value = new AST.cond($predicate.value, $ifbody.value, $elsebody.value, $st.getLine());
		}
	/* while curr_expr loop curr_expr pool */
	| st=WHILE predicate=expression LOOP body=expression POOL
		{
			$value = new AST.loop($predicate.value, $body.value, $st.getLine());
		}
	/* { [[curr_expr]]* } */
	| st=LBRACE el=block_expr_list RBRACE	// define
		{
			$value = new AST.block($el.value, $st.getLine());
		}
	/* let ID:TYPE [[, ID : TYPE [<- curr_expr]]]* in curr_expr */
	| st=LET ll=let_list IN expression_1=expression
	{
		$value = $expression_1.value; 
		AST.attr this_attr;
		for(int i = $ll.value.size() - 1; i >= 0; --i) 
		{
			this_attr = $ll.value.get(i);
			$value = new AST.let(this_attr.name, this_attr.typeid, this_attr.value, $value, $st.getLine());
		}
	}

	/* expression = case curr_expr of [[ID : TYPE => curr_expr; ]]+ esac   */
	/* branch_list = [[ID : TYPE => curr_expr; ]]+   */
    | st = CASE predicate = expression OF b1 = branch_list ESAC
    {
        $value = new AST.typcase($predicate.value, $b1.value, $st.getLine());
    }

	/* expression = new TYPE */
    | st = NEW type = TYPEID
    {
        $value = new AST.new_($type.getText(), $st.getLine());
    }

	/* expression = (curr_expr) */
    | st = LPAREN expression_1 = expression RPAREN
    {
        $value = $expression_1.value;
    }

	/* expression = ID */
    | id = OBJECTID
    {
        $value = new AST.object($id.getText(), $id.getLine());
    }

	/* expression = integer */
    | intv = INT_CONST
    {
        $value = new AST.int_const(Integer.parseInt($intv.getText()), $intv.getLine());
    }

	/* expression = string */
    | strv = STR_CONST
    {
        $value = new AST.string_const($strv.getText(), $strv.getLine());
    }

	/* expression = true/false */
    | boolv = BOOL_CONST
    {
        $value = new AST.bool_const($boolv.getText().charAt(0)=='t', $boolv.getLine());
    }

;