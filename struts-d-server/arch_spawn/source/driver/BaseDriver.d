module driver.BaseDriver;

import std.stdio, std.socket, std.container, std.conv;
import std.digest.md, std.datetime, std.string, std.outbuffer;
import http.HttpSession;
import http.HttpServer;
import servlib.http.request;
import servlib.http.response;
import servlib.utils.Log;
import servlib.control.Controller;
import servlib.control.NotFoundController;
import servlib.control.ControllerContainer;
import servlib.control.Session;
import servlib.utils.xml;
import servlib.utils.Option;
import servlib.utils.SoLoader;
import servlib.dsp.HTMLoader;
import http.SessionCreator;

/**
   Driver de base pour ce serveur web
   Prend en charge les sessions:
   On va chercher la session via un cookie ou une donnée de l'url (selon config)
   Se base sur un fichier de config pour aller chercher les controlleurs de l'utilisateur (chemin du fichier dans singleton Option)
   On enregistre toute l'activité via un fichier de log (chemin donné dans le singleton Option)
*/
class BaseDriver : HttpSession {

    this (Socket socket) {
	super (socket);
	config = Option.instance;
	controllers = Option.instance.controllers;
    }

    override void on_begin (Address addr) {
	try {
	    this.client_addr = addr.toAddrString();
	    Log.instance.addInfo ("Connexion de ", this.client_addr);
	    this.start_routine ();
	} catch (Exception e) {
	    writeln (e.toString());
	}
    }

    override void on_end () {
	Log.instance.addInfo ("Deconnexion de ", this.client_addr);
    }

    void start_routine () {
	string data = "";
	int status_recv = this.recv_request (data);

	if (status_recv < 0) {
	    Log.instance.addError (this.socket.getErrorText());
	} else {
	    HttpRequest request = this.toRequest (data);
	    Log.instance.addInfo (this.client_addr, " : ", to!string(request.http_method), " ", request.url.toString());
	    this.handleRequest (request);
	}
    }

    /*
      Prend en charge la requete recue
    */
    void handleRequest (HttpRequest request) {
	string controller_name;
	HttpUrl url = request.url;
	if (url.path.length > 0)
	    controller_name = url.path[0];

	// TODO
	// on s'emmerde pas avec le favicon demandé à chaque fois...
	if (controller_name == "favicon.ico") {
	    controller_name = "";
	}

	this.send_response (redirect (request, controller_name));
    }

    /**
       Prend en paramètre le nom du controlleur demandé, et renseigne les autres paramètres si possible
    */
    void getController (string action, ref ControllerAncestor controller, ref ControllerInfos controller_info, ref string app) {
	controller = null;
	if (action == "") {
	    foreach (key, value; ApplicationContainer.instance.all ()) {
		if (!value.def.isNull) {
		    auto typeinfo = ControllerTable.instance [value.def.control];
		    controller = cast(ControllerAncestor) (Object.factory (typeinfo.name));
		    controller_info = value.def;
		    app = key;
		    return;
		}
	    }	    
	}
	else 
	    foreach (key, value; ApplicationContainer.instance.all ()) {
		auto control = value [action];
		if (!control.isNull) {
		    auto typeinfo = ControllerTable.instance [control.control];
		    controller = cast(ControllerAncestor) (Object.factory (typeinfo.name));
		    controller_info = control;
		    app = key;
		    break;
		} 
	    }	
    }

    /**
       Renvoie une reponse (HttpResponse) en fonction de la requete et du controlleur
    */
    HttpResponse build_response (HttpRequest request, ControllerAncestor controller, ControllerInfos controller_info, string app, HttpResponseCode response_code) {
	HttpResponse response = new HttpResponse;
	controller.unpackRequest (request);

	this.handleSessid (request, response);
	this.session = SessionCreator.instance.getSession (this.sessid);	
	controller.setSession (session);
	
	string content;
	if (response_code == HttpResponseCode.OK) {
	    string res = controller.execute();
	    auto it = (res in controller_info.results);
	    auto it2 = (res in controller_info.redirect);
	    writeln (controller_info.results);
	    
	    if (it !is null) {
		content = getContent (controller, controller_info, app, *it);
	    } else if (it2 !is null) {
		controller.packRequest (request);
		return redirect (request, *it2);
	    } else if (controller_info.def !is null) {
		content = getContent (controller, controller_info, app, controller_info.def);
	    } else if (controller_info.redirectDef !is null) {
		controller.packRequest (request);
		return redirect (request, controller_info.redirectDef);
	    } else
		throw new Exception ("Pas de traitement pour le resultat " ~ res ~ " dans l'action " ~ controller_info.name);
	}    
		
	response.addContent (content);
	response.code = response_code;
	response.proto = "HTTP/1.1";
	response.type = "text/html";

	return response;
    }

    HttpResponse redirect (HttpRequest request, string action) {
	ControllerAncestor controller = null;
	ControllerInfos controller_info;
	string app;
	HttpResponseCode code_reponse = HttpResponseCode.OK;

	this.getController (action, controller, controller_info, app);

	if (controller is null) {
	    auto controllerInfo = ControllerTable.instance[this.controllers["NotFound"].control];
	    writeln (controllerInfo.name);
	    controller = cast(ControllerAncestor) (Object.factory (controllerInfo.name));
	    controller_info = this.controllers["NotFound"];
	    code_reponse = HttpResponseCode.NOT_FOUND;
	}

	return this.build_response (request, controller, controller_info, app, code_reponse);	
    }
    
    /**
       On vérifie comment sont configurées les variables de session et on met à jour la reponse si nécessaire
     */
    void handleSessid (HttpRequest request, HttpResponse response) {
	if (this.config.use_sessid == SessIdState.COOKIE) {
	    HttpParameter[string] cookies = request.cookies();
	    if ("SESSID" in cookies) {
		this.sessid = cookies["SESSID"].to!string;
	    } else {
		this.sessid = this.create_sessid ();
	    }
	    response.cookies["SESSID"] = this.sessid;
	} else if (this.config.use_sessid == SessIdState.URL) {
	    /// TODO: quand le client veut que le sessid soit dans l'url, le système de génération d'url devra y avoit accès pour ajouter le sessid dans chaque url générée
	    if (this.sessid.length == 0) {
		HttpUrl url = request.url;
		HttpParameter sessid = url.param("SESSID");
		if (!sessid.isVoid) {
		    this.sessid = sessid.to!string;
		} else {
		    this.sessid = this.create_sessid ();
		}
	    }
	}
    }

    /**
       Va chercher le contenu à renvoyer au client en fonction du code de réponse et du controlleur
       Si le code de réponse est OK on va chercher la page dsp indiquée dans le controller_info
     */
    string getContent (ControllerAncestor controller, ControllerInfos controller_info, string app, string dsp_file) {
	Balise html = HTMLoader.instance.load (dsp_file, app, controller);
	OutBuffer buf;
	html.toXml (buf);
	return buf.toString;
    }

    /**
       Renvoie un nouvel identifiant de session
    */
    string create_sessid () {
	SysTime date = Clock.currTime ();
	string str = to!string(date.day) ~
	    to!string(date.month) ~
	    to!string(date.hour) ~
	    to!string(date.minute) ~
	    to!string(date.second);
	ubyte[16] hash = md5Of (str);
	string sessid = "";
	foreach (ubyte n ; hash) {
	    sessid ~= to!string(n);
	}
	return sessid;
    }

    /**
       Renvoie un objet de type 'HttpRequest' en fonction des données recues
    */
    HttpRequest toRequest (string data) {
	return HttpRequestParser.parser (data);
    }

    /**
       Met à jour le paramètre 'data' avec les données recues
       Renvoie le nombre d'octets lu, ou bien 0 (client deconnecte) ou bien code d'erreur
    */
    int recv_request (ref string data) {
	byte[] total;
	while (true) {
	    byte[] buffer;
	    buffer.length = 256;
	    auto length = this.socket.receive (buffer);
	    total ~= buffer;
	    if (length <= 0) {
		return cast(int)length;
	    } else if (length < 256) {
		data = cast(string)total;
		return 1;
	    }
	}
    }

    /**
       Envoie requete de reponse au client en fonction du paramètre HttpResponse
    */
    void send_response (HttpResponse response) {
	auto error = this.socket.send (response.enpack());
	if (error == Socket.ERROR)
	    Log.instance.addError ("Send response : ", this.socket.getErrorText());
    }

    private {
	ControllerContainer controllers;
	Session session;
	Option config;
	string sessid;
	string client_addr;
    }
}
