module driver.BaseDriver;

import std.stdio, std.socket, std.container, std.conv;
import std.digest.md, std.datetime;
import http.HttpSession;
import http.HttpServer;
import http.request;
import http.response;
import utils.Log;
import control.Controller;
import control.NotFoundController;
import control.ControllerContainer;
import utils.XMLoader;
import utils.Option;

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
    controllers = config.controllers;
    log = Log.instance;
  }

  void on_begin (Address addr) {
    this.client_addr = addr.toAddrString();
    log.add_info ("Connexion de " ~ this.client_addr);

    this.start_routine ();
  }

  void on_end () {
    log.add_info ("Deconnexion de " ~ this.client_addr);
  }

  void start_routine () {
    string data = "";
    int status_recv = this.recv_request (data);

    if (status_recv < 0) {
      log.add_err (this.socket.getErrorText());
    } else {
      HttpRequest request = this.toRequest (data);
      log.add_info (this.client_addr ~ " : " ~ to!string(request.http_method) ~ " " ~ request.url.toString());

      string controller_name;
      HttpUrl url = request.url;
      if (url.path.length > 0)
	controller_name = url.path[0];

      // on s'emmerde pas avec le favicon demandé à chaque fois...
      if (controller_name == "favicon.ico") {
	controller_name = "";
      }

      ControllerAncestor controller = ControllerTable.instance[this.controllers[controller_name]];
      if (controller is null) {
	controller = ControllerTable.instance[this.controllers["NotFound"]];
      }

      HttpResponse response = this.build_response (request, controller);
      this.send_response (response);
    }
  }

  /**
     Renvoie une reponse (HttpResponse) en fonction de la requete et du controlleur
  */
  HttpResponse build_response (HttpRequest request, ControllerAncestor controller) {
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
    response.addContent (controller.execute (/*response*/));
    response.code = HttpResponseCode.OK;
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
      log.add_err ("Send response : " ~ this.socket.getErrorText());
  }

  private {
    ControllerContainer controllers;
    Option config;
    string sessid;
    Log log;
    string client_addr;
  }
}
