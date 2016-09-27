module utils.exception;
public import utils.exceptionmod.NoSuchFile;
public import utils.exceptionmod.ReqSyntaxException;
public import utils.exceptionmod.XMLSyntaxError;
public import utils.exceptionmod.ConfigFile;
public import utils.exceptionmod.Server;
import utils.Log;

class StrutsException : Exception {

    this (string msg) {
      Log.instance.add_err (msg);
	super (msg);
    }

  override string toString() {
    return super.msg;
  }
}
