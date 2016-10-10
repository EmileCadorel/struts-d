module utils.Process;
import servlib.utils.Singleton;
import std.process;

class ProcessLauncher {

    private this () {}
    
    void launch (string arch) {
	auto pid = spawnProcess ([proc, arch]);
	this.process [arch] = pid;
    }        
        
    void kill (string arch) {
	auto it = (arch in process);
	if (it !is null) {
	    std.process.kill (*it);
	    wait (*it);
	}
    }

    mixin Singleton!ProcessLauncher;

    private immutable string proc = "./arch_spawn/arch_launcher";
    private Pid [string] process;    
}
