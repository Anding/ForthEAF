UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

ifeq ($(UNAME_S),Darwin)
    OS = mac
    ifeq ($(UNAME_M),arm64)
        platform = mac64
    else ifeq ($(UNAME_M),x86_64)
        platform = mac
    else
        platform = mac
    endif
else
    OS = linux
    ifeq ($(UNAME_M),x86_64)
        platform = x64
    else
        platform = x86
    endif
endif

CXX = g++

CFLAGS :=
LDFLAGS :=
LIBS :=

ifeq ($(OS),mac)
    CFLAGS += -std=c++11 -I../../../include
    DEFS += -D_MAC
    SECTFLAGS += -sectcreate __TEXT __info_plist Info.plist
    ifeq ($(platform),mac64)
        CFLAGS += -arch arm64
        LDFLAGS += -L../../../lib/mac64 \
                   -lEAFFocuser \
                   -Wl,-rpath,@executable_path/../../../lib/mac64
    else
        CFLAGS += -arch x86_64
        LDFLAGS += -L../../../lib/mac \
                   -lEAFFocuser \
                   -Wl,-rpath,@executable_path/../../../lib/mac
    endif
    LDFLAGS += -framework IOKit -framework CoreFoundation -framework AppKit -framework CoreBluetooth -framework Foundation -lstdc++

else ifeq ($(OS),linux)
    CFLAGS += -std=c++11 -I../../../include
    ifeq ($(platform),x86)
        CFLAGS += -m32
        LDFLAGS += -L../../../lib/x86 \
                   -lEAFFocuser \
                   -lpthread \
                   -ludev \
                   -Wl,-rpath=../../../lib/x86 \
                   -ldl
    else ifeq ($(platform),x64)
        CFLAGS += -m64
        LDFLAGS += -L../../../lib/x64 \
                   -lEAFFocuser \
                   -lpthread \
                   -ludev \
                   -Wl,-rpath=../../../lib/x64 \
                   -ldl
    endif
endif

all: PREPARE test_console

PREPARE:
ifeq ($(OS),mac)
	-rm -f ./libEAFFocuser.*
	-cp ../../../lib/$(platform)/libEAFFocuser.* ./
else
	-rm -f ./lib/*
	-cp ../../../lib/$(platform)/* ./lib/
endif

test_console: main.cpp
ifeq ($(OS),mac)
	$(CXX) main.mm -o test_console $(DEFS) $(CFLAGS) ../../../lib/$(platform)/libEAFFocuser.dylib $(LDFLAGS) -lpthread $(SECTFLAGS)
else
	$(CXX) main.cpp -o test_console $(CFLAGS) $(LDFLAGS)
endif
	-mkdir -p bin/$(platform)/
	cp test_console bin/$(platform)/

clean:
	-rm -f test_console
