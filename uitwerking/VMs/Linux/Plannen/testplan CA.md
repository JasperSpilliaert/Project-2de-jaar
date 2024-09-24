# Testplan

- Auteur(s) testplan: Jorik Braet<!--Naam. -->

## Test: werking CA server<!-- Omschrijving test. -->

Testprocedure:

1. basis netwerk staat op
2. vagrant up CA
3. certificaten worden via tftp overgezet
4. windows script installeert CA certificaat
5. vanaf windows client wordt gezocht naar https://g03-fft.internal
6. vanaf windows client wordt gezocht naar https://extra.g03-fft.internal

Verwacht resultaat:

- bij het zoeken naar beide websites krijgt men geen melding dat de site onveilig is