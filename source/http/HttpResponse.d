module http.HttpResponse;
import std.outbuffer;
import std.datetime;
import std.conv;

enum HttpResponseCode : ushort {    
    OK = 200,
    NOT_FOUND = 404,
    INTERNAL_ERROR = 500
}


class HttpResponse {

    this () {
	this._date = Clock.currTime ();
    }

    ref HttpResponseCode code () {
	return this._code;
    }

    ref byte [] content () {
	return this._content;
    }

    ref string proto () {
	return this._proto;
    }

    ref string type () {
	return this._type;
    }    

    byte [] enpack () {
	OutBuffer buf = new OutBuffer;
	buf.write (_proto);
	buf.write (" " ~ to!string(cast(ushort)_code) ~ " " ~ to!string (_code));
	buf.write ("\nDate: " ~ to!string(_date.dayOfWeek));
	buf.write (", " ~ to!string (_date.day) ~ " " ~ to!string(_date.month) ~ " ");
	buf.write (to!string(_date.year) ~ " " ~ to!string(_date.hour) ~ ":" ~ to!string (_date.minute) ~ ":" ~ to!string(_date.second));
	buf.write (" " ~ to!string(_date.timezone.stdName));
	buf.write ("\nContent-Type: " ~ _type);
	buf.write ("\nContent-Length: " ~ to!string(_content.length) ~ "\n");
	byte [] total = cast(byte[])buf.toString ~ _content;
	return total;
    }
    
    private {
	HttpResponseCode _code;
	string _proto;
	SysTime _date;
	byte [] _content;
	string _type;
    }

}
