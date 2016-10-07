module example.HomeController;
import servlib.control.Controller;
import servlib.dsp.HTMLoader;

// On va simplement renvoyer un message basique pour le moment..

class HomeController : Controller!HomeController {
  override string execute () {
    auto it = this.get ("test");
    if (!it.isVoid) {
      return "<h1 align=\"center\">Home ! " ~ this.get("test").to!string ~ "</h1>
            <form method=\"post\">
            <input type=\"text\" name=\"nom1\"/>
            <input type=\"text\" name=\"nom_3\"/>
            <input type=\"submit\" value=\"send\">
            </form>";
    } else return "<h1 align=\"center\">Home !</h1>
            <form method=\"post\">
            <input type=\"text\" name=\"nom1\"/>
            <input type=\"text\" name=\"nom_3\"/>
            <input type=\"submit\" value=\"send\">
            </form>";
  }
}
