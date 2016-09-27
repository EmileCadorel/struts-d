module control.SessionController;

import utils.Option;
import utils.Log;
import utils.Singleton;
import control.Session;
import std.file;

/**
   Class SessionController
   Permet de gérer les sessions sur le serveur.
   S'assure que le dossier de sessions existe bien, le créé si nécessaire.
   Permet de charger une session suivant son sessid.
 */
class SessionController {

  mixin Singleton!SessionController;

  void load_session (string sessid) {
    if ((sessid in this._sessions) is null) {
      string path = this._session_dir_path ~ sessid ~ ".sess";
      this._sessions[sessid] = new Session;
      // if (path.isDir) {
	this._load_session (sessid);
      // }
    }
  }

  ref Session getSession (string sessid) {
    return this._sessions[sessid];
  }

  private {
    this () {
      this._session_dir_path = Option.instance.session_dir_path;
      if (this._session_dir_path.length > 0) {
	if (!this._session_dir_path.exists) {
	  try {
	    mkdir (this._session_dir_path);
	  } catch (FileException e) {
	    Log.instance.add_err ("Erreur lors de la création du dossier de sessions : " ~ e.toString());
	  }
	}
      }
    }

    //TODO
    void _load_session (string sessid) {
      string path = this._session_dir_path ~ sessid ~ ".sess";
      string test = "super_session";
      this._sessions[sessid]["test"] = test;
    }

    Session [string] _sessions;
    string _session_dir_path;
  }
}