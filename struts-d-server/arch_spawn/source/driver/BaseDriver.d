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

      string controller_name;
      HttpUrl url = request.url;
      if (url.path.length > 0)
	controller_name = url.path[0];

      // on s'emmerde pas avec le favicon demandé à chaque fois...
      if (controller_name == "favicon.ico") {
	controller_name = "";
      }

      ControllerAncestor controller = null;
      ControllerInfos controller_info;
      string app;
      HttpResponseCode code_reponse = HttpResponseCode.OK;

      foreach (key, value; ApplicationContainer.instance.all ()) {
	auto control = value[controller_name];
	if (!control.isNull) {
	  controller = ControllerTable.instance [control.control];
	  controller_info = control;
	  app = key;
	  break;
	}
      }

      if (controller is null) {
	controller = ControllerTable.instance[this.controllers["NotFound"].control];
	controller_info = this.controllers["NotFound"];
	code_reponse = HttpResponseCode.NOT_FOUND;
      }
      writeln (controller.classinfo.name);

      HttpResponse response = this.build_response (request, controller, controller_info, app, code_reponse);
      this.send_response (response);
    }
  }
  /**
     Renvoie une reponse (HttpResponse) en fonction de la requete et du controlleur
  */
  HttpResponse build_response (HttpRequest request, ControllerAncestor controller, ControllerInfos controller_info, string app, HttpResponseCode code_reponse) {
    HttpResponse response = new HttpResponse;
    controller.unpackRequest (request);

    // on check si le dev veut utiliser les cookies pour le sessid
    if (this.config.use_sessid == SessIdState.COOKIE) {
      HttpParameter[string] cookies = request.cookies();
      if ("SESSID" in cookies) {
	this.sessid = cookies["SESSID"].to!string;
      } else {
	this.sessid = this.create_sessid ();
      }
      response.cookies["SESSID"] = this.sessid;
    } else if (this.config.use_sessid == SessIdState.URL) {
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

    string result;
    if (code_reponse == HttpResponseCode.OK) {
      string res = controller.execute();
      string dsp_file;
      auto it = (res in controller_info.results);
      if (it is null) {
	if (controller_info.def is null || strip(controller_info.def) == "") {
	  //TODO throw
	}
	dsp_file = controller_info.def;
      } else {
	dsp_file = *it;
      }
      
      Balise html = HTMLoader.instance.load (dsp_file, app, null);
      OutBuffer buf;
      html.toXml (buf);
      result = buf.toString;
    } else {
      result = controller.execute ();
    }

    response.addContent (result);
    response.code = code_reponse;
    response.proto = "HTTP/1.1";
    response.type = "text/html";

    return response;
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
    Option config;
    string sessid;
    string client_addr;
  }
}
