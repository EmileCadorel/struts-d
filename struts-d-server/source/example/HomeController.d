import control.Controller;

// On va simplement renvoyer un message basique pour le moment..

class HomeController : Controller {
  string execute () {
    string res = "<h1 align=\"center\">Home ! " ~ this.get("test").to!string ~ "</h1>";
    // res ~= "<h2 align=\"center\">Session : " ~ this.session.get("test") ~ "</h2>";
    res ~= "<form method=\"post\">
            <input type=\"text\" name=\"nom1\"/>
            <input type=\"text\" name=\"nom_3\"/>
            <input type=\"submit\" value=\"send\">
            </form>";
    return res;
  }
}
