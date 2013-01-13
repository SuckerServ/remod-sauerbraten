#ifndef __REMOD_H__
#define __REMOD_H__

#include "fpsgame.h"

// worlio.cpp
extern void cutogz(char *s);

// remod.cpp
typedef vector<char *> extensionslist;
extern bool addextension(const char *name);
extern const extensionslist* getextensionslist();
char *conc(char **w, int n, bool space);
void reloadauth();

#define EXTENSION(name) bool __dummyext_##name = addextension(#name)

namespace server
{
    void filtercstext(char *str);
    bool checkpban(uint ip);
    void addban(int cn, char* actorname, int expire);
    void addpban(const char *name, const char *reason);
}

namespace remod
{
    using namespace server;

    extern char *mapdir;

    clientinfo* findbest(vector<clientinfo *> &a);
    bool playerexists(int *pcn);
    int parseplayer(const char *arg);
    bool ismaster(int *cn);
    bool isadmin(int *cn);
    bool isspectator(int *cn);
    char* concatpstring(char *d, const char *s);
    void loadbans();
    void writebans();
    bool loadents(const char *fname, vector<entity> &ents, uint *crc);
    bool writeents(const char *mapname, vector<entity> &ents, uint mapcrc);
}
#endif