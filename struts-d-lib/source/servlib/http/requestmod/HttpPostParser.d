module servlib.http.requestmod.HttpPostParser;
import servlib.utils.lexer;
import servlib.http.request, std.string;
import std.stdio, std.container;
import servlib.utils.exception, std.conv;

class HttpPostParser {

    static HttpPost parse (string data, string boundary) {
	LexerString lexer = new LexerString (data);
	lexer.setKeys (make!(Array!string)(":", ",", "?", "#", "=", "&", " ", "\n", "\r", ";", "\""));
	lexer.setSkip (make!(Array!string)(" ", "\r", "\n"));
	Word begin;
	HttpPost ret = new HttpPost;
	if (boundary !is null) boundary = "--" ~ toUpper (boundary);
	while (lexer.getNext (begin)) {
	    if (begin.str == boundary) parse_file (lexer, ret, boundary);
	    else if (boundary !is null && begin.str == boundary ~ "--") break;	    
	    else {
		lexer.rewind ();
		parse_post_values (lexer, ret);
	    }
	}
	return ret;
    }

    static void parse_file (LexerString file, ref HttpPost post, string boundary) {
	Word word;
	HttpFile h_file = new HttpFile;
	while (true) {
	    if (!file.getNext (word)) throw new ReqSyntaxError (word);
	    word.str = toUpper (word.str);
	    if (word.str == "CONTENT-DISPOSITION") {
		parse_content_disposition (file, h_file);
	    } else if (word.str == "CONTENT-TYPE") {
		parse_content_type (file, h_file);
	    } else {
		parse_to_bound (file, h_file, boundary);
		post.files ~= [h_file];
		return;
	    }	    
	}
    }

    static void parse_content_disposition (LexerString file, ref HttpFile post) {
	Word word;
	if (!file.getNext (word) || word.str != HttpRequestTokens.COLON)	    
	    throw new ReqSyntaxError (word);
	file.setSkip (make!(Array!string) ());
	file.addSkip (" ");
	while (true) {
	    if(!file.getNext (word)) break;	    
	    else {
		string key = word.str;
		if(!file.getNext (word))
		    throw new ReqSyntaxError (word);
		else if (word.str != HttpRequestTokens.EQUAL) {
		    file.rewind ();
		    post.content_disp [key] = HttpParameter.empty;
		} else {		    
		    post.content_disp [key] = parse_value_with_quot (file);
		    file.setSkip (make!(Array!string) ());
		    file.addSkip (" ");
		}
		if (!file.getNext (word)) break;
		else if (word.str != HttpRequestTokens.SEMI_COLON) {
		    file.rewind ();
		    break;
		} 
	    }
	}
	file.setSkip (make!(Array!string) (" ", "\n", "\r"));
    }

    static void parse_content_type (LexerString file, ref HttpFile post) {
	Word word;
	if (!file.getNext (word) || word.str != HttpRequestTokens.COLON)
	    throw new ReqSyntaxError (word);
	while (true) {
	    if (!file.getNext (word)) break;
	    else {
		string key = word.str;
		if (!file.getNext (word)) throw new ReqSyntaxError (word);
		else if (word.str != HttpRequestTokens.EQUAL) {
		    file.rewind ();
		    post.content_type [key] = HttpParameter.empty;
		} else {
		    post.content_type [key] = parse_value (file, HttpRequestTokens.SEMI_COLON);
		}
		if (!file.getNext (word)) break;
		else if (word.str != HttpRequestTokens.SEMI_COLON) {
		    file.rewind ();
		    break;
		}
	    }
	}
    }

    static void parse_suite (LexerString file, char[] suite) {
	Word word;
	for (ulong i = 0; i < suite.length;) {
	    if (!file.getNext (word)) throw new ReqSyntaxError (word);
	    for (ulong j = 0; j < word.str.length; j++) {
		if (word.str[j] != suite[i]) throw new ReqSyntaxError (word);
		else i++;
	    }
	}
    }
    
    static void parse_to_bound (LexerString file, ref HttpFile post, string bound) {
	Word word;
	file.setSkip (make!(Array!string) ());
	byte[] total;
	while (true) {
	    if(!file.getNext (word)) throw new ReqSyntaxError (word);
	    else {
		if (word.str == bound || word.str == bound ~ "--") {
		    file.rewind ();
		    break;
		} else {
		    total ~= word.str;
		}
	    }
	}
	post.content = cast(byte[])total;
	file.setSkip (make!(Array!string) (" ", "\n", "\r"));
    }
        
    static HttpParameter parse_value_with_quot (LexerString file) {
	Word word;	
	if(!file.getNext (word) || word.str != "\"")
	    throw new ReqSyntaxError (word);
	file.setSkip (make!(Array!string) ());
	string total;
	while (true) {
	    if (!file.getNext (word)) throw new ReqSyntaxError (word);
	    else {
		if (word.str == "\"") break;
		else total ~= word.str;
	    }
	}
	file.setSkip (make!(Array!string) (" ", "\n", "\r"));
	return HttpParameter (HttpParamEnum.STRING, total.dup);
    }

    
    static void parse_post_values (LexerString file, ref HttpPost post) {
	Word word;
	HttpParameter[string] params;
	while (true) {
	    if (!file.getNext (word)) throw new ReqSyntaxError (word);
	    string key = word.str;
	    if (!file.getNext (word) || word.str != HttpRequestTokens.EQUAL)
		throw new ReqSyntaxError (word);
	    params[key] = parse_value (file);
	    if (!file.getNext (word)) break;
	    else if (word.str != HttpRequestTokens.AND) {
		file.rewind ();
		break;
	    }
	}
	post.params = params;
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

    
    
    private this () {}

}
