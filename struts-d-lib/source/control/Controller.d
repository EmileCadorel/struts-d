module control.Controller;
import http.request;

abstract class Controller {

  this () {}

  /**
     Unpack la request et rempli les attributs du controller en consequence
  */
  void unpackRequest (HttpRequest request) {
    this._request = request;
  }

  abstract string execute ();

  ~this () {}

  HttpParameter get (string key) {
    return this._request.url.param(key);
  }

  HttpParameter post (string key) {
    return this._request.post_values()[key];
  }

  HttpParameter cookie (string key) {
    return this._request.cookies()[key];
  }

  ref HttpRequest request () {
    return this._request;
  }

  private {
    HttpRequest _request;
  }
}
