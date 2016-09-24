module driver.BaseDriver;

import std.stdio, std.socket, std.container, std.conv;
import std.digest.md, std.datetime;
import http.HttpSession;
import http.HttpServer;
import http.HttpRequest;
import http.HttpResponse;
import http.HttpUrl;
import utils.LexerString;
import utils.Log;
import utils.Option;
import control.Controller;
import control.NotFoundController;
import control.ControllerContainer;
import driver.BaseDriverConfig;

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
    config = new Config (Option.instance.config_file_path);
    container = new ControllerContainer (config.get_controllers());
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

  /**
     On va chercher le SESSID dans la première requete (dans le cookie ou dans l'url suivant les options).
     Si il est présent, on va pouvoir utiliser les variables de sessions
     Sinon on va créer une variable de session
  */
  void start_routine () {
    string data = "";
    int status_recv;

    // pour le moment, on garde la dernière page affichée, sinon se tape le favicon.ico qui fait chier
    string last_page = "";
    while ((status_recv = this.recv_request (data)) > 0) {
      HttpRequest request = this.toRequest (data);
      log.add_info (request.proto ~ " " ~ request.url.toString());

      string controller_name;
      HttpUrl url = request.url;
      if (url.path.length > 0)
	controller_name = url.path[0];

      // on s'emmerde pas avec le favicon demandé à chaque fois...
      if (controller_name == "favicon.ico") {
	controller_name = last_page;
      } else {
	last_page = controller_name;
      }

      Controller controller = this.container.get!Controller (controller_name);
      if (controller is null) {
      	controller = new NotFoundController;
      }

      HttpResponse response = this.build_response (request, controller);
      this.send_response (response);
    }
    if (status_recv < 0)
      log.add_err (this.socket.getErrorText());
  }

  /**
     Renvoie une reponse (HttpResponse) en fonction de la requete et du controlleur
  */
  HttpResponse build_response (HttpRequest request, Controller controller) {
    HttpResponse response = new HttpResponse;
    controller.unpackRequest (request);

    writeln ("use sessid : ", config.use_sessid);

    // on check si le dev veut utiliser les cookies pour le sessid
    if (this.config.use_sessid == SessIdState.COOKIE) {
      string[string] cookies = request.cookies();
      if ("SESSID" in cookies) {
	this.sessid = cookies["SESSID"];
      } else {
	this.sessid = this.create_sessid ();
      }
      response.cookies["SESSID"] = this.sessid;
    } else if (this.config.use_sessid == SessIdState.URL) {
      //on utilise l'url
      HttpUrl url = request.url;
      if ("SESSID" in url.params) {
	this.sessid = url.param("SESSID").to!string();
      } else {
	this.sessid = this.create_sessid ();
      }
      response.cookies["SESSID"] = this.sessid;
    }
    response.addContent (controller.execute ());
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
    return str;
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
    Config config;
    ControllerContainer container;
    string sessid;
    Log log;
    string client_addr;
  }
}
