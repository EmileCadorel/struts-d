import std.stdio, std.socket, std.container;
import utils.XMLoader;

void main (string[] args) {
    XMLoader loader = new XMLoader (args[1]);
    auto balise = loader.root;
    writeln (balise.toString ());
}
