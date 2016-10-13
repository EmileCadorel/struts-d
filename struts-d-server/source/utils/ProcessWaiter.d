module utils.ProcessWaiter;
import std.process;
import core.thread;
import std.stdio;
import utils.Process;

class ProcessWaiter : Thread {

    this (string arch, Pid pid) {
	super (&run);
	this.pid = pid;
	this.arch = arch;
    }

    void run () {
	try {
	    wait (pid);
	    ProcessLauncher.instance.remove (arch);
	    writefln ("%s arch failed", arch);
	} catch (Exception e) {}
    }

    private string arch;
    private Pid pid;    
}
