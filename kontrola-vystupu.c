#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * Přepis skriptu 'kontrola-vystupu.sh' do C.
 * Měl by zpracovávat vstupy stejně, jako originální skript (čte z stdinu), ale nic neslibuju.
 * Řádky delší než 64 znaků rozdělí na 2 (takže nespadne, ale bere je jako chybu), ale pokud
 * máte korektní řešení, neměl by žádný řádek být tak dlouhý, dokud teda nemáte ve výstupu více
 * jak 100M řádků.
 *
 * První číslo v Line format erroru, je číslo řádku v kódu, který neodpovídá formátu.
 *
 *
 * k rychlosti: nečekal, jsem takový speedup, ale dal jsem původnímu skriptu soubor s 1.7M řádky a ani
 * po 15 minutách nevyhodil výsledek. C to zvládlo do 200 ms. (Hlavně protože to prostě se rovnou rozhoduje
 * kam v kódu to půjde a navíc ten originální skript nic víc než kontrolu formátu řádků nedělá)
 *
 *
 * Jo a není to hezký kód :smrckaBat:, pokud bude nějaký problém, tak mě tagněte na discordu  @Tiger.CZ#1728,
 * ale neslibuju, že něco budu fixovat :D (Use at your own risk)
 *
 *
 * Compile with: gcc -std=gnu99 -Wall -Wextra -pedantic -Werror kontrola-vystupu.c -o kontrola-vystupu
 * (klidně si přidejte -O2, nebo co potřebujete)
 */

#define format_error(c) if (c) { printf("%d: Line format error: %s", __LINE__, buffer); err = 1; continue; }
#define format_number(c) format_error(buffer[c] < '0' || buffer[c] > '9'); i++

// 64 by mělo stačil i pro nejdelší řádky, pokud máte korektní řešení a nedostnete se k více než 100M řádkům
#define MAX_LINE_LEN 64

int main() {
    // Proměnné z originálního testu
    int Z_started  = 0;
    int Z_in       = 0;
    int Z_called   = 0;
    int Z_home     = 0;
    int U_start    = 0;
    int U_home     = 0;
    int U_break    = 0;
    int U_breakF   = 0;
    int U_serving  = 0;
    int U_servingF = 0;
    int Closing    = 0;

    int err = 0;
    char buffer[MAX_LINE_LEN]; 

    while(fgets(buffer, sizeof(buffer), stdin) != NULL) {
        int i = 0;
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
                        Z_started = 1;
                        break;
                    case 'e':
                        format_error(strncmp(&buffer[i], "entering office for a service ", 30));
                        i+= 30;
                        format_error(buffer[i] < '1' || buffer[i] > '3');
                        format_error(buffer[++i] != '\n');
                        Z_in = 1;
                        break;
                    case 'c':
                        format_error(strcmp(&buffer[i], "called by office worker\n"));
                        Z_called = 1;
                        break;
                    case 'g':
                        format_error(strcmp(&buffer[i], "going home\n"));
                        Z_home = 1; 
                        break;
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
                            U_start = 1;
                            break;
                        }

                        format_error(strncmp(&buffer[i-1], "servi", 5));
                        i += 4;
                        if (buffer[i] == 'n') {
                            format_error(strncmp(&buffer[++i], "g a service of type ", 20));
                            i+= 20;
                            format_error(buffer[i] < '1' || buffer[i] > '3');
                            format_error(buffer[++i] != '\n');
                            U_serving = 1;
                            break;
                        }

                        format_error(strcmp(&buffer[i], "ce finished\n"));
                        U_servingF = 1;
                        break;

                    case 'g':
                        format_error(strcmp(&buffer[i], "going home\n"));
                        U_home = 1;
                        break;
                    case 't':
                        format_error(strcmp(&buffer[i], "taking break\n"));
                        U_break = 1;
                        break;
                    case 'b':
                        format_error(strcmp(&buffer[i], "break finished\n"));
                        U_breakF = 1;
                        break;

                    default:
                        format_error(1);
                        break;
                    }

                break;

            case 'c':
                format_error(strcmp(&buffer[i-1], "closing\n"));
                Closing = 1;
                break;
            
            default:
                format_error(1);
                break;

        }

    }


    if (!Z_started)  printf("WARNING: no Z started\n");
    if (!Z_in)       printf("WARNING: no Z entering office\n");
    if (!Z_called)   printf("WARNING: no Z called by office worker\n");
    if (!Z_home)     printf("WARNING: no Z going home\n");
    if (!U_start)    printf("WARNING: no U started\n");
    if (!U_break)    printf("WARNING: no U taking break\n");
    if (!U_breakF)   printf("WARNING: no U finishing break\n");
    if (!U_serving)  printf("WARNING: no U serving a service\n");
    if (!U_servingF) printf("WARNING: no U finished a service\n");
    if (!U_home)     printf("WARNING: no U going home\n");
    if (!Closing)    printf("WARNING: no closing\n");

    return err;
}
