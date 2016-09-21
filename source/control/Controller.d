module control.Controller;
import http.HttpRequest;

abstract class Controller {

    this () {}

    /**
     Unpack la request et rempli les attributs du controller en consequence
     */
    void unpackRequest (HttpRequest request) {
    }

    abstract string execute ();
    
    ~this () {}
    
}
