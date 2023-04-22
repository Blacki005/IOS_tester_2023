#! /bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

F=0
P=0
E=0
proj2out_check() {
    if [[ ! -f "proj2.out" ]]
    then
        echo -e "${RED}Error: File proj2.out not found!${NC}"
    exit 1
    fi

    if [[ ! -f "./kontrola-vystupu.sh" ]]
    then
        echo -e  "${RED}Error: File ./kontrola-vystupu.sh not found!${NC}"
    exit 1
    fi

    if [[ "$F" == 1 ]]
    then
        echo "F = $F"
        if [[ ! -f "./wordcount" ]]
        then
            echo "Error: Wordcount file not found, make sure it is in the same directory as test script!"
        fi

        cat ./proj2.out | ./wordcount 2>./wordcount.tmp

        cat ./wordcount.tmp | \
        awk \
            -v services=0; \
            '{ 
                for (i = 1; i <= NF; i++) {
                    if($4 == "entering") {
                        services = services + 1;
                    }
                    if($4 == "serving") {
                        services = services - 1;
                    }
                }

                if (services != 0) {
                    print "WARNING: Not all customers have been served!"
                }
            }'

        #               if((date_a < $i) && ($i < date_b)) {

        rm ./wordcount.tmp
    elif [[ "$P" == 1 ]]
    then
        echo -e "${YELLOW}"
        python3 kontrola-vystupu.py
        echo -e "${NC}"
    else

        echo -e "${YELLOW}"
        cat ./proj2.out | ./kontrola-vystupu.sh
        echo -e "${NC}"

    fi

    rm ./proj2.out
}

if [[ $1 == "-h" ]]
then
    echo "IOS projekt 2 tester"
    echo "Tester vypisuje vsechny testovane vstupy a v pripade chyby vypise ocekavany navratovy kod programu a skutecny navratovy kod. Pokud se tester sekne, znamena to pravdepodobne deadlock ve vasem programu"
    echo "Prerekvizity: Funkcni Makefile, skript \"kontrola-vystupu.sh\", pripadne program wordcount ve stejnem adresari jako je tento skript. test-vystupu.sh je dostupny na https://moodle.vut.cz/course/view.php?id=231005"
    echo "Spustenim skriptu s parametrem -e zapnete extremni testovani. Toto testuje vstupy daleko za hranicemi normalnich cisel, ktere pravdepodobne zpusobi pad programu, pripadne zaplneni maximalniho poctu procesu definovaneho v /proc/sys/kernel/pid_max. Nepredpoikladam, ze by cvici testovali neco z tohoto, takze to je spis pro fajnsmekry."
    echo "Skript predpoklada, ze soubor proj2 si vytvori proj2.out, pokud soubor neexistuje - vystupove soubory jsou ve skriptu premazavany (coz odpovida implementaci, protoze jestli ma make vytvorit spustitelny program nezavisly na souborech, musi si program v pripade neexistence proj2.out tento soubor vytvorit)."
    echo "Je normalni, ze beh skriptu chvili trva, vzhledem k extremnim paramnetrum, ktere programu zadava. Chvili (cca 30 s) pockejte nez situaci vyhodnotite jako deadlock/nekonecny cyklus."
    echo "Parametr -f vyrazne urychli beh skriptu, ale testovani vystupu neni tak spolehlive - kontroluje se jen ze ke kazdemu vyskytu slova entering se vyskytuje i slovo serving."
    echo "Parametr -p urychli beh skriptu tak, ze pouzije verzi kontroly vstupu prepsanou do pythonu, protoze bash slow."
    echo "V pripade problemu piste na dc: White Knight#8252"
    echo "PS: Berte to s rezervou, nemusi to fungovat spravne vsem, je to splacane na koleni v autobusu a jsem clovek co ze shell projektu dostal 6 bodu"
    exit 0
fi

while getopts "fphe" opt; do
    case "$opt" in
        h)
            help
            exit
            ;;
        f)
            if [ "$P" == 1 ]; then
                echo "-p a -f cannot be together" 
                exit 1
            fi
            F=1
            ;;
        p)
            if [ "$F" == 1 ]; then
                echo "-p a -f cannot be together" 
                exit 1
            fi
            P=1
            ;;
        e)
            E=1
            ;;
        *)
            echo "Invalid argument" 
            exit 1
            ;;
    esac
done

if [[ ! -f "Makefile" ]]
then
    echo -e "${RED}Error: No makefile found!${NC}"
    exit 1
fi

make

if [[ ! -f "proj2" ]]
then
    echo -e "${RED}Error: Wrong file name! Correct is \"proj2\"${NC}"
exit 1
fi

#./proj2 NZ NU TZ TU F
#chybejici vstupni promenne:
echo "Testing missing arguments..."
    ./proj2 &>/dev/null
    if [[ $? != 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2\" returned with: $?. Return code 1 expected!${NC}"
        rm ./proj2.out
        exit 1
    else 
        echo -e "${GREEN}OK ./proj2${NC}" 
    fi

    ./proj2 1 &>/dev/null
    if [[ $? != 1 ]]
    then
        echo -e "${RED}proj2 returned with: $?. Return code 1 expected!${NC}"
        rm ./proj2.out
        exit 1
    else 
        echo -e "${GREEN}OK ./proj2 1${NC}" 
    fi

    ./proj2 1 1 &>/dev/null
    if [[ $? != 1 ]]
    then
        echo -e "${RED}proj2 returned with: $?. Return code 1 expected!${NC}"
        rm ./proj2.out
        exit 1
    else 
        echo -e "${GREEN}OK ./proj2 1 1${NC}" 
    fi
    
    ./proj2 1 1 1 &>/dev/null
    if [[ $? != 1 ]]
    then
        echo -e "${RED}proj2 returned with: $?. Return code 1 expected!${NC}"
        rm ./proj2.out
        exit 1
    else 
        echo -e "${GREEN}OK ./proj2 1 1 1${NC}" 
    fi

    ./proj2 1 1 1 1 &>/dev/null
    if [[ $? != 1 ]]
    then
        echo -e "${RED}proj2 returned with: $?. Return code 1 expected!${NC}"
        rm ./proj2.out
        exit 1
    else 
        echo -e "${GREEN}OK ./proj2 1 1 1 1${NC}" 
    fi

#neciselne argumenty
echo "Testing non-numeric arguments..."
    ./proj2 k 1 1 1 1 &>/dev/null
    if [[ $? != 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 k 1 1 1 1\" returned with: $?. Return code 1 expected!${NC}"
    else
        echo -e "${GREEN}OK ./proj2 k 1 1 1 1${NC}" 
    fi

    ./proj2 1 o 1 1 1 &>/dev/null
    if [[ $? != 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 1 o 1 1 1\" returned with: $?. Return code 1 expected!${NC}"
    else
        echo -e "${GREEN}OK ./proj2 1 o 1 1 1${NC}" 
    fi

    ./proj2 1 1 k 1 1 &>/dev/null
    if [[ $? != 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 1 1 k 1 1\" returned with: $?. Return code 1 expected!${NC}"
    else
        echo -e "${GREEN}OK ./proj2 1 1 k 1 1${NC}" 
    fi
    
    ./proj2 1 1 1 o 1 &>/dev/null
    if [[ $? != 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 1 1 1 o 1\" returned with: $?. Return code 1 expected!${NC}"
    else
        echo -e "${GREEN}OK ./proj2 1 1 1 o 1${NC}" 
    fi

    ./proj2 1 1 1 1 t &>/dev/null
    if [[ $? != 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 1 1 1 1 t\" returned with: $?. Return code 1 expected!${NC}"
    else
        echo -e "${GREEN}OK ./proj2 1 1 1 1 t${NC}" 
    fi
    
    if [[ ! -f "./proj2" ]]
    then
        rm ./proj2.out
    fi

#promenne mimo zadany rozsah - nema projit!:
echo "Testing invalid arguments..."

    ./proj2 1 0 1 1 1 &>/dev/null
    if [[ $? == 1 ]]
    then
        echo -e "${GREEN}OK ./proj2 1 0 1 1 1${NC}"
    else
        echo -e "${RED}FAILED \"./proj2 1 0 1 1 1\" returned with: $?. Return code 1 expected!${NC}"
        exit 1
    fi

    ./proj2 1 1 -1 1 1 &>/dev/null
    if [[ $? == 1 ]]
    then
        echo -e "${GREEN}OK ./proj2 1 1 -1 1 1${NC}"
    else
        echo -e "${RED}FAILED \"./proj2 1 1 -1 1 1\" returned with: $?. Return code 1 expected!${NC}"
        exit 1
    fi

    ./proj2 1 1 10001 1 1 &>/dev/null
    if [[ $? == 1 ]]
    then
        echo -e "${GREEN}OK ./proj2 1 1 10001 1 1${NC}"
    else
        echo -e "${RED}FAILED \"./proj2 1 1 10001 1 1\" returned with: $?. Return code 1 expected!${NC}"
        exit 1
    fi

    ./proj2 1 1 1 -1 1 &>/dev/null
    if [[ $? == 1 ]]
    then
        echo -e "${GREEN}OK ./proj2 1 1 1 -1 1${NC}"
    else
        echo -e "${RED}FAILED \"./proj2 1 1 1 -1 1\" returned with: $?. Return code 1 expected!${NC}"
        exit 1
    fi

    ./proj2 1 1 1 101 1 &>/dev/null
    if [[ $? == 1 ]]
    then
        echo -e "${GREEN}OK ./proj2 1 1 1 101 1${NC}"
    else
        echo -e "${RED}FAILED \"./proj2 1 1 1 101 1\" returned with: $?. Return code 1 expected!${NC}"
        exit 1
    fi

    ./proj2 1 1 1 1 -1 &>/dev/null
    if [[ $? == 1 ]]
    then
        echo -e "${GREEN}OK ./proj2 1 1 1 1 -1${NC}"
    else
        echo -e "${RED}FAILED \"./proj2 1 1 1 1 -1\" returned with: $?. Return code 1 expected!${NC}"
        exit 1
    fi

    ./proj2 1 1 1 1 10001 &>/dev/null
    if [[ $? == 1 ]]
    then
        echo -e "${GREEN}OK ./proj2 1 1 1 1 10001${NC}"
    else
        echo -e "${RED}FAILED \"./proj2 1 1 1 1 10001\" returned with: $?. Return code 1 expected!${NC}"
        exit 1
    fi

    if [[ ! -f "./proj2" ]]
    then
        rm ./proj2.out
    fi

#promenne tesne v zadanem rozsahu - ma projit!:======================================================================
echo "Testing max/min valid arguments..."
    ./proj2 1 1 10000 1 1
    if [[ $? == 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 1 1 10000 1 1\" returned with 1 even though arguments were valid!${NC}"
        exit 1
    else
        echo -e "${GREEN}OK \"./proj2 1 1 10000 1 1\" ... running ./kontrola-vystupu.sh${NC}"
        if [[ $1 == "-f" ]]
        then
            proj2out_check "-f"
        elif [[ $1 == "-p" ]]
        then
            proj2out_check "-p"
        else
            proj2out_check
        fi
    fi

    ./proj2 1 1 0 1 1
    if [[ $? == 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 1 1 0 1 1\" returned with 1 even though arguments were valid!${NC}"
        exit 1
    else
        echo -e "${GREEN}OK \"./proj2 1 1 0 1 1\" ... running ./kontrola-vystupu.sh${NC}"
        if [[ $1 == "-f" ]]
        then
            proj2out_check "-f"
        elif [[ $1 == "-p" ]]
        then
            proj2out_check "-p"
        else
            proj2out_check
        fi
    fi

    ./proj2 1 1 100 1 1
    if [[ $? == 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 1 1 100 1 1\" returned with 1 even though arguments were valid!${NC}"
        exit 1
    else
        echo -e "${GREEN}OK \"./proj2 1 1 100 1 1\" ... running ./kontrola-vystupu.sh${NC}"
        if [[ $1 == "-f" ]]
        then
            proj2out_check "-f"
        elif [[ $1 == "-p" ]]
        then
            proj2out_check "-p"
        else
            proj2out_check
        fi
    fi
    
    ./proj2 1 1 0 1 1
    if [[ $? == 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 1 1 0 1 1\" returned with 1 even though arguments were valid!${NC}"
        exit 1
    else
        echo -e "${GREEN}OK \"./proj2 1 1 0 1 1\" ... running ./kontrola-vystupu.sh${NC}"
        if [[ $1 == "-f" ]]
        then
            proj2out_check "-f"
        elif [[ $1 == "-p" ]]
        then
            proj2out_check "-p"
        else
            proj2out_check
        fi
    fi

    ./proj2 1 1 1 1 10000
    if [[ $? == 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 1 1 1 1 10000\" returned with 1 even though arguments were valid!${NC}"
        exit 1
    else
        echo -e "${GREEN}OK \"./proj2 1 1 1 1 10000\" ... running ./kontrola-vystupu.sh${NC}"
        if [[ $1 == "-f" ]]
        then
            proj2out_check "-f"
        elif [[ $1 == "-p" ]]
        then
            proj2out_check "-p"
        else
            proj2out_check
        fi
    fi

    ./proj2 1 1 1 1 0
    if [[ $? == 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 1 1 1 1 0\" returned with 1 even though arguments were valid!${NC}"
        exit 1
    else
        echo -e "${GREEN}OK \"./proj2 1 1 1 1 0\" ... running ./kontrola-vystupu.sh${NC}"
        if [[ $1 == "-f" ]]
        then
            proj2out_check "-f"
        elif [[ $1 == "-p" ]]
        then
            proj2out_check "-p"
        else
            proj2out_check
        fi
    fi

    ./proj2 100 1 1 1 10000
    if [[ $? == 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 100 1 1 1 10000\" returned with 1 even though arguments were valid!${NC}"
        exit 1
    else
        echo -e "${GREEN}OK \"./proj2 100 1 1 1 10000\" ... running ./kontrola-vystupu.sh${NC}"
        if [[ $1 == "-f" ]]
        then
            proj2out_check "-f"
        elif [[ $1 == "-p" ]]
        then
            proj2out_check "-p"
        else
            proj2out_check
        fi
    fi

    ./proj2 1 100 1 1 10000
    if [[ $? == 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 1 100 1 1 10000\" returned with 1 even though arguments were valid!${NC}"
        exit 1
    else
        echo -e "${GREEN}OK \"./proj2 1 100 1 1 10000\" ... running ./kontrola-vystupu.sh${NC}"
        if [[ $1 == "-f" ]]
        then
            proj2out_check "-f"
        elif [[ $1 == "-p" ]]
        then
            proj2out_check "-p"
        else
            proj2out_check
        fi
    fi

    ./proj2 0 1 1 1 1
    if [[ $? == 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 0 1 1 1 1\" returned with 1 even though arguments were valid!${NC}"
        exit 1
    else
        echo -e "${GREEN}OK \"./proj2 0 1 1 1 1\" ... running ./kontrola-vystupu.sh${NC}"
        if [[ $1 == "-f" ]]
        then
            proj2out_check "-f"
        elif [[ $1 == "-p" ]]
        then
            proj2out_check "-p"
        else
            proj2out_check
        fi
    fi

if [[ "$E" == 1 ]]
then
#test extremnich hodnot NZ a NU
echo "Ruining your day by tring arguments that are far above normally used numbers..."
    echo "Running \"./proj2 1000000000000000000000000000000000 1 1 1 1...\""
    ./proj2 1000000000000000000000000000000000 1 1 1 1
    echo "Running \"./proj2 1 1000000000000000000000000000000000 1 1 1...\""
    ./proj2 1 1000000000000000000000000000000000 1 1 1
    echo "Running \"10000000000 1 1 1 1...\""
    ./proj2 10000000000 1 1 1 1
    echo "Running \"./proj2 1 10000000000 1 1 1...\""
    ./proj2 1 10000000000 1 1 1
    echo "Running \"./proj2 5000000000 1 1 1 1...\""
    ./proj2 5000000000 1 1 1 1
    echo "Running \"./proj2 1 5000000000 1 1 1...\""
    ./proj2 1 5000000000 1 1 1
    echo "Running \"./proj2 1 0.5 1 1 1...\""
    ./proj2 1 0.5 1 1 1
    echo "Running \"./proj2 0.5 1 1 1 1...\""
    ./proj2 0.5 1 1 1 1
    echo "Running \"./proj2 1 helloworld 1 1 1...\""
    ./proj2 1 helloworld 1 1 1
    echo "Running \"./proj2 helloworld 1 1 1 1...\""
    ./proj2 helloworld 1 1 1 1
fi

echo -e "Named semaphores sentenced by you to wander across the vast plains of /dev/shm for eternity:${RED}"
ls /dev/shm
echo -e "${NC}Unnamed semaphores left in memory:${RED}"
ipcs -s
echo -e "${NC}"

exit 0