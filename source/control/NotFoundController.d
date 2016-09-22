module control.NotFoundController;
import control.Controller;

class NotFoundController : Controller {
  string execute () {
    return "La page que vous demandez n'existe pas !";
  }
}