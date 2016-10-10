module utils.ProcessWaiter;
import std.process;
import core.thread;
import std.stdio;

class ProcessWaiter : Thread {

    this (string arch, Pid pid) {
	super (&run);
	this.pid = pid;
    }

    void run () {
	try {
	    wait (pid);
	    writefln ("%s arch failed", arch);
	} catch (Exception e) {}
    }

    private string arch;
    private Pid pid;    
}
