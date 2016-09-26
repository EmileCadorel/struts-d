import control.Controller;

// On va simplement renvoyer un message basique pour le moment..

class HomeController : Controller {
  string execute () {
    return "<h1 align=\"center\">Home !</h1>
            <form method=\"post\">
            <input type=\"text\" name=\"nom1\"/>
            <input type=\"text\" name=\"nom_3\"/>
            <input type=\"submit\" value=\"send\">
            </form>";
  }
}
