module servlib.dsp.HtmlIfParser;

import servlib.dsp.HtmlTagParser;
import servlib.utils.xml;
import servlib.utils.lexer;
import servlib.control.Session;
import servlib.utils.Log;
import std.container, std.algorithm;

import std.conv, std.stdio;
import std.container, std.traits;

class HtmlIfParser : HtmlInHerit ! ("dsp:if", HtmlIfParser) {

  class Expression {
    Expression left, right;
    Operator op;    

    this () {}
    
    this (Operator op, Expression left, Expression right) {
      this.op = op;
      this.left = left;
      this.right = right;
    }

    Constante getValue (){
      return left.opTest(op,right);
    }

    Constante opTest (Operator op, Expression right) {
      switch (op) {
      case Operator.PLUS:
	return getValue().opPlus(right.getValue());
      case Operator.SUB:	
	return getValue().opSub(right.getValue());
      case Operator.MUL:	
	return getValue().opMul(right.getValue());
      case Operator.DIV:	
	return getValue().opDiv(right.getValue());
      default:
	assert (false,"Fatal Erreur opTest, Operation Not Defined " ~ cast(string) op);
      }
    }    
    
    bool isTrue (Session session) {
      Constante leftVal = left.getValue();
      Constante rightVal = right.getValue();
      writeln("result: " ~ leftVal.val ~ " " ~ cast(string) op ~ " " ~ rightVal.val);
      switch(op){
      case Operator.EQUAL:
	return leftVal.val == rightVal.val;	
      case Operator.NOTEQ:	
	return leftVal.val != rightVal.val;
      case Operator.INF:
	return leftVal.opInf (rightVal).isTrue(session);
      case Operator.SUP:        
	return leftVal.opSup (rightVal).isTrue(session);
      default:
	return false;
      }
    }

    override string toString () {
      return "(" ~ ((left !is null) ? left.toString() : "null") ~ " , " ~ (op ! is null ? cast(string)op : "null") ~ " , " ~ (right !is null ? right.toString() : "null") ~ ")";
    }
    
  }

  class Constante : Expression {
    string val;

    this(){}

    this(string val){
      this.val = val;
    }

    Constante opPlus (Constante other){
      return new Constante(val ~ other.val);
    }

    Constante opSub (Constante other){      
       assert (false,"Fatal Erreur Constance opSub, Operation Not Defined ");
    }

    Constante opMul (Constante other){      
	assert (false,"Fatal Erreur Constance opMul, Operation Not Defined ");
    }

    Constante opDiv (Constante other){      
	assert (false,"Fatal Erreur Constance opDiv, Operation Not Defined ");
    }

    Constante opSup (Constante other){      
	assert (false,"Fatal Erreur Constance opSup, Operation Not Defined ");
    }

    Constante opInf (Constante other){      
	assert (false,"Fatal Erreur Constance opInf, Operation Not Defined ");
    }
    
    override Constante getValue() {
      return this;
    }
  }
  
  class Int : Constante {    
    this (string val) {
      this.val = val;
    }

    this(int val){
      this.val = to!string(val);
    }

    override Constante opPlus (Constante other) {
      if (auto t = cast(Int) other) {
	return new Int (to!int (val) + to!int (t.val));
      } else if (auto t = cast(Float) other) {	
	return new Float (to!int (val) + to!float (t.val));
      }
      return null;
    }

    override Constante opSub (Constante other) {
      if(auto t = cast(Int) other){
	return new Int (to!int (val) - to!int (t.val));
      }else if(auto t = cast(Float)other){	
	return new Float (to!int (val) - to!float (t.val));
      }
      return null;
    }

    override Constante opMul (Constante other) {
      if (auto t = cast(Int) other) {
	return new Int (to!int (val) * to!int (t.val));
      } else if (auto t = cast(Float)other) {	
	return new Float (to!int (val) * to!float (t.val));
      }
      return null;
    }

    override Constante opDiv (Constante other) {
      if (auto t = cast(Int) other) {
	return new Int (to!int (val) / to!int (t.val));
      } else if (auto t = cast(Float) other) {	
	return new Float (to!int (val) / to!float (t.val));
      }
      return null;
    }

    override Constante opSup (Constante other) {
      if (auto t = cast(Int) other) {
	return new Bool (to!int (val) > to!int (t.val));
      } else if (auto t = cast(Float) other) {	
	return new Bool (to!int (val) > to!float (t.val));
      }
      return null;
    }

    override Constante opInf (Constante other) {
      if (auto t = cast(Int) other) {
	return new Bool (to!int (val) < to!int (t.val));
      } else if (auto t = cast(Float) other) {	
	return new Bool (to!int (val) < to!float (t.val));
      }
      return null;
    }
    
  }

  class Var : Constante {
    this (string val) {
      this.val = val;
    }
  }

  class Bool : Constante {
    this (string val) {
      this.val = val;
    }

    this(bool val){
      this.val = to!string(val);
    }

    override Constante opPlus (Constante other){
       assert (false,"Fatal Erreur Bool opPlus, Operation Not Defined ");
    }

    override Constante opSub (Constante other){      
       assert (false,"Fatal Erreur Bool opSub, Operation Not Defined ");
    }

    override Constante opMul (Constante other){      
	assert (false,"Fatal Erreur Bool opMul, Operation Not Defined ");
    }

    override Constante opDiv (Constante other){      
	assert (false,"Fatal Erreur Bool opDiv, Operation Not Defined ");
    }

    override Constante opSup (Constante other){      
	assert (false,"Fatal Erreur Bool opSup, Operation Not Defined ");
    }

    override Constante opInf (Constante other){      
	assert (false,"Fatal Erreur Bool opInf, Operation Not Defined ");
    }
    
    override bool isTrue (Session session) {
      return to!bool (val);
    }
  }
  
  class Float : Constante {
    this (string val) {
      this.val = val;
    }

    this (float val) {
      this.val = to!string(val);
    }
    
    override Constante opPlus (Constante other) {
      if (auto t = cast(Float) other) {
	return new Float (to!float (val) + to!float (t.val));
      } else if (auto t = cast(Int) other) {	
	return new Float (to!float (val) + to!int (t.val));
      }
      assert (false,"Fatal Erreur Float opPlus, NullValue or Type Not Supported ");
    }

    override Constante opSub (Constante other) {
      if (auto t = cast(Float) other) {
	return new Float (to!float (val) - to!float (t.val));
      } else if (auto t = cast(Int) other) {	
	return new Float (to!float (val) - to!int (t.val));
      }
      assert (false,"Fatal Erreur Float opSub, NullValue or Type Not Supported ");
    }

    override Constante opMul (Constante other) {
      if (auto t = cast(Float) other) {
	return new Float (to!float (val) * to!float (t.val));
      } else if (auto t = cast(Int) other) {	
	return new Float (to!float (val) * to!int (t.val));
      }
      assert (false,"Fatal Erreur Float opMul, NullValue or Type Not Supported ");
    }

    override Constante opDiv (Constante other) {
      if (auto t = cast(Float) other) {
	return new Float (to!float (val) / to!float (t.val));
      } else if (auto t = cast(Int) other) {	
	return new Float (to!float (val) / to!int (t.val));
      }
      assert (false,"Fatal Erreur Float opDiv, NullValue or Type Not Supported ");
    }

        override Constante opSup (Constante other) {
      if (auto t = cast(Float) other) {
	return new Bool (to!float (val) > to!float (t.val));
      } else if (auto t = cast(Int) other) {	
	return new Bool (to!float (val) > to!int (t.val));
      }
      assert (false,"Fatal Erreur Float opSup, NullValue or Type Not Supported ");
    }

    override Constante opInf (Constante other) {
      if (auto t = cast(Float) other) {
	return new Bool (to!float (val) < to!float (t.val));
      } else if (auto t = cast(Int) other) {	
	return new Bool (to!float (val) < to!int (t.val));
      }
      assert (false,"Fatal Erreur Float opInf, NullValue or Type Not Supported ");
    }
  }


  enum Operator:string{
    PLUS = "+",
      SUB = "-",

      MUL = "*",
      DIV = "/",
      
      OR = "||",
      AND = "&&",
      EQUAL = "==",
      NOTEQ = "!=",
      INF = "<",
      SUP = ">",
      SUP_E = ">=",
      INF_E = "<=",
      PARO = "(",
      PARC = ")"      
  }
  
  override Balise[] execute (Balise element, Balise[] function (Balise, Session) callBack, Session session) {
    Log.instance.addInfo("HtmlIf execute");
    auto it = element["test"];
    if (it !is null){
      LexerString lex = new LexerString (it);
      lex.setKeys(make!(Array!string)(EnumMembers!Operator, " "));
      lex.setSkip(make!(Array!string)([" "]));
      Expression exp = expression (lex);
      if (exp.isTrue (session)) {
	Balise [] total ;
	foreach (itch ; element.childs) {
	  auto ret = callBack (itch, session);
	  total ~= ret;
	}
	return total;
      } else
	return [];
    } else {
      //TODO throw
      assert (false, "TODO, throw syntax");
    }
  }

  private {

    Expression expression (LexerString lex) {
      Word word;
      Expression left = low (lex);
      lex.getNext (word);
      auto op = find ([Operator.AND, Operator.OR, Operator.EQUAL, Operator.NOTEQ, Operator.SUP, Operator.INF, Operator.SUP_E, Operator.INF_E], word.str);
      if (op != []) {
	Expression right = expression (lex);
	return new Expression (op[0], left, right);
      } else {
	lex.rewind ();
	return left;
      }
    }
    
    Expression low (LexerString lex) {
      Word word;
      Expression left = high (lex);
      lex.getNext (word);
      auto op = find ([Operator.PLUS, Operator.SUB], word.str);
      if (op != []) {
	Expression right = low (lex);
	return new Expression (op[0], left, right);
      } else {
	lex.rewind ();
	return left;
      }
    }

    Expression high (LexerString lex) {
      Word word;
      Expression left = pth (lex);
      lex.getNext (word);
      auto op = find ([Operator.MUL, Operator.DIV], word.str);
      if (op != []) {
	Expression right = high (lex);
	return new Expression (op[0], left, right);
      } else {
	lex.rewind ();
	return left;
      }
    }

    Expression pth (LexerString lex) {
      Word word;
      lex.getNext (word);
      if (word.str == Operator.PARO) {
	Expression exp = expression (lex);
	lex.getNext (word);
	if (word.str != Operator.PARC) assert (false, "TODO, erreur de syntaxe " ~ word.str );
	return exp;
      } else {
	lex.rewind ();
	return constante (lex);	
      }
    }

    Constante constante (LexerString lex) {
      Word word;
      lex.getNext (word);
      if (word.str.length > 0 && word.str[0] >= '0'
	  && word.str[0] <= '9')
	return numeric (lex, word);
      else {
	return new Var (word.str);
      }
    }

    Constante numeric (LexerString lex, Word word) {
      bool dot = false;
      foreach (it ; word.str) {
	if (it == '.') {
	  if (dot) assert (false, "TODO, erreur de syntaxe");
	  else dot = true;	      
	} else if (it < '0' || it > '9')
	  assert (false, "TODO, erreur de syntaxe " ~ it);
      }
      
      if (dot) return new Float (word.str);
      else return new Int (word.str);	      
    }
    
  }
}
