module http.requestmod.HttpRequestParser;
import std.traits, std.string;
import std.outbuffer;
import std.conv, std.stdio;
import utils.lexer;
import std.container;
import http.request;
import utils.exception;

enum HttpRequestTokens : string {
    COLON = ":",
	SEMI_COLON = ";",
	COMA = ",",
	SLASH = "/",
	QUES_MARK = "?",
	EQUAL = "=",
	AND = "&",
	BOUND_END = "--"
	}

class HttpRequestParser {    
    
    static HttpRequest parser (string data) {
	LexerString lexer = new LexerString (data);
	lexer.setKeys (make!(Array!string)(":", ",", "?", "#", "=", "&", " ", "\n", "\r", ";"));
	lexer.setSkip (make!(Array!string)(" ", "\r", "\n"));
	Word begin;
	HttpRequest ret = new HttpRequest;
	while (true) {
	    auto read = lexer.getNext (begin);	    
	    if (!read) break;
	    begin.str = toUpper(begin.str);
	    if (find ([EnumMembers!HttpMethod], begin.str) != [])
		parse_method (lexer, ret, begin);
	    else if (begin.str == "HOST")
		parse_host (lexer, ret);
	    else if (begin.str == "USER-AGENT")
		parse_user (lexer, ret);
	    else if (begin.str == "ACCEPT")
		parse_accept (lexer, ret);
	    else if (begin.str == "ACCEPT-LANGUAGE")
		parse_language (lexer, ret);
	    else if (begin.str == "ACCEPT-ENCODING")
		parse_encoding (lexer, ret);
	    else if (begin.str == "CONNECTION")
		parse_connection (lexer, ret);
	    else if (begin.str == "REFERER")
		parse_referer (lexer, ret);
	    else if (begin.str == "CACHE-CONTROL")
		parse_cache_control (lexer, ret);
	    else if (begin.str == "CONTENT-LENGTH") 
		parse_post_values (lexer, ret);
	    else if (begin.str == "CONTENT-TYPE")
		parse_content_type (lexer, ret);
	    else if (begin.str == "COOKIE")
		parse_cookies (lexer, ret);
	}
	return ret;
    }

    static void parse_content_type (LexerString file, ref HttpRequest req) {
	Word word;
	if (!file.getNext (word) || word.str != HttpRequestTokens.COLON)
	    throw new ReqSyntaxError (word);
	while (true) {
	    if(!file.getNext (word)) break;
	    else {
		string key = word.str;
		if(!file.getNext (word))
		    throw new ReqSyntaxError (word);
		else if (word.str != HttpRequestTokens.EQUAL) {
		    file.rewind ();
		    req.content_type [key] = HttpParameter.empty;
		} else {		    
		    req.content_type [key] = parse_value (file, HttpRequestTokens.SEMI_COLON);
		}
		if (!file.getNext (word)) break;
		else if (word.str != HttpRequestTokens.SEMI_COLON) {
		    file.rewind ();
		    break;
		}
	    }
	}	
    }
    
    static void parse_cookies (LexerString file, ref HttpRequest req) {
	Word word;
	if (!file.getNext (word) || word.str != HttpRequestTokens.COLON) 
	    throw new ReqSyntaxError (word);
	while (true) {
	    if(!file.getNext (word)) break;
	    else {
		string key = word.str;
		if(!file.getNext (word))
		    throw new ReqSyntaxError (word);
		else if (word.str != HttpRequestTokens.EQUAL) {
		    file.rewind ();
		    req.cookies[key] = HttpParameter.empty;
		} else {		    
		    req.cookies [key] = parse_value (file, HttpRequestTokens.SEMI_COLON);
		}
		if (!file.getNext (word)) break;
		else if (word.str != HttpRequestTokens.SEMI_COLON) {
		    file.rewind ();
		    break;
		}
	    }
	}
    }
        
    static void parse_cache_control (LexerString file, ref HttpRequest req) {
	Word word;
	if(!file.getNext (word) || word.str != HttpRequestTokens.COLON)
	    throw new ReqSyntaxError (word);
	file.setSkip (make!(Array!string)());
	string total;
	while (true) {
	    if (!file.getNext (word) || word.str == "\r" || word.str == "\n") break;
	    else {
		total ~= word.str;
	    }
	}
	req.cache_control = total;
	file.setSkip (make!(Array!string)(" ", "\r", "\n"));

    }
    
    static void parse_referer (LexerString file, ref HttpRequest req) {
	Word word;
	if(!file.getNext (word) || word.str != HttpRequestTokens.COLON)
	    throw new ReqSyntaxError (word);
	file.setSkip (make!(Array!string)());
	string total;
	while (true) {
	    if (!file.getNext (word) || word.str == "\r" || word.str == "\n") break;
	    else {
		total ~= word.str;
	    }
	}
	req.referer = total;
	file.setSkip (make!(Array!string)(" ", "\r", "\n"));
    }
    
    static void parse_method (LexerString lexer, ref HttpRequest req, Word elem) {
	req.http_method = cast(HttpMethod)elem.str;
	Word proto, word;
	lexer.addKey (HttpRequestTokens.SLASH);
	auto url = parse_url (lexer);
	lexer.getNext (proto);
	if(!lexer.getNext (word) || word.str != HttpRequestTokens.SLASH)
	    throw new ReqSyntaxError (word);
	lexer.getNext (proto);
	lexer.removeKey (HttpRequestTokens.SLASH);
	req.url = url;
	req.proto = proto.str;
    }

    static HttpUrl parse_url (LexerString file) {
	Word word;
	file.getNext (word);
	if (word.str != HttpRequestTokens.SLASH)
	    throw new ReqSyntaxError (word);
	file.setSkip (make!(Array!string)());
	Array!string path;
	
	while (true) {	    
	    if (!file.getNext (word)) throw new ReqSyntaxError (word);
	    if (word.str == " ") break;
	    else if (word.str == HttpRequestTokens.QUES_MARK) break;
	    else {
		path.insertBack (word.str);
	    }
	    if (!file.getNext (word)) throw new ReqSyntaxError (word);
	    if (word.str == HttpRequestTokens.QUES_MARK) break;
	    else if (word.str == " ") break;
	    else if (word.str != HttpRequestTokens.SLASH)
		throw new ReqSyntaxError (word);	    
	}
	
	if (word.str == HttpRequestTokens.QUES_MARK) {
	    auto ret = parse_url_values(file, path);
	    file.setSkip (make!(Array!string)(" ", "\n", "\r"));
	    return ret;
	} else {
	    file.setSkip (make!(Array!string)(" ", "\n", "\r"));
	    return new HttpUrl (path);
	}	    
    }

    static HttpUrl parse_url_values (LexerString file, Array!string path) {
	Word word;
	HttpParameter [string] params;
	while (true) {
	    if (!file.getNext (word)) throw new ReqSyntaxError (word);
	    string key = word.str;
	    if (!file.getNext (word) || word.str != HttpRequestTokens.EQUAL)
		throw new ReqSyntaxError (word);
	    params[key] = parse_value (file);
	    if(!file.getNext (word))
		throw new ReqSyntaxError (word);
	    if (word.str == " ")
		return new HttpUrl (path, params);
	    else if (word.str != HttpRequestTokens.AND)
		throw new ReqSyntaxError (word);
	}	
    }

    static void parse_post_values (LexerString lexer, HttpRequest req) {
	Word word;
	if (!lexer.getNext (word) || word.str != HttpRequestTokens.COLON)
	    throw new ReqSyntaxError (word);
	auto size = parse_value (lexer);       	
	auto datas = lexer.getBytes (size.to!int + 4);
	writeln (datas);
	auto it = ("boundary" in req.content_type);
	if (it !is null)
	    req.post_value = HttpPostParser.parse (to!string (datas), it.to!string);
	else
	    req.post_value = HttpPostParser.parse (to!string (datas), null);
    }

    
    static HttpParameter parse_value (LexerString file, HttpRequestTokens bre = HttpRequestTokens.AND) {
	Word word;
	file.getNext (word);
	if (word.str == " " || word.str == bre) {
	    file.rewind ();
	    return HttpParameter.empty;
	}
	if (word.str.length > 0 && word.str[0] >= '0'
	    && word.str[0] <= '9') 
	    return numeric (file, word);	
	else {
	    return HttpParameter (HttpParamEnum.STRING, word.str.dup);
	}
    }


    static HttpParameter numeric (LexerString file, Word word) {
	bool dot = false;
	foreach (it ; word.str) {
	    if (it == '.') {		
		if (dot) {
		    return HttpParameter (HttpParamEnum.STRING, word.str.dup);
		} else dot = true;
	    } else if (it < '0' || it > '9') {
		return HttpParameter (HttpParamEnum.STRING, word.str.dup);
	    }
	}
	
	if (dot) {
	    return HttpParameter (HttpParamEnum.FLOAT, [(to!float (word.str))]);
	} else {
	    return HttpParameter (HttpParamEnum.INT, [to!int (word.str)]);
	}	
    }        
    
    static void parse_host (LexerString lexer, ref HttpRequest req) {
	Word addr, port, ign;
	lexer.getNext (ign);
	lexer.getNext (addr);
	lexer.getNext (ign);
	lexer.getNext (port);
	req.host_addr = addr.str;
	req.host_port = port.str;
    }
    
    static void parse_user (LexerString lexer, ref HttpRequest req) {
	Word suite, ign;
	string total;
	lexer.getNext (ign);
	lexer.removeSkip (" ");
	lexer.removeSkip ("\n");
	lexer.removeSkip ("\r");
	while (true) {
	    auto take = lexer.getNext (suite);
	    if (suite.str == "\n" || suite.str == "\r" || !take) break;
	    else total ~= suite.str;
	}
	lexer.addSkip (" ");
	lexer.addSkip ("\n");
	lexer.addSkip ("\r");
	req.user_agent = total;
    }

    static void parse_accept (LexerString lexer, ref HttpRequest req) {
	Word next, ign;
	lexer.removeSkip ("\n");
	lexer.removeSkip ("\r");
	lexer.getNext (ign);
	string [] total;
	while (true) {
	    lexer.getNext (next);
	    total ~= next.str;
	    auto take = lexer.getNext (next); //skip ,
	    if (next.str == "\r" || next.str == "\r" || !take) break;
	}
	lexer.addSkip ("\n");
	lexer.addSkip ("\r");
	req.file_accepted = total;
    }

    static void parse_language (LexerString lexer, ref HttpRequest req) {
	Word next, ign;
	lexer.removeSkip ("\n");
	lexer.removeSkip ("\r");
	lexer.getNext (ign);
	string [] total;
	while (true) {
	    lexer.getNext (next);
	    total ~= next.str;
	    auto take = lexer.getNext (next);
	    if (next.str == "\n" || next.str == "\r" || !take) break;
	}
	lexer.addSkip ("\n");
	lexer.addSkip ("\r");
	req.languages = total;
    }

    static void parse_encoding (LexerString lexer, ref HttpRequest req) {
	Word next, ign;
	lexer.removeSkip ("\n");
	lexer.removeSkip ("\r");
	lexer.getNext (ign);
	string [] total;
	while (true) {
	    lexer.getNext (next);
	    total ~= next.str;
	    auto take = lexer.getNext (next);
	    if (next.str == "\r" || !take) break;
	}
	lexer.addSkip ("\r");
	lexer.addSkip ("\n");
	req.encoding = total;
    }

    static void parse_connection (LexerString lexer, ref HttpRequest req) {
	Word next, ign;
	lexer.getNext (ign);
	lexer.getNext (next);
	req.connection = next.str;
    }

}
