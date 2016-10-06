module servlib.dsp.HtmlIfParser;

import servlib.dsp.HtmlTagParser;
import servlib.utils.XMLoader;
import servlib.utils.lexer;
import servlib.control.Session;
import servlib.utils.Log;
import std.container, std.algorithm;

import std.conv;
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

    Constante opTest (Operator op, Expression right){
      return null;
    }    
    
    bool isTrue (Session session) {
      auto l = left.calcul();
      auto r = right.calcul();
      Log.instance.add_err(toString());
      if (l.opTest (op, r))
	return true;
      return false;
    }

    Constante calcul () {
      Constante left = left.calcul();
      Constante right = right.calcul();
      return null;
    }

    override string toString () {
      return "(" ~ ((left !is null) ? left.toString() : "null") ~ " , " ~ (op ! is null ? cast(string)op : "null") ~ " , " ~ (right !is null ? right.toString() : "null") ~ ")";
    }
    
  }

  class Constante : Expression {
    string val;

    override bool opEquals (Object other_) {
      Constante other = cast(Constante)other_;
      if (other !is null){	
	return val == other.val;
      }
      return false;
    }

    Constante opBinary (string s = "+") (Object obj) {
      return opPlus(obj);
    }

    Constante opPlus (Object obj) {
      auto obj_ = cast(Constante)obj;
      if(obj_ !is null){
	Constante newCnst = new Constante();
	newCnst.val = val ~ obj_.val;
	return newCnst;
      }
      return null;
    }

    override Constante calcul () {
      return this;
    }
    /*
    override string toString () {
      return val;
      }*/
  }
  
  class Int : Constante {    
    this (string val) {
      this.val = val;
    }

    override Constante opTest(Operator op, Expression right) {
      //Verifie this op right existe, retourne vrai si this op right != 0
      return null;
    }
    
    override Constante opPlus (Object obj) {
      auto obj_ = cast(Int)obj;
      if(obj_ !is null){
	int val_ = to!int(val) + to!int(obj_.val);
	return new Int(to!string(val_));
      }else{
	return null;
      }
    }
  }

  class Var : Constante {
    this (string val) {
      this.val = val;
    }
  }
  
  class Float : Constante {
    this (string val) {
      this.val = val;
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
    Log.instance.add_err("HtmlIf execute");
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
	Expression right = low (lex);
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
	Expression right = high (lex);
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
	Expression right = pth (lex);
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
	if (word.str != Operator.PARC) assert (false, "TODO, erreur de syntaxe");
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
