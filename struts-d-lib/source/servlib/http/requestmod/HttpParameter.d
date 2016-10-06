module servlib.http.requestmod.HttpParameter;
import std.conv;

/**
 Enum permettant de reconnaitre le type d'un parametre
*/
enum HttpParamEnum {
    STRING,
    INT,
    FLOAT,
    VOID
}

/**
 Un parametre passe dans un des elements d'une requete HTTP (POST, GET, FILE ...)
*/
struct HttpParameter {

    /**
     Le type du paramatre     
     */
    ref HttpParamEnum type () {
	return this._type;
    }

    /**
     Les donne du parametre
     */
    ref void [] data () {
	return this._data;
    }

    /**
     Cast les donnees en T[]
     */
    T[] to (T : T[]) () {
	return (cast(T[])this._data);
    }

    /**
     Cast les donnees en string
     */
    T to (T : string) () {
	return (cast(char[])this._data);
    }

    /**
     Cast les donnees en T
     */
    ref T to (T) () {
	return (cast(T[])this._data)[0];
    }

    /**
     Retourne le parametre vide
     */
    static ref HttpParameter empty () {
	return _empty;
    }

    /**
     Return:
     Vrai, si this == empty
     */
    bool isVoid () {
	return this._type == HttpParamEnum.VOID;
    }

    /**
     Affiche les informations de la structure formate en string
     */
    string toString () {
	switch (type) {
	case HttpParamEnum.STRING: return "Parameter(STRING," ~ cast(string)_data ~ ")";
	case HttpParamEnum.INT: return "Parameter(INT," ~ std.conv.to!string ((cast(int[])_data)[0]) ~ ")";
	case HttpParamEnum.FLOAT: return "Parameter(FLOAT," ~ std.conv.to!string ((cast(float[])_data)[0]) ~ ")";
	default : return "Parameter (VOID)";
	}
    }

    private {
	
	/// le parametre vide 
	static HttpParameter _empty = HttpParameter (HttpParamEnum.VOID, null);
	
	/// le type du fichier
	HttpParamEnum _type;

	/// le contenu du parametre
	void [] _data;
    }
    
}
