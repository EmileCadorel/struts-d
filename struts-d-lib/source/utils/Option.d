module utils.Option;

import std.stdio, std.file;
import utils.XMLoader;
import utils.Singleton;
import utils.exception;
import utils.Log;

enum SessIdState : string {
 NONE = "NONE",
   COOKIE = "COOKIE",
   URL = "URL"
   }

class Option {

  void load_config () {
    this._load_config ();
  }

  void load_config (string config_file_path) {
    this._config_file_path = config_file_path;
    this._load_config ();
  }

  ref string log_file_path() {
    return this._log_file_path;
  }

  ref SessIdState use_sessid () {
    return this._use_sessid;
  }

  mixin Singleton!Option;

  private {
    this () {
      // valeurs par défaut
      this._default_config_file_path = "config_server.xml";
      this._config_file_path = this._default_config_file_path;
      this._log_file_path = "logs_server.txt";
      this._use_sessid = SessIdState.COOKIE;
    }

    void _load_config () {
      try {
	this._load (this._config_file_path);
      } catch (StrutsException e) {
	if (this._default_config_file_path.isDir) {
	  throw new NoSuchFile (this._default_config_file_path);
	} else {
	  Log.instance.add_war ("Utilisation du fichier de configuration par défaut.");
	  try {
	    this._load (this._default_config_file_path);
	  } catch (StrutsException e) {
	    import std.stdio; writeln (e);
	    throw new ServerError (e.toString());
	  }
	}
      }
    }

    void _load (string file_name) {
      Balise root = XMLoader.root (file_name);

      if (root.name.name != "config")
	throw new ConfigFileError ("Le format du fichier de configuration est invalide. Détail : " ~ root.name.name);

      foreach (child ; root.childs) {
	this._load_param (child);
      }
    }

    void _load_param (Balise b) {
      if (b.name.name == "use_sessid") {
	if (b.childs.length == 0)
	  throw new ConfigFileError ("Le format du fichier de configuration est incomplet. Détail : use_sessid");
	Balise child = b.childs[0];
	if (child.getValue() == "NONE") {
	  this._use_sessid = SessIdState.NONE;
	} else if (child.getValue() == "COOKIE") {
	  this._use_sessid = SessIdState.COOKIE;
	} else if (child.getValue() == "URL") {
	  this._use_sessid = SessIdState.URL;
	} else {
	  throw new ConfigFileError ("Le format du fichier de configuration est invalide. Détail : " ~ child.getValue());
	}
      }
    }

    immutable string _default_config_file_path;
    string _config_file_path;
    string _log_file_path;
    SessIdState _use_sessid;
  }
}