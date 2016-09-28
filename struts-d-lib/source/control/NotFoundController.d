module control.NotFoundController;
import control.Controller;

class NotFoundController : Controller!NotFoundController {
  string execute () {
    return "<h1 align=\"center\">La page que vous demandez n'existe pas !</h1>";
  }
}
