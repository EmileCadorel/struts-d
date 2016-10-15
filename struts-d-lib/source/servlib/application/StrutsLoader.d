module servlib.application.StrutsLoader;
import servlib.utils.xml;
import servlib.utils.exception;
import servlib.control.ControllerContainer;
import std.stdio;


/**
 Permet le chargement d'un fichier de type struts.xml
 */
class StrutsLoader {

    /**
     Charge le fichier 
     Params:
     name, le path vers le fichier
     app, le nom de l'application a charger
     */
    static void load (string name, string app) {
	auto root = XMLoader.root (name);
	writeln (name);
	if (root.name.name != "struts")
	    throw new StrutsError (root);
	ApplicationContainer.instance.addApp (app);
	auto current = ApplicationContainer.instance.getApp (app);
	foreach (it; root.childs) {	    
	    if (it.name.name == "package")
		loadPackage (current, it);
	    else if (it.name.name == "action")
		loadAction (current, it);
	    else throw new StrutsError (it);
	}
    }    

    private static void loadPackage (ControllerContainer current, Balise pck, string root="") {
	auto pack = pck["value"];
	if (pack is null) throw new StrutsError (pck);
	else root ~= pack ~ ".";
	foreach (it ; pck.childs) {
	    if (it.name.name == "action")
		loadAction (current, it, root);
	    else if (it.name.name == "package")
		loadPackage (current, it, root);
	    else throw new StrutsError (it);
	}
    }

    private static void loadAction (ControllerContainer current, Balise act, string root="") {
	ControllerInfos info;
	info.def = null;
	info.name = act["name"];
	info.control = act["class"];
	if (info.name is null) throw new StrutsError (act);
	else if (info.control is null) throw new StrutsError (act);
	foreach (it ; act.childs) {
	    if (it.name.name != "result")
		throw new StrutsError (it);
	    else {
		if (it.childs.length == 1 && cast(Text)(it.childs[0]) !is null) {
		    loadResultName (it, info);
		} else if (it.childs.length == 1) {
		    loadRedirectName (it, info);
		} else
		      throw new StrutsError (it);
	    }
	}
	writeln (info.name, " ", info);
	current[info.name] = info;
    }

    private static void loadRedirectName (Balise it, ref ControllerInfos info) {
	auto child = it.childs[0];
	if (child.name.name != "redirect" || child.childs.length > 0) throw new StrutsError (child);
	else {
	    auto val = it["value"];
	    auto action = child["action"];
	    if (action is null) throw new StrutsError (child);
	    if (val is null) {
		if (info.def !is null || info.redirectDef !is null)
		    throw new StrutsError (it);
		info.redirectDef = action;
	    } else {
		info.redirect [val] = action;
	    }
	}
    }
    
    private static void loadResultName (Balise it, ref ControllerInfos info) {
	auto val = it["value"];
	if (val is null) {
	    if (info.def is null) {
		if (info.def !is null || info.redirectDef !is null)
		    throw new StrutsError (it);
		info.def = loadResult (it);
	    } else throw new StrutsError (it);
	} else {
	    if ((val in info.results) !is null)
		throw new StrutsError (it);
	    info.results [val] = loadResult (it);
	}
    }

    private static string loadResult (Balise result) {
	if (result.childs.length != 1) throw new StrutsError (result);
	auto text = cast(Text)result.childs[0];
	if (text is null) throw new StrutsError (result);
	return text.content;	
    }
    
}
