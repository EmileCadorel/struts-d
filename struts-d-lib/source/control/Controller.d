module control.Controller;
import http.request;
import control.SessionController;
import control.Session;

abstract class Controller {

  this () {}

  /**
     Unpack la request et rempli les attributs du controller en consequence
  */
  void init (HttpRequest request, string sessid = "") {
    this._request = request;
    this._sessid = sessid;
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

  ref Session session () {
    return SessionController.instance.getSession (this._sessid);
  }

  ref HttpRequest request () {
    return this._request;
  }

  private {
    HttpRequest _request;
    string _sessid;
  }
}
