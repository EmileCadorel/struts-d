module servlib.utils.Option;

import std.stdio, std.file;
import servlib.utils.XMLoader;
import servlib.utils.Singleton;
import servlib.utils.exception;
import servlib.utils.Log;
import servlib.control.ControllerContainer;

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
    this._paths["config_file"] = config_file_path;
    this._load_config ();
  }

  ref string config_file_path() {
    return this._paths["config_file"];
  }

  ref string log_file_path() {
    return this._paths["log_file"];
  }

  ref string controllers_file_path () {
    return this._paths["controllers_file"];
  }

  ref ControllerContainer controllers () {
    return this._controllers;
  }

  ref string session_dir_path () {
    return this._paths["session_dir"];
  }

  ref bool debug_mode () {
    return this._debug_mode;
  }

  ref SessIdState use_sessid () {
    return this._use_sessid;
  }

  mixin Singleton!Option;

  private {
    this () {
      // valeurs par défaut
      this._default_config_file_path = "config_server.xml";
      this._default_session_dir_path = "session_dir";
      this._default_log_file_path = "log_server.txt";
      this._default_controllers_file_path = "controllers.xml";

      this._paths["config_file"] = this._default_config_file_path;
      this._paths["session_dir"] = this._default_session_dir_path;
      this._paths["log_file"] = this._default_log_file_path;
      this._paths["controllers_file"] = this._default_controllers_file_path;
      this._use_sessid = SessIdState.COOKIE;
      this._debug_mode = false;
      this._controllers = new ControllerContainer;
    }

    void _load_config () {
      try {
	this._load (this._paths["config_file"]);
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
	this._load_data (child);
      }
    }

    void _load_data (Balise b) {
      if (b.name.name == "general") {
	foreach (child ; b.childs) {
	  this._load_general_params (child);
	}
      } else if (b.name.name == "controllers") {
	foreach (child ; b.childs) {
	  this._load_controllers (child);
	}
      } else {
	throw new ConfigFileError ("Le format du fichier de configuration est invalide, balise inconnue : " ~ b.name.name);
      }
    }

    void _load_general_params (Balise b) {
      if (b.name.name == "use_sessid") {
	if (b.childs.length != 1)
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
	Log.instance.add_info ("Paramètre chargé : use_sessid -> ", child.getValue());
      } else if (b.name.name == "sessions_path") {
	if (b.childs.length != 1)
	  throw new ConfigFileError ("Le format du fichier de configuration est incomplet. Détail : sessions_path");
	this._paths["session_dir"] = b.childs[0].getValue();
	Log.instance.add_info ("Paramètre chargé : session_dir -> ", b.childs[0].getValue());
      } else if (b.name.name == "log_file_path") {
	if (b.childs.length != 1)
	  throw new ConfigFileError ("Le format du fichier de configuration est incomplet. Détail : log_file_path");
	this._paths["log_file"] = b.childs[0].getValue();
	Log.instance.add_info ("Paramètre chargé : log_file -> ", b.childs[0].getValue());
      } else if (b.name.name == "debug_mode") {
	if (b.childs.length != 1)
	  throw new ConfigFileError ("Le format du fichier de configuration est incomplet. Détail : log_file_path");
	this._debug_mode = (b.childs[0].getValue() == "true");
	Log.instance.add_info ("Paramètre chargé : debug_mode -> ", b.childs[0].getValue());
      } else if (b.name.name == "controllers") {
	if (b.childs.length != 1)
	  throw new ConfigFileError ("Le format du fichier de configuration est incomplet. Détail : controllers");
	this._paths["controllers_file"] = b.childs[0].getValue();
      } else {
	throw new ConfigFileError ("Balise \"" ~ b.name.name ~ "\" inconnue dans le fichier de configuration !");
      }
    }

    void _load_controllers (Balise b) {
      if (b.name.name == "controller") {
	if (b.childs.length == 2) {
	  Balise b_name = b.childs[0];
	  Balise b_class = b.childs[1];
	  if (b_name.name.name == "name" && b_class.name.name == "class") {
	    import std.stdio; writeln ("controllers : ", this._controllers);
	    this._controllers[b_name.childs[0].getValue()] = ControllerInfos (b_name.childs[0].getValue(), b_class.childs[0].getValue(), null, null);
	    Log.instance.add_info ("Controlleur ajouté : ", b_name.childs[0].getValue(), " -> ", b_class.childs[0].getValue());
	  }
	} else {
	  //TODO
	}
      } else {
	//TODO
      }
    }

    immutable string _default_config_file_path;
    immutable string _default_session_dir_path;
    immutable string _default_log_file_path;
    immutable string _default_controllers_file_path;

    string[string] _paths;
    SessIdState _use_sessid;
    bool _debug_mode;
    ControllerContainer _controllers;
  }
}
