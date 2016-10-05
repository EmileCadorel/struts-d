module servlib.application.Manifest;
import std.outbuffer, std.conv;
import servlib.utils.XMLoader;
import servlib.utils.exception;
import std.stdio;


/**
 Classe permettant la lecture d'un fichier manifest
*/
class Manifest  {

    /**
     Params:
     manifest, le path du fichier manifest
     */
    this (string manifest) {
	this.manifest = manifest;
	this.root = XMLoader.root (manifest);
	this._parse_file ();
    }

    /**
     Return:
     le path du fichier de configuration de l'archive (struts.xml)
     */
    string config () {
	return this._config;
    }

    /**
     Return:
     une liste de path vers les shared object de l'application
     */
    string [] libs () {
	return this._libs;
    }
    
    private {

	void _parse_file () {
	    if (this.root.name.name != "manifest") 
		throw new ManifestError (this.root);
	    foreach (child ; this.root.childs) {
		this._load_data (child);
	    }
	}
	
	void _load_data (Balise b) {
	    if (b.childs.length != 0) throw new ManifestError (b);
	    if (b.name.name == "lib")
		this._load_lib (b);
	    else if (b.name.name == "struts")
		this._load_struts (b);
	    else
		throw new ManifestError (b);
	}

	void _load_lib (Balise b) {
	    if (b.attrs.length == 1) {
		foreach (key, value ; b.attrs) {
		    if (key.name == "path") _libs ~= value;
		    else throw new ManifestError (b);
		}
	    } else throw new ManifestError (b);
	}

	void _load_struts (Balise b) {
	    writeln ("ici");
	    if (b.attrs.length == 1 && config is null) {
		foreach (key, value ; b.attrs) {
		    if (key.name == "path") _config = value;		
		    else throw new ManifestError (b);
		}
	    } else throw new ManifestError (b);
	}
	
	string manifest;
	string _config = null;
	string[] _libs;
	Balise root;
	
    }    
    
}
