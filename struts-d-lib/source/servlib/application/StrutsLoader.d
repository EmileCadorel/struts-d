module servlib.application.StrutsLoader;
import servlib.utils.XMLoader;
import servlib.utils.exception;
import servlib.control.ControllerContainer;
import std.stdio;

class StrutsLoader {

    static void load (string name, string app) {
	auto root = XMLoader.root (name);
	writeln (name);
	if (root.name.name != "struts")
	    throw new StrutsError (root);
	ApplicationContainer.instance.addApp (app);
	auto current = ApplicationContainer.instance.getApp (app);
	foreach (it; root.childs) {	    
	    if (it.name.name == "package")
		load_package (current, it);
	    else if (it.name.name == "action")
		load_action (current, it);
	    else throw new StrutsError (it);
	}
    }    

    private static void load_package (ControllerContainer current, Balise pck, string root="") {
	auto pack = pck["value"];
	if (pack is null) throw new StrutsError (pck);
	else root ~= pack ~ ".";
	foreach (it ; pck.childs) {
	    if (it.name.name == "action")
		load_action (current, it, root);
	    else if (it.name.name == "package")
		load_package (current, it, root);
	    else throw new StrutsError (it);
	}
    }

    private static void load_action (ControllerContainer current, Balise act, string root="") {
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
		auto val = it["value"];
		if (val is null) {
		    if (info.def is null) info.def = load_result (it);
		    else throw new StrutsError (it);
		} else {
		    if ((val in info.results) !is null)
			throw new StrutsError (it);
		    else info.results[val] = load_result (it);
		}
	    }
	}
	
	import std.stdio;
	writeln (info.name, " ", info);
	
			  
	current[info.name] = info;
    }

    static string load_result (Balise result) {
	if (result.childs.length != 1) throw new StrutsError (result);
	auto text = cast(Text)result.childs[0];
	if (text is null) throw new StrutsError (result);
	return text.content;	
    }
    
}
