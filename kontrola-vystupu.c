#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * Vylepšená verze skriptu 'kontrola-vystupu.sh' a přepsaná do C.
 * Měla by zpracovávat vstupy stejně, jako originální skript (čte z stdinu), ale nic neslibuju.
 * Řádky delší než 64 znaků rozdělí na 2 (takže nespadne, ale bere je jako chybu), ale pokud
 * máte korektní řešení, neměl by žádný řádek být tak dlouhý, dokud teda nemáte ve výstupu více
 * jak 100M řádků.
 *
 * Kód není hezký :smrckaBat:, ale nebudu dávat více času psaní testů, než tomu projektu :D.
 * 
 * Tento program kotroluje vše jako 'kontrola-vystupu.sh' + kontroluje čísla řádků, jestli každý
 * zákazník a uředník začal a a šel domů. Také kontroluje jestli se vyprázdnily všechny řady. 
 * 
 * Dále se snaží najít problémy jako, zákazník začal 2x, nebo šel domů i přesto, že čekal v řadě a 
 * nebyl zavolán.
 * 
 * Navíc je to napsané v C, takže to zvládne jet i normální rychlostí.
 *
 * Pokud bude nějaký problém, tak mě tagněte na discordu @Tiger.CZ#1728, ale neslibuju, že něco budu 
 * fixovat :D (Use at your own risk)
 *
 * Když program nic nevypíše, tak nenašel žádný problém.
 *
 * Compile with: gcc -std=gnu99 -Wall -Wextra -pedantic -Werror kontrola-vystupu.c -o kontrola-vystupu
 * (klidně si přidejte -O2, nebo co potřebujete)
 * 
 * Run with: ./kontrola-vystupu NZ NU <input
 **/

#define format_error(c) if (c) { printf("%d: Line format error: %s", __LINE__, buffer); err = 1; continue; }
#define format_number(c) format_error(buffer[c] < '0' || buffer[c] > '9'); i++
#define eprintf(format, ...) fprintf(stderr, "ERROR on line %d: " format, tmp[0], ##__VA_ARGS__)

#define last_line_macro()                                                               \
        if (tmp[0] != last_line + 1) {                                                  \
            eprintf("Invalid line number: %d. Expected %d\n", tmp[0], last_line + 1);   \
        };                                                                              \
        last_line = tmp[0]                                                              \

#define out_of_range(max, c)                              \
        if (tmp[1] <= 0 || tmp[1] > max) {                \
            eprintf("%c out of range: %d\n", c, tmp[1]);  \
            continue;                                     \
        }                                                 \

// 64 by mělo stačil i pro nejdelší řádky, pokud máte korektní řešení a nedostnete se k více než 100M řádkům
#define MAX_LINE_LEN 64

#define found(x) vars[x] = 1; current_type = x; break


enum line_types {
    Z_STARTED = 0, 
    Z_IN,      
    Z_CALLED,  
    Z_HOME,    
    U_START,   
    U_HOME,    
    U_BREAK,   
    U_BREAKF,  
    U_SERVING, 
    U_SERVINGF,
    CLOSING,
    COUNT_TYPES    
};


struct Z {
    int started;
    int in;
    int called;
    int home;
};

struct U {
    int started;
    int on_break;
    int serving;
    int home;
};

int NZ;
int NU;


int handle_arguments(int argc, char *argv[]) {
    if (argc != 3) return -1;
    if (argv[1][0] < '0' || argv[1][0] > '9') return -1;
    if (argv[2][0] < '0' || argv[1][0] > '9') return -1;
    NZ = atoi(argv[1]);
    NU = atoi(argv[2]);
    if (NU <= 0 || NZ < 0) return -1;
    return 0;
}

int main(int argc, char *argv[]) {
    if (handle_arguments(argc, argv) == -1) {
        printf("Invalid aruguments, closing program\n");
        printf("Usage: %s NZ NU\n", argv[0]);
        return 1;
    }
        
    char vars[COUNT_TYPES] = {0};
    struct Z z[NZ];
    struct U u[NU];
    memset(z, 0, sizeof(z));
    memset(u, 0, sizeof(u));


    int last_line = 0;
    int queues[3] = {0};

    int err = 0;
    char buffer[MAX_LINE_LEN]; 

    while(fgets(buffer, sizeof(buffer), stdin) != NULL) {
        int i = 0;
        enum line_types current_type = COUNT_TYPES;
        
        format_number(i);

        while (buffer[i] >= '0' && buffer[i] <= '9') i++;
        
        format_error(buffer[i++] != ':');
        format_error(buffer[i++] != ' ');

        switch(buffer[i++]) {
            case 'Z':
                format_error(buffer[i++] != ' ');
                format_number(i);

                while (buffer[i] >= '0' && buffer[i] <= '9') i++;

                format_error(buffer[i++] != ':');
                format_error(buffer[i++] != ' ');

                switch (buffer[i]) {
                    case 's':
                        format_error(strcmp(&buffer[i], "started\n"));
                        found(Z_STARTED);

                    case 'e':
                        format_error(strncmp(&buffer[i], "entering office for a service ", 30));
                        i+= 30;
                        format_error(buffer[i] < '1' || buffer[i] > '3');
                        format_error(buffer[++i] != '\n');
                        found(Z_IN);

                    case 'c':
                        format_error(strcmp(&buffer[i], "called by office worker\n"));
                        found(Z_CALLED);

                    case 'g':
                        format_error(strcmp(&buffer[i], "going home\n"));
                        found(Z_HOME); 

                    default:
                        format_error(1);
                        break;
                    }
                break;
            
            case 'U':
                format_error(buffer[i++] != ' ');
                format_number(i);

                while (buffer[i] >= '0' && buffer[i] <= '9') i++;

                format_error(buffer[i++] != ':');
                format_error(buffer[i++] != ' ');

                switch (buffer[i]) {
                    case 's':
                        if (buffer[++i] == 't') {
                            format_error(strcmp(&buffer[++i], "arted\n")); //started
                            found(U_START);

                        }

                        format_error(strncmp(&buffer[i-1], "servi", 5));
                        i += 4;
                        if (buffer[i] == 'n') {
                            format_error(strncmp(&buffer[++i], "g a service of type ", 20));
                            i+= 20;
                            format_error(buffer[i] < '1' || buffer[i] > '3');
                            format_error(buffer[++i] != '\n');
                            found(U_SERVING);

                        }

                        format_error(strcmp(&buffer[i], "ce finished\n"));
                        found(U_SERVINGF);


                    case 'g':
                        format_error(strcmp(&buffer[i], "going home\n"));
                        found(U_HOME);

                    case 't':
                        format_error(strcmp(&buffer[i], "taking break\n"));
                        found(U_BREAK);

                    case 'b':
                        format_error(strcmp(&buffer[i], "break finished\n"));
                        found(U_BREAKF);


                    default:
                        format_error(1);
                        break;
                    }

                break;

            case 'c':
                format_error(strcmp(&buffer[i-1], "closing\n"));
                found(CLOSING);
            
            default:
                format_error(1);
                break;
        }

        switch (current_type) {
            int tmp[3];
            case Z_STARTED:
                sscanf(&buffer[0], "%d: Z %d", &tmp[0], &tmp[1]);
                last_line_macro();
                out_of_range(NZ, 'Z');

                if (z[tmp[1]-1].started) {
                    eprintf("Z %d started twice\n", tmp[1]);
                }
                z[tmp[1]-1].started = 1;
                break;

            case Z_IN:
                sscanf(&buffer[0], "%d: Z %d: entering office for a service %d", &tmp[0], &tmp[1], &tmp[2]);
                last_line_macro();
                out_of_range(NZ, 'Z');

                if (z[tmp[1] - 1].started == 0) {
                    eprintf("Z %d not started, but got in the office\n", tmp[1]);
                }
                if (vars[CLOSING] == 1) {
                    eprintf("Z %d post already closed, but got in the office\n", tmp[1]);
                }
                if (z[tmp[1]-1].in != 0) {
                    eprintf("Z %d already in office, but got in twice\n", tmp[1]);
                }
                z[tmp[1]-1].in = tmp[2];
                queues[tmp[2]-1]++;
                break;

            case Z_CALLED:
                sscanf(&buffer[0], "%d: Z %d", &tmp[0], &tmp[1]);
                last_line_macro();
                out_of_range(NZ, 'Z');

                if (z[tmp[1] - 1].started == 0) {
                    eprintf("Z %d not started, but got called\n", tmp[1]);
                }
                if (z[tmp[1]-1].in == 0) {
                    eprintf("Z %d wasn't in office, but got called\n", tmp[1]);
                }
                if (z[tmp[1]-1].called) {
                    eprintf("Z %d already called\n", tmp[1]);
                }
                z[tmp[1]-1].called = 1;
                break;

            case Z_HOME:
                sscanf(&buffer[0], "%d: Z %d", &tmp[0], &tmp[1]);
                last_line_macro();
                out_of_range(NZ, 'Z');

                if (z[tmp[1] - 1].started == 0) {
                    eprintf("Z %d not started, but got home\n", tmp[1]);
                }

                if (z[tmp[1]-1].in != 0 && z[tmp[1]-1].called == 0) {
                    eprintf("Z %d did enter the office for job %d, but never got called, and its going home\n", tmp[1], z[tmp[1]-1].in);
                }
                if (vars[CLOSING] == 0 && z[tmp[1]-1].called == 0) {
                    eprintf("Z %d gone home even though it wasn't called and the post is still opened.\n", tmp[1]);
                }

                if (z[tmp[1]-1].home) {
                    eprintf("Z %d gone home twice\n", tmp[1]);
                }
                z[tmp[1]-1].home = 1;
                break;

            case U_START:
                sscanf(&buffer[0], "%d: U %d", &tmp[0], &tmp[1]);
                last_line_macro();
                out_of_range(NU, 'U');

                if (u[tmp[1] - 1].started) {
                    eprintf("U %d started twice\n", tmp[1]);
                }
                u[tmp[1]-1].started = 1;
                break;

            case U_BREAK:
                sscanf(&buffer[0], "%d: U %d", &tmp[0], &tmp[1]);
                last_line_macro();
                out_of_range(NU, 'U');

                if (u[tmp[1]-1].started == 0) {
                    eprintf("U %d not started, but got on break\n", tmp[1]);
                }
                if (vars[CLOSING] == 1) {
                    eprintf("U %d post already closed, but got on break\n", tmp[1]);
                }

                if (u[tmp[1]-1].on_break) {
                    eprintf("U %d already on break\n", tmp[1]);
                }
                u[tmp[1]-1].on_break = 1;
                break;

            case U_BREAKF:
                sscanf(&buffer[0], "%d: U %d", &tmp[0], &tmp[1]);
                last_line_macro();
                out_of_range(NU, 'U');

                if (u[tmp[1]-1].started == 0) {
                    eprintf("U %d not started, but finished break\n", tmp[1]);
                }
                if (u[tmp[1]-1].on_break == 0) {
                    eprintf("U %d already off break\n", tmp[1]);
                }
                u[tmp[1]-1].on_break = 0;
                break;

            case U_SERVING:
                sscanf(&buffer[0], "%d: U %d: serving a service of type %d", &tmp[0], &tmp[1], &tmp[2]);
                last_line_macro();
                out_of_range(NU, 'U');

                if (u[tmp[1]-1].started == 0) {
                    eprintf("U %d not started, but is serving\n", tmp[1]);
                }
                
                if (u[tmp[1]-1].serving) {
                    eprintf("U %d already serving\n", tmp[1]);
                }

                if (u[tmp[1]-1].on_break) {
                    eprintf("U %d is on break, but is also serving\n", tmp[1]);
                }

                u[tmp[1]-1].serving = 1;
                queues[tmp[2]-1]--;
                break;

            case U_SERVINGF:
                sscanf(&buffer[0], "%d: U %d ", &tmp[0], &tmp[1]);
                last_line_macro();
                out_of_range(NU, 'U');

                if (u[tmp[1]-1].started == 0) {
                    eprintf("U %d not started, but finished serving\n", tmp[1]);
                }

                if (u[tmp[1]-1].on_break) {
                    eprintf("U %d can't finish serving and be on break in the same time\n", tmp[1]);
                }

                if (u[tmp[1]-1].serving == 0) {
                    eprintf("U %d wasn't serving - but finished serving\n", tmp[1]);
                }

                u[tmp[1]-1].serving = 0;
                break;

            case U_HOME:
                sscanf(&buffer[0], "%d: U %d", &tmp[0], &tmp[1]);
                last_line_macro();
                out_of_range(NU, 'U');

                if (u[tmp[1]-1].started == 0) {
                    eprintf("U %d not started, but got home\n", tmp[1]);
                }

                if (u[tmp[1]-1].on_break) {
                    eprintf("U %d is on break, but got home\n", tmp[1]);
                }

                if (u[tmp[1]-1].serving) {
                    eprintf("U %d is serving, but got home\n", tmp[1]);
                }

                if (u[tmp[1]-1].home) {
                    eprintf("U %d already home\n", tmp[1]);
                }
                
                u[tmp[1]-1].home = 1;
                break;

            case CLOSING:
                sscanf(&buffer[0], "%d: closing", &tmp[0]);
                last_line_macro();
                break;

            default:
                fprintf(stderr, "UNREACHABLE: %s:%d\n Tried so hard and got so far and in the end it doesn't even matter.\n", __FILE__, __LINE__);
                exit(1);
                break;
        }
    }


    if (!vars[Z_STARTED])  printf("WARNING: no Z started\n");
    if (!vars[Z_IN])       printf("WARNING: no Z entering office\n");
    if (!vars[Z_CALLED])   printf("WARNING: no Z called by office worker\n");
    if (!vars[Z_HOME])     printf("WARNING: no Z going home\n");
    if (!vars[U_START])    printf("WARNING: no U started\n");
    if (!vars[U_BREAK])    printf("WARNING: no U taking break\n");
    if (!vars[U_BREAKF])   printf("WARNING: no U finishing break\n");
    if (!vars[U_SERVING])  printf("WARNING: no U serving a service\n");
    if (!vars[U_SERVINGF]) printf("WARNING: no U finished a service\n");
    if (!vars[U_HOME])     printf("WARNING: no U going home\n");
    if (!vars[CLOSING])    printf("WARNING: no closing\n");


    for (int i = 0; i < NZ; i++) {
        if (z[i].started == 0) printf("ERROR: Z %d didn't start\n", i + 1);
        if (z[i].home == 0)    printf("ERROR: Z %d didn't go home\n", i + 1);
    }

    for (int i = 0; i < NU; i++) {
        if (u[i].started == 0) printf("ERROR: U %d didn't start\n", i + 1);
        if (u[i].home    == 0) printf("ERROR: U %d didn't go home\n", i + 1);
    }

    for (int i = 0; i < 3; i++) {
        if (queues[i] != 0) printf("ERROR: queue %d is not empty (queue value: %d)\n", i + 1, queues[i]);
    }

    return err;
}
