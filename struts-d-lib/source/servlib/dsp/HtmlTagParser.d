module servlib.dsp.HtmlTagParser;

import servlib.utils.xml;
import servlib.utils.Log;
import servlib.dsp.HTMLoader;
import servlib.control.Session;
import std.stdio;

class HtmlTagParser {
    abstract Balise[] execute (Balise, Balise[] delegate (Balise, string, Session), string, Session);
}

template HtmlTPInsert (string id, T : HtmlTagParser) {
  static this () {
    writeln ("Ajout du parser de balise : " ~ T.classinfo.name);
    HTMLoader.instance.addParser (id, new T);
  }
}

abstract class HtmlInHerit (string id, T) : HtmlTagParser {
  mixin HtmlTPInsert!(id, T);
}
