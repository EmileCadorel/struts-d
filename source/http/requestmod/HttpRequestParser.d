module http.requestmod.HttpRequestParser;
import std.traits;
import std.outbuffer;
import std.conv, std.stdio;
import utils.lexer;
import std.container;
import http.request;

enum HttpRequestTokens : string {
    SEMI_COLON = ":",
	COMA = ",",
	SLASH = "/",
	QUES_MARK = "?",
	EQUAL = "=",
	AND = "&"
	}

class ReqSyntaxError : Exception {
    this (Word word) {
	super ("Erreur de syntaxe " ~ word.str);
    }   
}


class HttpRequestParser {    
    
    static HttpRequest parser (string data) {
	LexerString lexer = new LexerString (data);
	lexer.setKeys (make!(Array!string)(":", ",", "/", "?", "#", "=", "&", " ", "\n", "\r"));
	lexer.setSkip (make!(Array!string)(" ", "\r", "\n"));
	Word begin;
	HttpRequest ret = new HttpRequest;
	while (true) {
	    auto read = lexer.getNext (begin);
	    if (!read) break;
	    if (find ([EnumMembers!HttpMethod], begin.str) != [])
		parse_method (lexer, ret, begin);
	    else if (begin.str == "Host")
		parse_host (lexer, ret);
	    else if (begin.str == "User-Agent")
		parse_user (lexer, ret);
	    else if (begin.str == "Accept")
		parse_accept (lexer, ret);
	    else if (begin.str == "Accept-Language")
		parse_language (lexer, ret);
	    else if (begin.str == "Accept-Encoding")
		parse_encoding (lexer, ret);
	    else if (begin.str == "Connection")
		parse_connection (lexer, ret);
	    else break;
	}
	return ret;
    }
        
    static void parse_method (LexerString lexer, ref HttpRequest req, Word elem) {
	req.http_method = cast(HttpMethod)elem.str;
	Word proto;
	auto url = parse_url (lexer);
	lexer.getNext (proto);
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
	    return parse_url_values(file, path);
	} else {
	    file.setSkip (make!(Array!string)(" ", "\n", "\r"));
	    return new HttpUrl (path);
	}	    
    }

    static HttpUrl parse_url_values (LexerString file, Array!string path) {
	Word word;
	HttpUrl.Parameter [string] params;
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

    static HttpUrl.Parameter parse_value (LexerString file) {
	Word word;
	file.getNext (word);
	if (word.str.length > 0 && word.str[0] >= '0'
	    && word.str[0] <= '9') 
	    return numeric (file, word);	
	else {
	    return HttpUrl.Parameter (HttpUrl.ParamEnum.STRING, word.str.dup);
	}
    }


    static HttpUrl.Parameter numeric (LexerString file, Word word) {
	bool dot = false;
	foreach (it ; word.str) {
	    if (it == '.') {		
		if (dot) {
		    return HttpUrl.Parameter (HttpUrl.ParamEnum.STRING, word.str.dup);
		} else dot = true;
	    } else if (it < '0' || it > '9') {
		return HttpUrl.Parameter (HttpUrl.ParamEnum.STRING, word.str.dup);
	    }
	}
	
	if (dot) {
	    return HttpUrl.Parameter (HttpUrl.ParamEnum.FLOAT, [(to!float (word.str))]);
	} else {
	    return HttpUrl.Parameter (HttpUrl.ParamEnum.INT, [to!int (word.str)]);
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
