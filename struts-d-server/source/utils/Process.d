module utils.Process;
import servlib.utils.Singleton;
import std.process;
import std.conv, std.stdio;
import servlib.utils.Log;
import utils.ProcessWaiter;

class ProcessLauncher {

    private this () {
	foreach (it ; 0u .. 10u) {
	    ports ~= [it + 8080u];
	}
    }
    
    void launch (string arch) {
	kill (arch);
	auto pid = spawnProcess ([proc, arch, to!string(ports[lastPort])]);
	lastPort ++;
	lastPort %= ports.length;
	this.process [arch] = pid;
	ProcessWaiter proc = new ProcessWaiter (arch, pid);
	proc.start ();
    }        
        
    void kill (string arch) {
	try {
	    auto it = (arch in process);
	    if (it !is null) {
		std.process.kill (*it);
		wait (*it);
		writefln("Kill arch:%s", arch);
		process.remove (arch);
	    }
	} catch (Exception e) {
	    process.remove (arch);
	}
    }

    void killAll () {
	foreach (key, value ; process) {
	    try {
		std.process.kill (value);		
		wait (value);
		writefln("Kill arch:%s", key);
		process.remove (key);
	    } catch (Exception e) {
		writefln("Kill arch:%s", key);
		process.remove (key);
	    }		
	}	
    }
    
    void remove (string arch) {
	this.process.remove (arch);
    }

    mixin Singleton!ProcessLauncher;

    private immutable string proc = "./arch_spawn/arch_launcher";
    private Pid [string] process;
    private uint [] ports;
    private ulong lastPort = 0;
}
