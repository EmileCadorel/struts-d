module servlib.utils.exception;
public import servlib.utils.exceptionmod.NoSuchFile;
public import servlib.utils.exceptionmod.ReqSyntaxException;
public import servlib.utils.exceptionmod.XMLSyntaxError;
public import servlib.utils.exceptionmod.ConfigFile;
public import servlib.utils.exceptionmod.Server;
public import servlib.utils.exceptionmod.ManifestError;
public import servlib.utils.exceptionmod.StrutsError;
public import servlib.utils.exceptionmod.WrongExt;
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
