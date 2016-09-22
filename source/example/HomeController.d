import control.Controller;

// On va simplement renvoyer un message basique pour le moment..

class HomeController : Controller {
  string execute () {
    return "<h1 align=\"center\">Home !</h1>";
  }
}
