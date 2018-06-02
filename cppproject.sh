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

cat << END                                                     > $PROJECT/Makefile

PROJECT=$PROJECT
SRC=\$(shell find . -type f | egrep *.cpp\$\$)
OBJ=\$(patsubst %.cpp,%.o,\$(SRC))
CSRC=\$(shell find . -type f | egrep *.c\$\$)
COBJ=\$(patsubst %.c,%.O,\$(CSRC))

ifndef INSTALL_DIR
INSTALL_DIR=/usr/local
endif

CC=gcc
CFLAGS+=-O3 -std=c11 -Wall
CXX=g++ 
CXXFLAGS+=-O3 -std=c++11 -Wall
LDLIBS+=


all:\$(PROJECT)

%.o:%.cpp
	\$(CXX) \$(CXXFLAGS) -c -o \$@ \$<

%.O:%.c
	\$(CC) \$(CFLAGS) -c -o \$@ \$<

\$(PROJECT): \$(COBJ) \$(OBJ)
	\$(CXX)  -o \$@ \$^ \$(LDLIBS)

clean:
	rm -f  \$(COBJ) \$(OBJ) \$(PROJECT)

install:
	test -d \$(INSTALL_DIR)/ || mkdir -p \$(INSTALL_DIR)/
	install \$(PROJECT) \$(INSTALL_DIR)

END


echo "create app project $PROJECT demo source file."

cat << END                                                     > $PROJECT/$PROJECT.cpp

#include <iostream>


int main(int,char**)
{
    std::cout << "hello,world" << std::endl;
    return 0;
}



END
}


sharedlib_makefile_tpl(){

cat << END                                                     > $PROJECT/Makefile

PROJECT=lib$PROJECT.so
SRC=\$(shell find . -type f | egrep *.cpp\$\$)
OBJ=\$(patsubst %.cpp,%.o,\$(SRC))
CSRC=\$(shell find . -type f | egrep *.c\$\$)
COBJ=\$(patsubst %.c,%.O,\$(CSRC))

ifndef INSTALL_DIR
INSTALL_DIR=/usr/local
endif

CC=gcc
CFLAGS+=-O3 -std=c11 -Wall
CXX=g++ 
CXXFLAGS+=-O3 -std=c++11 -fPIC -Wall
LDLIBS+=
LDFLAGS+=-shared

all:\$(PROJECT)

%.o:%.cpp
	\$(CXX) \$(CXXFLAGS) \$(LDFLAGS) -c -o \$@ \$<

%.O:%.c
	\$(CC) \$(CFLAGS) \$(LDFLAGS) -c -o $@ $<

\$(PROJECT): \$(COBJ)  \$(OBJ)
	\$(CXX) \$(LDFLAGS) -o \$@ \$^ \$(LDLIBS) 

clean:
	rm -f  \$(COBJ) \$(OBJ)  \$(PROJECT)

install:
	test -d \$(INSTALL_DIR)/ || mkdir -p \$(INSTALL_DIR)/
	install \$(PROJECT) \$(INSTALL_DIR)

END


echo "create sharedlib project $PROJECT demo source file."

cat << END                                                     > $PROJECT/$PROJECT.cpp

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

cat << END                                                     > $PROJECT/Makefile

PROJECT=lib$PROJECT.a
SRC=\$(shell find . -type f | egrep *.cpp\$\$)
OBJ=\$(patsubst %.cpp,%.o,\$(SRC))
CSRC=\$(shell find . -type f | egrep *.c\$\$)
COBJ=\$(patsubst %.c,%.O,\$(CSRC))

ifndef INSTALL_DIR
INSTALL_DIR=/usr/local
endif

CC=gcc
CFLAGS+=-O3 -std=c11 -Wall
CXX=g++ 
CXXFLAGS+=-O3 -std=c++11 -Wall -I\$(INSTALL_DIR)/include
LDLIBS+=


all:\$(PROJECT)

%.o: %.cpp
	\$(CXX) \$(CXXFLAGS) -c -o \$@ \$< \$(LDLIBS) 

%.O:%.c
	\$(CC) \$(CFLAGS) -c -o $@ $< \$(LDLIBS)

\$(PROJECT): \$(COBJ) \$(OBJ)
	ar rvs \$@ \$^
    

clean:
	rm -f  \$(OBJ) \$(PROJECT)

install:
	test -d \$(INSTALL_DIR)/ || mkdir -p \$(INSTALL_DIR)/
	install \$(PROJECT) \$(INSTALL_DIR)

END


echo "create staticlib project $PROJECT demo source file."

cat << END                                                     > $PROJECT/$PROJECT.cpp

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
