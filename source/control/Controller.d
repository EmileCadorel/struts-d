module control.Controller;

abstract class Controller {

    this () {}
    
    void unpackRequest (HttpRequest request) {}

    abstract string execute ();
    
    ~this () {}
    
}
