module http.requestmod.HttpParameter;
import std.conv;

enum HttpParamEnum {
    STRING,
    INT,
    FLOAT,
    VOID
}

struct HttpParameter {
    HttpParamEnum type;
    void [] data;
		
    ref T to (T) () {
	return (cast(T[])this.data)[0];
    }

    static ref HttpParameter empty () {
	return _empty;
    }

    private {
	static HttpParameter _empty = HttpParameter (HttpParamEnum.VOID, null);
    }

    string toString () {
	switch (type) {
	case HttpParamEnum.STRING: return "Parameter(STRING," ~ cast(string)data ~ ")";
	case HttpParamEnum.INT: return "Parameter(INT," ~ std.conv.to!string ((cast(int[])data)[0]) ~ ")";
	case HttpParamEnum.FLOAT: return "Parameter(FLOAT," ~ std.conv.to!string ((cast(float[])data)[0]) ~ ")";
	default : return "Parameter (VOID)";
	}
    }
	
}
