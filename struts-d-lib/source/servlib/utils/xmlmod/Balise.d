module servlib.utils.xmlmod.Balise;
import servlib.utils.xml;
import std.container, std.outbuffer, std.string;

class Balise {
    
    this (Identifiant name) {
	this.name = name;
    }

    this (Identifiant name, string [Identifiant] attrs) {
	this.name = name;
	this.attrs = attrs;
    }

    this (Identifiant name, Array!Balise childs) {
	this.name = name;
	this.childs = childs;
    }

    this (Identifiant name, string [Identifiant] attrs, Array!Balise childs) {
	this.name = name;
	this.attrs = attrs;
	this.childs = childs;
    }    
    
    string getValue() { return ""; }

    string opIndex (string name) {
	foreach (key, value; attrs)
	    if (key.name == name) return value;
	return null;
    }

    Balise clone(){
	return new Balise(this.name.clone,this.attrs.dup,this.childs.dup);
    }
        
    string toStr (int nb = 0) {
	OutBuffer buf = new OutBuffer();
	buf.write (rightJustify("", nb, ' '));
	buf.write (this.name.toStr ());
	buf.write (" ~> ");
	foreach (key, value ; attrs) {
	    buf.write (key.toStr ());
	    buf.write ("=[");
	    buf.write (value);
	    buf.write ("]");
	}
	buf.write ('\n');
	foreach (it ; childs) {
	    buf.write (it.toStr (nb + 4));
	    buf.write ("\n");
	}
	return buf.toString ();
    }

    override string toString(){
	return toStr();
    }

    void toXml (ref OutBuffer buf, int nb = 0) {
	if (buf is null) buf = new OutBuffer ();
	buf.write (rightJustify ("", nb, ' '));
	buf.write ("<");
	buf.write (this.name.toXml);
	foreach (key, value; attrs) {
	    buf.write (" ");
	    buf.write (key.toXml);
	    buf.write ("=\"");
	    buf.write (value);
	    buf.write ("\"");
	}
	if (this.childs.length == 0) buf.write ("/>\n");
	else {
	    buf.write (">\n");
	    foreach (it ; this.childs) {
		it.toXml (buf, nb + 4);		
	    }
	    buf.write (rightJustify("", nb, ' '));
	    buf.write ("</");
	    buf.write (this.name.toXml);
	    buf.write (">\n");
	}
    }

    ref Identifiant name () {
	return this._name;
    }

    ref string [Identifiant] attrs () {
	return this._attrs;
    }

    ref Array!Balise childs () {
	return this._childs;
    }
        
    private {	
	Identifiant _name;
	string [Identifiant] _attrs;
	Array!Balise _childs;
    }       
}


class ProcInst : Balise {
    this (Identifiant name, string[Identifiant] attrs) {
	super (name, attrs);
	assert(false, "TODO a implementer");
    }    
}

class Text : Balise {
    this (string content) {
	super (Identifiant.eof);
	this.content = content;
    }

    override string getValue() {
	return this.content;
    }

    override string toStr (int nb = 0) {
	OutBuffer buf = new OutBuffer;
	buf.write (rightJustify("", nb, ' '));
	buf.write ("[");
	buf.write (content);
	buf.write ("]");
	return buf.toString ();
    }

    override void toXml (ref OutBuffer buf, int nb = 0) {
	buf.write (rightJustify ("", nb, ' '));	
	buf.write (this.content);
	buf.write ("\n");
    }

    override Balise clone(){
	return new Text(this.content);
    }

    string content;
}
