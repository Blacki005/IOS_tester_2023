#! /bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
F=0
L=0
E=0

function show_help(){
    echo -e "Usage:
    ${YELLOW}./test.sh [FILTER]${NC}
        Tester vypisuje vsechny testovane vstupy.
        V pripade chyby vypise ocekavany navratovy kod programu a skutecny navratovy kod.
        Pokud se tester sekne, znamena to pravdepodobne deadlock/nekonecny cyklus ve vasem programu.
        Skript predpoklada, ze soubor proj2 si vytvori proj2.out, pokud soubor neexistuje.
        Je normalni, ze beh skriptu chvili trva (v jeho pomalejsi variante).
        V pripade problemu piste na dc: White Knight#8252
        PS: Berte to s rezervou, jsem clovek co ze shell projektu dostal 6 bodu.

    ${YELLOW}PREREQUISITIES${NC}
        soubory: \"kontrola-vystupu.sh\", \"kontrola-vystupu.py\" a \"Makefile\"ve stejném adresáři jako tento skript.
        kontrola vystupu.sh je dostupná na https://moodle.vut.cz/course/view.php?id=231005, ostatí na gitu https://github.com/xjanst03/IOS_tester_2023

    ${YELLOW}FILTERS${NC}
    [${GREEN}-l${NC}]
        Běží s ${GREEN}L${NC}engálovým (pomalým) skriptem pro kontrolu výstupu.
        Tato varianta se použije automaticky, pokud v adresáři není soubor kontrol-vystupu.py

    [${GREEN}-e${NC}]
        Zapne ${GREEN}E${NC}xtrémní variantu testů.
        Toto není dvakrát bezpečná varianta, zkouší to věci typu překročení rozsahu unsigned long u argumentů NU a NZ.
        Cvičící toto pravděpodobně totot nebudou testovat, je to spíše varianta pro IOS enjoyers.
    
    ${YELLOW}CREDITS${NC}
        viotal#1256 - rychlý python skript na kontrolu výstupu
        Kubulambula#8412 - čitelný help
        White Knight#8252 - skript, testy
"
exit 0
}

proj2out_check() {
    if [[ ! -f "proj2.out" ]]
    then
        echo -e "${RED}Error: File proj2.out not found!${NC}"
    exit 1
    fi

    if [[ $L == 1 ]]
    then
        if [[ ! -f "./kontrola-vystupu.sh" ]]
        then
            echo -e  "${RED}ERROR: File ./kontrola-vystupu.sh not found!${NC}"
            exit 1
        else
            cat ./proj2.out | ./kontrola-vystupu.sh
        fi
    else
        if [[ ! -f "./kontrola-vystupu.py" ]]
        then
            echo -e  "${YELLOW}WARNING: File ./kontrola-vystupu.py not found, running with slower kontrola-vystupu.sh!${NC}"
            if [[ ! -f "./kontrola-vystupu.sh" ]]
            then
                echo -e  "${RED}ERROR: File ./kontrola-vystupu.sh not found!${NC}"
                exit 1
            else
                echo -e "${YELLOW}"
                cat ./proj2.out | ./kontrola-vystupu.sh
                echo -e "${NC}"
            fi
        else
            echo -e "${YELLOW}"
            python3 kontrola-vystupu.py
            echo -e "${NC}"
        fi
    fi
    rm ./proj2.out
}



while getopts "lhe" opt; do
    case "$opt" in
        h)
            show_help
            exit
            ;;
        l)
            L=1
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
        echo -e "${GREEN}OK \"./proj2 1 1 10000 1 1\" ... running ./kontrola-vystupu${NC}"
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
        echo -e "${GREEN}OK \"./proj2 1 1 0 1 1\" ... running ./kontrola-vystupu${NC}"
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
        echo -e "${GREEN}OK \"./proj2 1 1 100 1 1\" ... running ./kontrola-vystupu${NC}"
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
        echo -e "${GREEN}OK \"./proj2 1 1 0 1 1\" ... running ./kontrola-vystupu${NC}"
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
        echo -e "${GREEN}OK \"./proj2 1 1 1 1 10000\" ... running ./kontrola-vystupu${NC}"
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
        echo -e "${GREEN}OK \"./proj2 1 1 1 1 0\" ... running ./kontrola-vystupu${NC}"
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
        echo -e "${GREEN}OK \"./proj2 100 1 1 1 10000\" ... running ./kontrola-vystupu${NC}"
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
        echo -e "${GREEN}OK \"./proj2 1 100 1 1 10000\" ... running ./kontrola-vystupu${NC}"
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
        echo -e "${GREEN}OK \"./proj2 0 1 1 1 1\" ... running ./kontrola-vystupu${NC}"
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

if [[ $E == 1 ]]
then
#test extremnich hodnot NZ a NU
echo "Ruining your day by trying arguments that are far above normally used numbers..."
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
