module servlib.control.ControllerContainer;
import servlib.control.Controller;
import servlib.utils.Option;
import servlib.utils.xml;
import servlib.utils.Singleton;

/**
 Cette classe est un singleton qui va contenir toutes les controllers des applications
 */
class ApplicationContainer {

    /**
     Return:
     toutes les applications
     */
    ControllerContainer[string] all () {
	return this._controllers;
    }

    /**
     Params:
     le nom de l'application
     Return:
     L'application identifie par son nom, ou null si inexistante
     */
    ControllerContainer getApp (string value) {
	auto it = (value in _controllers);
	if (it is null) return null;
	else return *it;
    }

    /**
     Ajoute une application dans les informations du serveur
     */
    void addApp(string value) {
	this._controllers[value] = new ControllerContainer;
    }

    private ControllerContainer [string] _controllers;
    mixin Singleton!ApplicationContainer;
}


/**
 Permet de stocker les controller charger lors d'un deploiement d'application
 */
class ControllerContainer {

    /**
     Return:
     Un controller identifie par son chemin d'acces (cf: struts.xml)
     */
    ControllerInfos opIndex (string name) {
	auto it = name in this._controllers;
	if (it !is null) return *it;
	else return ControllerInfos.empty;
    }

    /**
     Definis un controller pour un chemin d'acces
     Params:
     value, le controller
     name, le chemin d'acces du controller
     */
    void opIndexAssign (ControllerInfos value, string name) {
	this._controllers[name] = value;
    }

    /**
     Retourne le tableau associatif des controller [chemin d'acces]
     */
    ref ControllerInfos [string] controllers () { return this._controllers; }

    private  {
	ControllerInfos [string] _controllers;
    }

}

/**
 Cette structure encode les informations relative a un controller
 */
struct ControllerInfos {
    /// le chemin d'acces du controller
    string name;

    /// le nom du controller pour pouvoir le retrouver dans la tables
    string control;

    /// Les informations sur le traitement a effectuer apres execution du controller
    string [string] results;

    /// Le traitements a effectuer par default si results ne specifie rien
    string def;

    /// Les informations de redirection a effectuer apres une execution du controller
    string [string] redirect;

    /// La redirection par defaut
    string redirectDef;
    
    /**
     Return:
     un controller identifier comme etant le controller vide
     */
    static ControllerInfos empty () {
	return ControllerInfos(null, null, null, null);
    }

    /**
     Return:
     vrai si this == empty
     */
    bool isNull () {
	return this.name == null;
    }

}
