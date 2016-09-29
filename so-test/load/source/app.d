import core.stdc.stdio;
import core.stdc.stdlib;
import core.sys.posix.dlfcn;
import std.conv;

class Test {
    this (int a) {
	this.a = a;
    }
    
    int a;

    string toString () {
	return "Ici:Test2 " ~ to!string(a);
    }
}

void main(string [] args) {
    printf("+main()\n");

    void* lh = dlopen(args[1].ptr, RTLD_LAZY);
    if (!lh)
    {
        fprintf(stderr, "dlopen error: %s\n", dlerror());
        exit(1);
    }
    printf("libdll.so is loaded\n");

    int function(Test) fn = cast(int function(Test))dlsym(lh, "load");
    char* error = dlerror();
    if (error)
    {
        fprintf(stderr, "dlsym error: %s\n", error);
        exit(1);
    }
    printf("dll() function is found\n");

    fn(new Test(10));

    printf("unloading libdll.so\n");
    dlclose(lh);

    printf("-main()\n");
    exit (0);
}
