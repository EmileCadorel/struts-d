import std.stdio;
import control.Session;

class A {
    string toString () {
	return "A";
    }    
}

void fill_session (Session session) {
    session["salut"] = new A ();
    session ["comment"] = new int(89);
}

void main (string [] args) {
    Session session = new Session;
    fill_session (session);
    auto res = session.get!A ("salut");
    if (res !is null)
	writeln (res.toString);

    auto b = session.get!int ("comment");
    if (b !is null)
	writeln (*b);
}
