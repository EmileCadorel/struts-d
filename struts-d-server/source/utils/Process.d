module utils.Process;
import servlib.utils.Singleton;
import std.process;
import std.conv, std.stdio;
import servlib.utils.Log;

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
    }        
        
    void kill (string arch) {
	auto it = (arch in process);
	if (it !is null) {
	    std.process.kill (*it);
	    wait (*it);
	    writefln("Kill arch:%s", arch);
	}
    }

    void killAll () {
	foreach (key, value ; process) {
	    std.process.kill (value);
	    wait (value);
	    writefln("Kill arch:%s", key);
	}
    }
    
    mixin Singleton!ProcessLauncher;

    private immutable string proc = "./arch_spawn/arch_launcher";
    private Pid [string] process;
    private uint [] ports;
    private ulong lastPort = 0;
}
