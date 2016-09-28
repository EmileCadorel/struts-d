module http.requestmod.HttpPost;
import http.requestmod.HttpParameter;
import http.requestmod.HttpFile;

class HttpPost {

    ref HttpParameter [string] params () {
	return this._params;
    }

    ref HttpFile [] files () {
	return this._files;
    }

    ref HttpParameter [string] content_disp () {
	return this._content_disp;
    }
    
    private {
	
	HttpParameter [string] _params;
	HttpParameter [string] _content_disp;
	HttpFile [] _files;
	
    }
    
}
