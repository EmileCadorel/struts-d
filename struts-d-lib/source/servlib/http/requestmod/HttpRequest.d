module servlib.http.requestmod.HttpRequest;
import std.outbuffer, std.conv;
import servlib.http.request;

/**
 Le methode utilise par la requete
 */
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

/**
 Une requete Http
 */
class HttpRequest {

    this () {
    }

    /**
     La methode http utilise
     */
    ref HttpMethod http_method () {
	return this.type;
    }

    /**
     l'url de la requete
     */
    ref HttpUrl url () {
	return this._url;
    }

    /**
     le protocole de la requete
     */
    ref string proto() {
	return this._proto;
    }

    /**
     l'adresse du host
     */
    ref string host_addr () {
	return this._host_addr;
    }

    /**
     le port du host
     */
    ref string host_port () {
	return this._host_port;
    }

    /**
     Les langues demande
     */
    ref string [] languages () {
	return this._language;
    }

    /**
     l'explorateur utilise
     */
    ref string user_agent () {
	return this._user_agent;
    }

    /**
     l'information de connection
     */
    ref string connection () {
	return this._connection;
    }

    /**
     l'encodage pris en charge
     */
    ref string [] encoding () {
	return this._encoding;
    }

    /**
     le type de fichier pris en charge
     */
    ref string [] file_accepted () {
	return this._file_accepted;
    }

    /**
     cf: rfc requete HTTP
     */
    ref string referer () {
	return this._referer;
    }

    /**
     cf: rfc requete HTTP
    */
    ref string cache_control () {
	return this._cache_control;
    }

    /**
     cf: rfc requete HTTP
    */
    ref HttpParameter [string] content_type () {
	return this._content_type;
    }
    
    /**
     Les elements contenu dans la requetes
     */
    ref HttpPost post_value () {
	return this._post_value;
    }

    /**
     Les cookies
     */
    ref HttpParameter [string] cookies () {
	return this._cookies;
    }

    override string toString () {
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
	buf.write ("POST_VALUES : " ~ to!string (_post_value) ~ "\n");
	buf.write ("COOKIES : " ~ to!string (_cookies) ~ "\n");
	buf.write ("CONTENT_TYPE : " ~ to!string (_content_type) ~ "\n");
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
	HttpPost _post_value;
	HttpParameter [string] _content_type;	
	HttpParameter [string] _cookies;
    }
}
