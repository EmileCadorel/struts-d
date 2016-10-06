module servlib.control.NotFoundController;
import servlib.control.Controller;

/**
 Classe temporaire
*/
class NotFoundController : Controller!NotFoundController {
    override string execute () {
	return "<h1 align=\"center\">La page que vous demandez n'existe pas !</h1>";
    }
}
