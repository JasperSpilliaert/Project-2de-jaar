# Testplan

- Auteur(s) testplan: Jorik Braet<!--Naam. -->

## Test: werking web, db en reverseProxy<!-- Omschrijving test. -->

Testprocedure:

1. vagrant up web db reverseProxy op verschillende pc's
2. ping
    - web -> router
    - db -> router
    - reverseProxy -> router
    - web -> db
    - db -> web
    - web -> reverseProxy
    - reverseProxy -> web
3. Vanop reverseProxy VM
    - curl -k https://g03-syndus.internal
    - vanop windows client zoeken naar https://g03-syndus.internal


Verwacht resultaat:

- Alle pings werken tussen de 3 VM's
- Het curl commando returned de website van de web server

<!-- Voeg hier eventueel een screenshot van het verwachte resultaat in. -->