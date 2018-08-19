if test -n "$1";then
    if test "$1" = "--help" || test "$1" = "-h" ;then
        echo \$1:project name.
        echo -e "\tdefault:demo"
        echo \$2:type:app,sharedlib or staticlib
        echo -e "\tdefault:app"
        echo \$3:install directory.
        echo -e "\tdefault:/usr/local"
        exit
    fi
fi

echo "create cpp project."

if test -n "$1";then 
    PROJECT=$1
else 
    PROJECT=demo
fi

if test -n "$2";then
    TYPE=$2
else
    TYPE=app
fi

if test -n "$3";then 
    INSTALL_DIR=$3
else
    INSTALL_DIR=/usr/local
fi

echo "create cpp project $PROJECT Makefile."

mkdir -pv $PROJECT

app_makefile_tpl(){

cat > $PROJECT/Makefile << END

PROJECT=$PROJECT
CPPSRC=\$(shell find . -type f -name *.cpp)
CPPOBJ=\$(patsubst %.cpp,%.o,\$(CPPSRC))
CCSRC=\$(shell find . -type f -name *.cc)
CCOBJ=\$(patsubst %.cc,%.o,\$(CCSRC))
CXXSRC=\$(shell find . -type f -name *.cxx)
CXXOBJ=\$(patsubst %.cxx,%.o,\$(CXXSRC))

CSRC=\$(shell find . -type f -name *.c)
COBJ=\$(patsubst %.c,%.o,\$(CSRC))

OBJ=\$(COBJ) \$(CXXOBJ) \$(CCOBJ) \$(CPPOBJ)

CC=gcc
CXX=g++

CFLAGS+=-O3 -std=c11 -Wall
CXXFLAGS+=-O3 -std=c++11 -Wall
LDLIBS+=

ifndef INSTALL_DIR
INSTALL_DIR=/usr/local
endif


all:\$(PROJECT)

\$(PROJECT):\$(OBJ)
	\$(CXX) \$(LDFLAGS) -o \$@ \$^ \$(LDLIBS) 

.c.o:
	\$(CC) \$(CFLAGS) -c $< -o \$@

.cpp.o:
	\$(CXX) \$(CXXFLAGS)  -c \$< -o \$@

.cc.o:
	\$(CXX) \$(CXXFLAGS)  -c \$< -o \$@
	
.cxx.o:
	\$(CXX) \$(CXXFLAGS)  -c \$< -o \$@

clean:
	@for i in \$(OBJ);do echo "rm -f" \$\${i} && rm -f \$\${i} ;done
	rm -f \$(PROJECT)


install:
	test -d \$(INSTALL_DIR)/ || mkdir -p \$(INSTALL_DIR)/
	install \$(PROJECT) \$(INSTALL_DIR)

END


echo "create app project $PROJECT demo source file."

cat > $PROJECT/$PROJECT.cpp << END

#include <iostream>


int main(int,char**)
{
	std::cout << "hello,world." << std::endl;
    return 0;
}



END
}


sharedlib_makefile_tpl(){

cat > $PROJECT/Makefile << END

PROJECT=lib$PROJECT.so
CPPSRC=\$(shell find . -type f -name *.cpp)
CPPOBJ=\$(patsubst %.cpp,%.o,\$(CPPSRC))
CCSRC=\$(shell find . -type f -name *.cc)
CCOBJ=\$(patsubst %.cc,%.o,\$(CCSRC))
CXXSRC=\$(shell find . -type f -name *.cxx)
CXXOBJ=\$(patsubst %.cxx,%.o,\$(CXXSRC))

CSRC=\$(shell find . -type f -name *.c)
COBJ=\$(patsubst %.c,%.o,\$(CSRC))

OBJ=\$(COBJ) \$(CXXOBJ) \$(CCOBJ) \$(CPPOBJ)

CC=gcc
CXX=g++

CFLAGS+=-O3 -std=c11 -Wall -fPIC
CXXFLAGS+=-O3 -std=c++11 -Wall -fPIC
LDLIBS+=
LDFLAGS+=-shared


ifndef INSTALL_DIR
INSTALL_DIR=/usr/local
endif


all:\$(PROJECT)

\$(PROJECT):\$(OBJ)
	\$(CXX) \$(LDFLAGS) -o \$@ \$^ \$(LDLIBS) 

.c.o:
	\$(CC) \$(CFLAGS) -c $< -o \$@

.cpp.o:
	\$(CXX) \$(CXXFLAGS)  -c \$< -o \$@

.cc.o:
	\$(CXX) \$(CXXFLAGS)  -c \$< -o \$@
	
.cxx.o:
	\$(CXX) \$(CXXFLAGS)  -c \$< -o \$@

clean:
	@for i in \$(OBJ);do echo "rm -f" \$\${i} && rm -f \$\${i} ;done
	rm -f \$(PROJECT)

install:
	test -d \$(INSTALL_DIR)/ || mkdir -p \$(INSTALL_DIR)/
	install \$(PROJECT) \$(INSTALL_DIR)

END


echo "create sharedlib project $PROJECT demo source file."

cat > $PROJECT/$PROJECT.cpp << END

class $PROJECT {
    public:
        $PROJECT()=default;
        virtual~$PROJECT()=default;
};

#ifdef __cplusplus
   extern "C" {
#endif

$PROJECT* create() {
    return new $PROJECT();
}

void destroy($PROJECT* p) {
    delete p;
}

#ifdef __cplusplus
   }
#endif

END
}



staticlib_makefile_tpl(){

cat > $PROJECT/Makefile << END

PROJECT=lib$PROJECT.a
CPPSRC=\$(shell find . -type f -name *.cpp)
CPPOBJ=\$(patsubst %.cpp,%.o,\$(CPPSRC))
CCSRC=\$(shell find . -type f -name *.cc)
CCOBJ=\$(patsubst %.cc,%.o,\$(CCSRC))
CXXSRC=\$(shell find . -type f -name *.cxx)
CXXOBJ=\$(patsubst %.cxx,%.o,\$(CXXSRC))

CSRC=\$(shell find . -type f -name *.c)
COBJ=\$(patsubst %.c,%.o,\$(CSRC))

OBJ=\$(COBJ) \$(CXXOBJ) \$(CCOBJ) \$(CPPOBJ)

CC=gcc
CXX=g++

CFLAGS+=-O3 -std=c11 -Wall
CXXFLAGS+=-O3 -std=c++11 -Wall
LDLIBS+=

ifndef INSTALL_DIR
INSTALL_DIR=/usr/local
endif



all:\$(PROJECT)

\$(PROJECT):\$(OBJ)
	ar rvs \$@ \$^

.c.o:
	\$(CC) \$(CFLAGS) -c $< -o \$@ \$(LDLIBS)

.cpp.o:
	\$(CXX) \$(CXXFLAGS)  -c \$< -o \$@ \$(LDLIBS)

.cc.o:
	\$(CXX) \$(CXXFLAGS)  -c \$< -o \$@ \$(LDLIBS)
	
.cxx.o:
	\$(CXX) \$(CXXFLAGS)  -c \$< -o \$@ \$(LDLIBS)

clean:
	@for i in \$(OBJ);do echo "rm -f" \$\${i} && rm -f \$\${i} ;done
	rm -f \$(PROJECT)

install:
	test -d \$(INSTALL_DIR)/ || mkdir -p \$(INSTALL_DIR)/
	install \$(PROJECT) \$(INSTALL_DIR)

END


echo "create staticlib project $PROJECT demo source file."

cat > $PROJECT/$PROJECT.cpp << END

class $PROJECT {
    public:
        $PROJECT()=default;
        virtual~$PROJECT()=default;
};

#ifdef __cplusplus
   extern "C" {
#endif

$PROJECT* create() {
    return new $PROJECT();
}

void destroy($PROJECT* p) {
    delete p;
}

#ifdef __cplusplus
   }
#endif

END
}



case $TYPE in
    app) app_makefile_tpl;;
    sharedlib) sharedlib_makefile_tpl;;
    staticlib) staticlib_makefile_tpl;;
    *) echo 'Please set TYPE in (app,sharedlib,staticlib)';;
esac


