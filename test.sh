#! /bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
F=0
L=0
E=0
C=0

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

    [${GREEN}-c${NC}]
        Rychlá varianta kontroly výstupu implementovaná v ${GREEN}C${NC}.
        První číslo v Line format erroru, je číslo řádku v kódu, který neodpovídá formátu.
        * Řádky delší než 64 znaků rozdělí na 2 (takže nespadne, ale bere je jako chybu), ale pokud
            máte korektní řešení, neměl by žádný řádek být tak dlouhý, dokud teda nemáte ve výstupu více
            jak 100M řádků.
        * K rychlosti: nečekal, jsem takový speedup, ale dal jsem původnímu skriptu soubor s 1.7M řádky a ani
            po 15 minutách nevyhodil výsledek. C to zvládlo do 200 ms. (Hlavně protože to prostě se rovnou rozhoduje
            kam v kódu to půjde a navíc ten originální skript nic víc než kontrolu formátu řádků nedělá)
        Jo a není to hezký kód :smrckaBat:, pokud bude nějaký problém, tak mě tagněte na discordu  @Tiger.CZ#1728

    [${GREEN}-e${NC}]
        Zapne ${GREEN}E${NC}xtrémní variantu testů.
        Toto není dvakrát bezpečná varianta, zkouší to věci typu překročení rozsahu unsigned long u argumentů NU a NZ.
        Cvičící toto pravděpodobně totot nebudou testovat, je to spíše varianta pro IOS enjoyers.
    
    ${YELLOW}CREDITS${NC}
        Tiger.CZ#1728 - c program pro kontrolu výstupu
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
    elif [[ $C == 1 ]]
    then
        if [[ ! -f "./kontrola-vystupu.c" ]]
        then
            echo -e  "${YELLOW}WARNING: File ./kontrola-vystupu.c not found, running with slower kontrola-vystupu.sh!${NC}"
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
            cat ./proj2.out | ./kontrola-vystupu.c
            echo -e "${NC}"
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
    clear_output
}

function clear_output() {
    if [[ -f ./proj2.out ]]
    then
        rm proj2.out
    fi
}



while getopts "lhec" opt; do
    case "$opt" in
        h)
            show_help
            exit
            ;;
        l)
            if [[ $C == 1 ]]
            then
                echo "${RED}ERROR: options -l and -c are mutually exclusive!${NC}"
            fi
            L=1
            ;;
        e)
            E=1
            ;;
        c)
            C=1
            if [[ $L == 1 ]]
            then
                echo "${RED}ERROR: options -l and -c are mutually exclusive!${NC}"
            fi
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
        clear_output
        exit 1
    else 
        echo -e "${GREEN}OK ./proj2${NC}" 
    fi

    ./proj2 1 &>/dev/null
    if [[ $? != 1 ]]
    then
        echo -e "${RED}proj2 returned with: $?. Return code 1 expected!${NC}"
        clear_output
        exit 1
    else 
        echo -e "${GREEN}OK ./proj2 1${NC}" 
    fi

    ./proj2 1 1 &>/dev/null
    if [[ $? != 1 ]]
    then
        echo -e "${RED}proj2 returned with: $?. Return code 1 expected!${NC}"
        clear_output
        exit 1
    else 
        echo -e "${GREEN}OK ./proj2 1 1${NC}" 
    fi
    
    ./proj2 1 1 1 &>/dev/null
    if [[ $? != 1 ]]
    then
        echo -e "${RED}proj2 returned with: $?. Return code 1 expected!${NC}"
        clear_output
        exit 1
    else 
        echo -e "${GREEN}OK ./proj2 1 1 1${NC}" 
    fi

    ./proj2 1 1 1 1 &>/dev/null
    if [[ $? != 1 ]]
    then
        echo -e "${RED}proj2 returned with: $?. Return code 1 expected!${NC}"
        clear_output
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
    clear_output

    ./proj2 1 o 1 1 1 &>/dev/null
    if [[ $? != 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 1 o 1 1 1\" returned with: $?. Return code 1 expected!${NC}"
    else
        echo -e "${GREEN}OK ./proj2 1 o 1 1 1${NC}" 
    fi
    clear_output

    ./proj2 1 1 k 1 1 &>/dev/null
    if [[ $? != 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 1 1 k 1 1\" returned with: $?. Return code 1 expected!${NC}"
    else
        echo -e "${GREEN}OK ./proj2 1 1 k 1 1${NC}" 
    fi
    clear_output

    ./proj2 1 1 1 o 1 &>/dev/null
    if [[ $? != 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 1 1 1 o 1\" returned with: $?. Return code 1 expected!${NC}"
    else
        echo -e "${GREEN}OK ./proj2 1 1 1 o 1${NC}" 
    fi
    clear_output

    ./proj2 1 1 1 1 t &>/dev/null
    if [[ $? != 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 1 1 1 1 t\" returned with: $?. Return code 1 expected!${NC}"
    else
        echo -e "${GREEN}OK ./proj2 1 1 1 1 t${NC}" 
    fi
    clear_output

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
    clear_output

    ./proj2 1 1 -1 1 1 &>/dev/null
    if [[ $? == 1 ]]
    then
        echo -e "${GREEN}OK ./proj2 1 1 -1 1 1${NC}"
    else
        echo -e "${RED}FAILED \"./proj2 1 1 -1 1 1\" returned with: $?. Return code 1 expected!${NC}"
        exit 1
    fi
    clear_output

    ./proj2 1 1 10001 1 1 &>/dev/null
    if [[ $? == 1 ]]
    then
        echo -e "${GREEN}OK ./proj2 1 1 10001 1 1${NC}"
    else
        echo -e "${RED}FAILED \"./proj2 1 1 10001 1 1\" returned with: $?. Return code 1 expected!${NC}"
        exit 1
    fi
    clear_output

    ./proj2 1 1 1 -1 1 &>/dev/null
    if [[ $? == 1 ]]
    then
        echo -e "${GREEN}OK ./proj2 1 1 1 -1 1${NC}"
    else
        echo -e "${RED}FAILED \"./proj2 1 1 1 -1 1\" returned with: $?. Return code 1 expected!${NC}"
        exit 1
    fi
    clear_output

    ./proj2 1 1 1 101 1 &>/dev/null
    if [[ $? == 1 ]]
    then
        echo -e "${GREEN}OK ./proj2 1 1 1 101 1${NC}"
    else
        echo -e "${RED}FAILED \"./proj2 1 1 1 101 1\" returned with: $?. Return code 1 expected!${NC}"
        exit 1
    fi
    clear_output

    ./proj2 1 1 1 1 -1 &>/dev/null
    if [[ $? == 1 ]]
    then
        echo -e "${GREEN}OK ./proj2 1 1 1 1 -1${NC}"
    else
        echo -e "${RED}FAILED \"./proj2 1 1 1 1 -1\" returned with: $?. Return code 1 expected!${NC}"
        exit 1
    fi
    clear_output

    ./proj2 1 1 1 1 10001 &>/dev/null
    if [[ $? == 1 ]]
    then
        echo -e "${GREEN}OK ./proj2 1 1 1 1 10001${NC}"
    else
        echo -e "${RED}FAILED \"./proj2 1 1 1 1 10001\" returned with: $?. Return code 1 expected!${NC}"
        exit 1
    fi
    clear_output

#promenne tesne v zadanem rozsahu - ma projit!:======================================================================
echo "Testing max/min valid arguments..."
    ./proj2 4 2 10000 10 100
    if [[ $? == 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 4 2 10000 10 100\" returned with 1 even though arguments were valid!${NC}"
        clear_output
        exit 1
    else
        echo -e "${GREEN}OK \"./proj2 4 2 10000 10 100\" ... running ./kontrola-vystupu${NC}"
        proj2out_check
    fi

    ./proj2 4 2 0 100 100
    if [[ $? == 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 4 2 0 100 100\" returned with 1 even though arguments were valid!${NC}"
        clear_output
        exit 1
    else
        echo -e "${GREEN}OK \"./proj2 4 2 0 100 100\" ... running ./kontrola-vystupu${NC}"
        proj2out_check
    fi

    ./proj2 4 2 100 1 100
    if [[ $? == 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 4 2 100 1 100\" returned with 1 even though arguments were valid!${NC}"
        clear_output
        exit 1
    else
        echo -e "${GREEN}OK \"./proj2 4 2 100 1 100\" ... running ./kontrola-vystupu${NC}"
        proj2out_check
    fi
    
    ./proj2 4 2 0 1 100
    if [[ $? == 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 4 2 0 1 100\" returned with 1 even though arguments were valid!${NC}"
        clear_output
        exit 1
    else
        echo -e "${GREEN}OK \"./proj2 4 2 0 1 100\" ... running ./kontrola-vystupu${NC}"
        proj2out_check
    fi

    ./proj2 4 2 1 1 100
    if [[ $? == 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 4 2 1 1 100\" returned with 1 even though arguments were valid!${NC}"
        clear_output
        exit 1
    else
        echo -e "${GREEN}OK \"./proj2 4 2 1 1 100\" ... running ./kontrola-vystupu${NC}"
        proj2out_check
    fi

    ./proj2 4 2 1 1 0
    if [[ $? == 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 4 2 1 1 0\" returned with 1 even though arguments were valid!${NC}"
        clear_output
        exit 1
    else
        echo -e "${GREEN}OK \"./proj2 4 2 1 1 0\" ... running ./kontrola-vystupu${NC}"
        proj2out_check
    fi


    ./proj2 100 1 1 1 100
    if [[ $? == 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 100 1 1 1 100\" returned with 1 even though arguments were valid!${NC}"
        clear_output
        exit 1
    else
        echo -e "${GREEN}OK \"./proj2 100 1 1 1 100\" ... running ./kontrola-vystupu${NC}"
        proj2out_check
    fi

    ./proj2 1 100 1 1 100
    if [[ $? == 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 1 100 1 1 100\" returned with 1 even though arguments were valid!${NC}"
        clear_output
        exit 1
    else
        echo -e "${GREEN}OK \"./proj2 1 100 1 1 100\" ... running ./kontrola-vystupu${NC}"
        proj2out_check
    fi

    ./proj2 0 1 1 1 10
    if [[ $? == 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 0 1 1 1 10\" returned with 1 even though arguments were valid!${NC}"
        clear_output
        exit 1
    else
        echo -e "${GREEN}OK \"./proj2 0 1 1 1 10\" ... running ./kontrola-vystupu${NC}"
        proj2out_check
    fi

#nahodne argumenty programu

echo "Testing randomized arguments..."
RANDOM=$$
for i in {0..5}
do
    NZ=$(($RANDOM%50))
    NU=$(($RANDOM%50)); ((NU++))
    TZ=$(($RANDOM%10000))
    TU=$(($RANDOM%100))
    F=$(($RANDOM%1000))

    ./proj2 $NZ $NU $TZ $TU $F
    if [[ $? == 1 ]]
    then
        echo -e "${RED}FAILED \"./proj2 $NZ $NU+1 $TZ $TU $F\" returned with 1 even though arguments were valid!${NC}"
        clear_output
        exit 1
    else
        echo -e "${GREEN}OK \"./proj2 $NZ $NU $TZ $TU $F\" ... running ./kontrola-vystupu${NC}"
        proj2out_check
    fi
done



if [[ $E == 1 ]]
then
#test extremnich hodnot NZ a NU
echo "Ruining your day by trying arguments that are far above normally used numbers"
echo -e "${YELLOW}WARNING:${NC} Please note, that result ${GREEN}OK${NC} is based purely on the program not crushing."

    echo "Running \"10000000000 1 1 1 1...\""
    ./proj2 2147483647 1 1 1 1 #INT_MAX
    clear_output
    echo -e "${GREEN}OK${NC}"

    echo "Running \"./proj2 1 10000000000 1 1 1...\""
    ./proj2 1 2147483647 1 1 1 #INT_MAX
    clear_output
    echo -e "${GREEN}OK${NC}"


    echo "Running \"./proj2 1 0.5 1 1 1...\""
    ./proj2 1 0.5 1 1 1
    clear_output
    echo -e "${GREEN}OK${NC}"

    echo "Running \"./proj2 0.5 1 1 1 1...\""
    ./proj2 0.5 1 1 1 1
    clear_output
    echo -e "${GREEN}OK${NC}"

    echo "Running \"./proj2 1 helloworld 1 1 1...\""
    ./proj2 1 helloworld 1 1 1
    clear_output
    echo -e "${GREEN}OK${NC}"

    echo "Running \"./proj2 helloworld 1 1 1 1...\""
    ./proj2 helloworld 1 1 1 1
    clear_output
    echo -e "${GREEN}OK${NC}"
fi

echo -e "Named semaphores sentenced by you to wander across the vast plains of /dev/shm for eternity:${RED}"
ls /dev/shm
echo -e "${NC}Unnamed semaphores left in memory:${RED}"
ipcs -s
echo -e "${NC}"

exit 0
