# COOL Compiler - Parser #
> **Group 7, OM SITAPARA (CS16BTECH11036), HARSHIT PATEL (CS16BTECH11017)**

The project implements phase B of the COOL parser. We generate an AST here.

### The Code and Design
* We have added some specific rules for every grammar rule, mentioned in the COOL grammar.
* To complete the actions, all these rules invoke several classes and their member functions mentioned in AST.java file
* These invokations define the structure and layout for each node of our AST tree(which will be generated) and the specific properties of the nodes are assigned to it.
* The code CoolParser.g4 generates the AST tree for an input cool program, if the program is syntactically correct.
* If the code is incorrect, it will generate errrors.
* The parser matches the grammar rules for each construct of the input cool program and add the corresponding node to our AST.

#### Operator Precedence ####

Precedence rules according to cool language(followed by the parser rules writen) : 

	'.' ,  '@' , '~' , 'isvoid' , '* /'  ,  '+ -'  ,  ' <= < = '  ,  'not'  ,  '<-' 

### List Handling ##
There are several types of lists - 
* `class_list` : Complete program is referred as class_list, atleast one class is mandatory
* `feature_list`: A class is composed of features 
* `let_list`: It is compromised of a list of let commands(e.g. while taking inputs from user)
* `formal_list`: Each method invocation accepts a formal list.
* `block_expr_list` : List of blocks i.e. expressions(terminated by semicolon) in list
* `branch_list`: They contains construct like switch case etc.
* `expression_list` : It contains list of expressions



###  Test Cases Provided : 

We have provided with a bunch of working and erroneous programs which can be executed using :
    
    ./parser progname.cl
    
### Working Programs 

* calculator.cl - It demonstrates multiple rules like :

        program::= [[class; ]]+
        class::= ∗class TYPE [inherits TYPE] { [[feature; ]] }
        formal::=ID : TYPE
        expr::= ID <- expr
            |   expr + expr 
            |   expr − expr
            |   expr ∗ expr
            |   expr / expr
            |   expr < expr
            |   expr <= expr
            |   expr = expr
            |   (expr)
            |   ID
            |   let ID : TYPE [ <- expr ] [[, ID : TYPE [ <- expr ]]]∗ in expr
            |   { [[expr; ]]+ }
            |   if expr then expr else expr fi
        
* area.cl - It demonstrates the if-else expression rule :
    
        if expr then expr else expr fi
    
* reverseString.cl - It demonstrates the usage of loops in cool :

        while expr loop expr pool
        
### Erroneous Programs 

These incorrect programs demonstrates several parsing errors, which are mentioned in the code as comments.

* errorIfElse.cl - Incorrect usage of if-else statements
* incorrect4.cl - It shows the incorrect usage of predefined keywords
* incorrect5.cl - Incorrect usage of variable and keyword names.


