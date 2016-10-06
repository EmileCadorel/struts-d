module servlib.utils.xmlmod.Location;

/**
 Un emplacement dans un fichier XML
 */
struct Location {
    string filename;
    long line;
    long column;
}
