
CC=gdc
CFLAGS= -W -Wall 
LDFLAGS=-fPIC -shared
EXEC=app.so
SRC= $(wildcard source/*.d)
OBJ= $(SRC:source/.d=.o)

all: $(EXEC)

app.so: $(OBJ)
	@$(CC) $(CFLAGS) -I ../../struts-d-lib/client-addon/source/:../../struts-d-lib/source/ ../../struts-d-lib/libstruts-dlib.a ../../struts-d-lib/client-addon/libclient-addon.a -o $@ $^ $(LDFLAGS) -lphobos2  -nodefaultlibs

.PHONY: clean mrproper

clean:
	@rm -rf *.o

mrproper: clean
	@rm -rf $(EXEC)
