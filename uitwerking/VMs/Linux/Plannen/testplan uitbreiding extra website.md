# Testplan

- Auteur(s) testplan: Jorik Braet<!--Naam. -->

## Test: werking van uitbreiding extra website<!-- Omschrijving test. -->

Testprocedure:

1. basis netwerk staat op
2. surf vanop windows client naar https://extra.g03-fft.internal
3. open de access logs op de webservers
4. herlaad een aantal keer op beide websites
5. zet een van de webservers uit
6. zoek opnieuw naar de website

Verwacht resultaat:

- wanneer gesurfd wordt naar de website krijgen we een website
- bij het herladen moet om de beurt bij web en redundantweb logs bij komen in de access log
- bij het afzetten van de ene webserver blijft de andere werken en veranderd er niks voor de client