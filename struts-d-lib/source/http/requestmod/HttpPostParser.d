module http.requestmod.HttpPostParser;
import utils.lexer;
import http.request, std.string;
import std.stdio, std.container;
import utils.exception;

class HttpPostParser {

    static HttpPost parse (string data, string boundary) {
	LexerString lexer = new LexerString (data);
	lexer.setKeys (make!(Array!string)(":", ",", "?", "#", "=", "&", " ", "\n", "\r", ";"));
	lexer.setSkip (make!(Array!string)(" ", "\r", "\n"));
	Word begin;
	HttpPost ret = new HttpPost;
	if (boundary !is null) boundary = "--" ~ toUpper (boundary);
	while (lexer.getNext (begin)) {
	    if (begin.str == boundary) parse_file (lexer, ret, boundary);
	    else if (boundary !is null && begin.str == boundary ~ "--") break;	    
	    else parse_post_values (lexer, ret);
	}
	return ret;
    }

    static void parse_file (LexerString file, ref HttpPost post, string boundary) {
	Word word;
	while (true) {
	    if (!file.getNext (word)) throw new ReqSyntaxError (word);
	    word.str = toUpper (word.str);
	    if (word.str == "CONTENT_DISPOSITION") {
		parse_content_disposition (file, post);
	    } else if (word.str == "CONTENT-TYPE") {
		parse_content_type (file, post);
	    } else {
		parse_to_bound (file, post, boundary);
		return;
	    }	    
	}
    }

    static void parse_content_disposition (LexerString file, ref HttpPost post) {
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
		    post.content_disp [key] = HttpParameter.empty;
		} else {		    
		    post.content_disp [key] = parse_value_with_quot (file);
		}
		if (!file.getNext (word)) break;
		else if (word.str != HttpRequestTokens.SEMI_COLON) {
		    file.rewind ();
		    break;
		}
	    }
	}
    }

    static void parse_content_type (LexerString, ref HttpPost) {}
    static void parse_to_bound (LexerString, ref HttpPost, string) {}
    
    
    static HttpParameter parse_value_with_quot (LexerString file) {
	return HttpParameter.empty;
    }

    
    static void parse_post_values (LexerString file, ref HttpPost post) {
	
    }
    
    
    private this () {}

}
