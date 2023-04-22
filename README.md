Snad vsechno info jde ziskat spustenim ./test -h a ja jsem linej, takze se mi to sem nechce prepisovat. Kdyby byly dotazy, piste na discord White Knight#8252, nebo autorovi prislusne sekce ve ktere je problem (viz ./test.sh -h, CREDITS).

Poznámka k C testovacímu skriptu:
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
