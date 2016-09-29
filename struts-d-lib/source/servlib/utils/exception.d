module servlib.utils.exception;
public import servlib.utils.exceptionmod.NoSuchFile;
public import servlib.utils.exceptionmod.ReqSyntaxException;
public import servlib.utils.exceptionmod.XMLSyntaxError;
public import servlib.utils.exceptionmod.ConfigFile;
public import servlib.utils.exceptionmod.Server;
import servlib.utils.Log;

class StrutsException : Exception {

    this (string msg) {
      Log.instance.add_err (msg);
	super (msg);
    }

  override string toString() {
    return super.msg;
  }
}
