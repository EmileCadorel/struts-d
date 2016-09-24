module driver.BaseDriverConfig;

import utils.XMLoader;

enum SessIdState : string {
 NONE = "NONE",
   COOKIE = "COOKIE",
   URL = "URL"
   }

/**
   Classe permettant de gérer le fichier de configuration d'une application web
 */
class Config {

  this () {
    this._use_sessid = SessIdState.COOKIE;
    this.init ("example/config.xml");
  }

  this (string config_file_path) {
    this._use_sessid = SessIdState.COOKIE;
    this.init (config_file_path);
  }

  void init (string config_file_path) {
    XMLoader xml = new XMLoader (config_file_path);
    Balise b = xml.root();

    assert (b.name.name == "config", "Format du fichier de config invalide : " ~ b.name.name);

    foreach (child ; b.childs) {
      if (child.name.name == "controllers") {
	this._get_controllers (child);
      } else if (child.name.name == "general") {
	this._get_general (child);
      } else {
	assert (1 != 1, "foireux ici");
      }
    }
  }

  string[string] get_controllers () {
    return this.controllers;
  }

  string use_sessid() {
    return this._use_sessid;
  }

  private {
    void _get_general (Balise b) {
      foreach (param ; b.childs) {
	assert (param.childs.length == 1, "Erreur format.");
	if (param.name.name == "use_sessid") {
	  Balise value = param.childs[0];
	  assert (value.getValue() == "NONE" || value.getValue == "COOKIE" || value.getValue == "URL", "Erreur de format");
	  this._use_sessid = value.getValue();
	} else {
	  assert (1!=1, "Erreur de format");
	}
      }
    }

    void _get_controllers (Balise b) {
      foreach (controller ; b.childs) {
	assert (controller.name.name == "controller", "Format du fichier de config invalide : " ~ controller.name.name);
	string controller_name;
	string controller_class;
	foreach (child ; controller.childs) {
	  assert (child.childs.length == 1, "Erreur format");
	  Balise value = child.childs[0];
	  if (child.name.name == "name") {
	    controller_name = value.getValue ();
	  } else if (child.name.name == "class") {
	    controller_class = value.getValue ();
	  } else {
	    //on doit pouvoir faire plus propre ?
	    assert (1 != 1, "Format du fichier de config invalide : " ~ child.name.name);
	  }
	}
	if (controller_name.length > 0 && controller_class.length > 0) {
	  this.controllers[controller_name] = controller_class;
	} else {
	  assert (1 != 1, "format foireux");
	}
      }
    }

    string[string] controllers;
    string _use_sessid;
  }
}