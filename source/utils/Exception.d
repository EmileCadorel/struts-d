module utils.Exception;
public import utils.NoSuchFile;


class StrutsException : Exception {

    string RESET = "\u001B[0m";
    string PURPLE = "\u001B[46m";
    string RED = "\u001B[41m";
    string GREEN = "\u001B[42m";
    
    this (string msg) {
	super (msg);
    }
    
}
