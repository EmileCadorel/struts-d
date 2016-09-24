module driver.BaseDriverConfig;

import utils.XMLoader;

class Config {
  this (string config_file_path) {
    XMLoader xml = new XMLoader (config_file_path);
    Balise b = xml.root();

    assert (b.name.name == "config", "Format du fichier de config invalide : " ~ b.name.name);

    foreach (child ; b.childs) {
      if (child.name.name == "controllers") {
	this._get_controllers (child);
      } else {
	assert (1 != 1, "foireux ici");
      }
    }
  }

  string[string] get_controllers () {
    return this.controllers;
  }

  private {
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
  }
}