module http.requestmod.HttpRequest;
import std.outbuffer, std.conv;
import http.request;

enum HttpMethod : string {
    OPTIONS = "OPTIONS",
	GET = "GET",
	HEAD = "HEAD",
	POST = "POST",
	PUT = "PUT",
	DELETE = "DELETE",
	TRACE = "TRACE",
	CONNECT = "CONNECT"
	}

class HttpRequest {

    this () {
    }

    void http_method (HttpMethod type) {
	this.type = type;
    }

    HttpMethod http_method () {
	return this.type;
    }

    ref HttpUrl url () {
	return this._url;
    }

    ref string proto() {
	return this._proto;
    }

    ref string host_addr () {
	return this._host_addr;
    }

    ref string host_port () {
	return this._host_port;
    }

    ref string [] languages () {
	return this._language;
    }

    ref string user_agent () {
	return this._user_agent;
    }

    ref string connection () {
	return this._connection;
    }

    ref string [] encoding () {
	return this._encoding;
    }

    ref string [] file_accepted () {
	return this._file_accepted;
    }

    ref string referer () {
	return this._referer;
    }

    ref string cache_control () {
	return this._cache_control;
    }

    ref HttpParameter [string] post_values () {
	return this._post_values;
    }

    ref HttpParameter [string] cookies () {
	return this._cookies;
    }

    string toString () {
	OutBuffer buf = new OutBuffer;
	buf.write ("METHODE : " ~ to!string (type) ~ "\n");
	buf.write ("URL : " ~ _url.toString() ~ "\n");
	buf.write ("PROTOCOL : " ~ _proto ~ "\n");
	buf.write ("HOST : " ~ _host_addr ~ " : " ~ _host_port ~ "\n");
	buf.write ("USER_AGENT : " ~ _user_agent ~ "\n");
	buf.write ("LANGUAGES : " ~ to!string (_language) ~ "\n");
	buf.write ("FILE_FORMAT : " ~ to!string (_file_accepted) ~ "\n");
	buf.write ("ENCODING : " ~ to!string(_encoding) ~ "\n");
	buf.write ("CONNECTION : " ~ _connection ~ "\n");
	buf.write ("POST_VALUES : " ~ to!string (_post_values) ~ "\n");
	buf.write ("COOKIES : " ~ to!string (_cookies) ~ "\n");

	return buf.toString;
    }

    private {
	HttpMethod type;
	HttpUrl _url;
	string _proto;
	string _host_addr;
	string _host_port;
	string _user_agent;
	string [] _language;
	string [] _file_accepted;
	string [] _encoding;
	string _connection;
	string _referer;
	string _cache_control;

	HttpParameter [string] _post_values;
	HttpParameter [string] _cookies;
    }
}
