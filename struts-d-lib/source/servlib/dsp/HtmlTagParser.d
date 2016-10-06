module servlib.dsp.HtmlTagParser;
import servlib.utils.XMLoader;
import servlib.utils.Log;
import servlib.dsp.HTMLoader;
import servlib.control.Session;
import std.stdio;

class HtmlTagParser {
  abstract Balise[] execute (Balise, Balise[] function (Balise, Session), Session);
}

template HtmlTPInsert (string id, T : HtmlTagParser) {
  static this () {
    Log.instance.add_info ("Ajout du parser de balise : " ~ T.classinfo.name);
    HTMLoader.addParser (id, new T);
  }
}

abstract class HtmlInHerit (string id, T) : HtmlTagParser {
  mixin HtmlTPInsert!(id, T);
}
