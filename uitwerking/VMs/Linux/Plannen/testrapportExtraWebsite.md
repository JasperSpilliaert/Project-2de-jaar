# Testrapport

- Uitvoerder(s) test: Wout<!-- Naam. -->
- Uitgevoerd op: 14/05/2024<!-- Datum. -->
- Github commit: 798927a<!-- Git commit hash. -->

## Test: surf naar extra website<!-- Omschrijving test. -->

Test procedure:

- surfen naar extra website https://extra.g03-fft.internal

Verkregen resultaat:

- de extra website

<!-- Voeg hier eventueel een screenshot van het verkregen resultaat in. -->
![extra website](./img/extra%20site%20ca.png)

Test geslaagd:

- [x] Ja
- [ ] Nee

Opmerkingen:
/

## Test: access logs bekijken van beide servers voor load balancing<!-- Omschrijving test. -->

Test procedure:

- sudo tail -f /var/log/httpd/access_log op web en redundantWeb
- kijken of er bij beide logs bij komen
 
Verkregen resultaat:

- er komen bij beide servers logs bij

<!-- Voeg hier eventueel een screenshot van het verkregen resultaat in. -->
![load balancing](./img/load%20balancing.png)

Test geslaagd:

- [x] Ja
- [ ] Nee

Opmerkingen:
/

## Test: schakel 1 webserver uit<!-- Omschrijving test. -->

Test procedure:

- schakel 1 webserver uit
- werken beide websites nog?

Verkregen resultaat:

- de website werkt nog steeds

<!-- Voeg hier eventueel een screenshot van het verkregen resultaat in. -->

Test geslaagd:

- [x] Ja
- [ ] Nee

Opmerkingen:
/

