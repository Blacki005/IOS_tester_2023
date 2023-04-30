      ./test.sh [FILTERS]
        Tester vypisuje vsechny testovane vstupy.
        V pripade chyby vypise ocekavany navratovy kod programu a skutecny navratovy kod.
        Pokud se tester sekne, znamena to pravdepodobne deadlock/nekonecny cyklus ve vasem programu.
        Skript predpoklada, ze soubor proj2 si vytvori proj2.out, pokud soubor neexistuje.
        Je normalni, ze beh skriptu chvili trva (v jeho pomalejsi variante).
        V pripade problemu piste na dc: White Knight#8252
        PS: Berte to s rezervou, jsem clovek co ze shell projektu dostal 6 bodu.
    PREREQUISITIES
        soubory: "kontrola-vystupu.sh", "kontrola-vystupu.py" a "Makefile" ve stejném adresáři jako tento skript.
        kontrola vystupu.sh je dostupná na https://moodle.vut.cz/course/view.php?id=231005
    FILTERS
    [-l]
        Běží s Lengálovým (pomalým) skriptem pro kontrolu výstupu.
        Tato varianta se použije automaticky, pokud v adresáři není soubor kontrol-vystupu.py
    [-c]
        Rychlá varianta kontroly výstupu implementovaná v C.
        První číslo v Line format erroru, je číslo řádku v kódu, který neodpovídá formátu.
        Podporuje řádky dlouhé maximálně 64 znaků (není problém zvýšit v kódu). Avšak pokud máte správné řešení 
            dělší řádky by ani neměli vznikat. 

        Kontroluje základní logické chyby např.: zákazník začal 2x, zákazník šel domů i přesto, že čekal v řadě a 
            nebyl zavolán, uředník šel domů, nebo začal sloužit zákazníkovi, když měl přestávku atd. 
        Dále počítá jestli se všechny řady vyprázdnily a všichni zákazníci a uředníci začali a šli domů.
        Jo a není to hezký kód :smrckaBat:, pokud bude nějaký problém, tak mě tagněte na discordu  @Tiger.CZ#1728
    [-e]
        Zapne Extrémní variantu testů.
        Toto není dvakrát bezpečná varianta, zkouší to věci typu překročení rozsahu unsigned long u argumentů NU a NZ.
        Cvičící toto pravděpodobně totot nebudou testovat, je to spíše varianta pro IOS enjoyers.
    
    CREDITS
        Tiger.CZ#1728 - c program pro kontrolu výstupu
        viotal#1256 - rychlý python skript na kontrolu výstupu
        Kubulambula#8412 - čitelný help
        White Knight#8252 - skript, test
