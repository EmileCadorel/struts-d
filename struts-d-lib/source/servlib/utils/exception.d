module servlib.utils.exception;

/// Module d'inclusion du superModule exceptionmod

public import servlib.utils.exceptionmod.NoSuchFile;
public import servlib.utils.exceptionmod.ReqSyntaxException;
public import servlib.utils.exceptionmod.XMLSyntaxError;
public import servlib.utils.exceptionmod.ConfigFile;
public import servlib.utils.exceptionmod.Server;
public import servlib.utils.exceptionmod.ManifestError;
public import servlib.utils.exceptionmod.StrutsError;
public import servlib.utils.exceptionmod.WrongExt;
public import servlib.utils.exceptionmod.SoError;
import servlib.utils.Log;

class StrutsException : Exception {

    this (string msg) {
      Log.instance.addError (msg);
	super (msg);
    }
}
