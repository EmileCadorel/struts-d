module utils.exception;
public import utils.exceptionmod.NoSuchFile;
public import utils.exceptionmod.ReqSyntaxException;
public import utils.exceptionmod.XMLSyntaxError;
public import utils.exceptionmod.ConfigFile;
public import utils.exceptionmod.Server;
import utils.Log;

class StrutsException : Exception {

    string RESET = "\u001B[0m";
    string PURPLE = "\u001B[46m";
    string RED = "\u001B[41m";
    string GREEN = "\u001B[42m";

    this (string msg) {
      Log.instance.add_err (msg);
	super (msg);
    }

  override string toString() {
    return super.msg;
  }
}
