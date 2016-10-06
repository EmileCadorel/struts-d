module servlib.utils.xmlmod.Identifiant;
import servlib.utils.xml;
import std.conv;

/**
 Un identifiant dans un fichier XML
 */
class Identifiant {

    this (string name, Location locate) {
	this._name = name;
	this._locate = locate;
    }

    this (string name, Identifiant space, Location locate) {
	this._name = name;
	this._space = space;
	this._locate = locate;
    }

    ref string name () {
	return this._name;
    }

    ref Identifiant space () {
	return this._space;
    }

    ref Location locate () {
	return this._locate;
    }
    
    static Identifiant eof () {
	return new Identifiant ("", Location("", -1, -1));
    }
    
    override bool opEquals (Object other_) {	
	Identifiant other = cast(Identifiant) other_;
	if (other !is null) {	
	    if (this.space !is null) {
		return this.name == other.name && this.space == other.space;
	    } else {
		return this.name == other.name;
	    }
	} else return false;
    }    
    
    string toStr () {
	if (space !is null)
	    return space.toSimpleString() ~ ":" ~ name ~ "!" ~ to!string (locate);
	else return name ~ "!" ~ to!string (locate);
    }

    string toXml () {
	if (space !is null)
	    return space.toSimpleString() ~ ":" ~ name;
	else return name;
    }
    
    private {
	string toSimpleString () {
	    return this.name;
	}

	/// le contenu
	string _name;

	/// le namespace (space:name)
	Identifiant _space;

	/// l'emplacement de l'identifiant
	Location _locate;
	
    }
}

