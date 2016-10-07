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

    Constante opTest (Operator op, Expression right){
      switch(op){
      case Operator.PLUS:
	return getValue().opPlus(right.getValue());
      case Operator.SUB:
	return getValue().opSub(right.getValue());
      default:
	return null;
      }
    }    
    
    bool isTrue (Session session) {
      string leftVal = left.getValue().val;
      string rightVal = right.getValue().val;
      writeln("result: " ~ leftVal ~ " " ~ cast(string) op ~ " " ~ rightVal);
      switch(op){
      case Operator.EQUAL:
	return leftVal == rightVal;	
      case Operator.NOTEQ:	
	return leftVal != rightVal;
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

    Constante opPlus(Constante other){
      Constante cnst = new Constante();
      cnst.val = val ~ other.val;
      return cnst;
    }

    Constante opSub(Constante other){
      return null;
    }
    
    override Constante getValue() {
      return this;
    }
  }
  
  class Int : Constante {    
    this (string val) {
      this.val = val;
    }
    
    override Constante opPlus(Constante other){
      Int myInt = cast(Int)other;
      if(myInt !is null){
	int res = to!int(val)+to!int(myInt.val);
	return new Int(to!string(res));
      }else{
	Float myFloat = cast(Float)other;
	if(myFloat !is null){
	  float res = to!int(val)+to!float(myFloat.val);
	  return new Float(to!string(res));
	}
      }
      return null;      
    }

    override Constante opSub (Constante other) {
      Int myInt = cast(Int) other;
      if (myInt !is null) {
	int res = to!int (val) - to!int (myInt.val);
	return new Int (to!string (res));
      } else {
	Float myFloat = cast(Float) other;
	if (myFloat !is null) {
	  float res = to!int (val) - to!float (myFloat.val);
	  return new Float (to!string (res));
	}
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

    
    override bool isTrue (Session session) {
      return to!bool (val);
    }
  }
  
  class Float : Constante {
    this (string val) {
      this.val = val;
    }
    
    override Constante opPlus (Constante other) {
      Float myFloat = cast(Float) other;
      if (myFloat !is null) {
	float res = to!float (val) + to!float (myFloat.val);
	return new Float (to!string (res));
      } else {
	Int myInt = cast(Int) other;
	if (myInt !is null) {
	  float res = to!float (val) + to!int (myInt.val);
	  return new Float (to!string (res));
	}
      }
      return null;
    }
    
    override Constante opSub (Constante other) {
      Float myFloat = cast(Float) other;
      if (myFloat !is null) {
	float res = to!float (val) - to!float (myFloat.val);
	return new Float (to!string (res));
      } else {
	Int myInt = cast(Int) other;
	if (myInt !is null) {
	  float res = to!float (val) - to!int (myInt.val);
	  return new Float (to!string (res));
	}
      }
      return null;      
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
