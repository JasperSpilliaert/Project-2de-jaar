# Testplan

- Auteur(s) testplan: Leonard Van Iseghem

## Test: Verbinding met de Nextcloud-server

Testprocedure:

1. Open een webbrowser.
2. Typ het adres van de Nextcloud-server in de adresbalk.
3. Voer de inloggegevens in en meld je aan.

Verwacht resultaat:

- De gebruiker wordt succesvol ingelogd op de Nextcloud-interface.
- Het dashboard of de bestandenweergave wordt geladen.

<!-- Voeg hier eventueel een screenshot van het verwachte resultaat in. -->

## Test: Synchronisatie van bestanden met Nextcloud-desktopclient

Testprocedure:

1. Installeer de Nextcloud-desktopclient op een lokaal apparaat.
2. Meld je aan bij de desktopclient met de Nextcloud-account.
3. Controleer of de voorbeeld bestanden zijn gesynchroniseerd met op de lokale schijf

Verwacht resultaat:

- Voorbeeld bestanden zijn gesynchroniseerd met de lokale schijf
- De wijzigingen zijn zichtbaar op zowel het lokale apparaat als de Nextcloud-webinterface.

<!-- Voeg hier eventueel een screenshot van het verwachte resultaat in. -->

## Test: Bestanden uploaden naar de Nextcloud-server

Testprocedure:

1. Klik op de knop om bestanden te uploaden.
2. Selecteer en upload een bestand vanaf je lokale apparaat.

Verwacht resultaat:

- Het bestand wordt succesvol geüpload naar de Nextcloud-server.
- Het geüploade bestand wordt weergegeven in de bestandenlijst.

<!-- Voeg hier eventueel een screenshot van het verwachte resultaat in. -->

## Test: Aanmaken van een kalenderevenement in Thunderbird en synchronisatie met Nextcloud-kalender

Testprocedure:

1. Open Thunderbird en navigeer naar de kalenderweergave.
2. Maak een nieuw kalenderevenement aan.
3. Sla het kalenderevenement op in de standaardkalender van Thunderbird.

Verwacht resultaat:

- Het kalenderevenement wordt succesvol aangemaakt in Thunderbird.
- Controleer of het nieuw aangemaakte kalenderevenement wordt gesynchroniseerd met de Nextcloud-kalender.

<!-- Voeg hier eventueel een screenshot van het verwachte resultaat in. -->

## Test: Controleren of het aangemaakte kalenderevenement wordt weergegeven in de Nextcloud-webinterface

Testprocedure:

1. Open een webbrowser en ga naar de Nextcloud-webinterface.
2. Navigeer naar de kalendersectie.
3. Controleer of het kalenderevenement dat is aangemaakt in Thunderbird, wordt weergegeven in de Nextcloud-kalender.

Verwacht resultaat:

- Het kalenderevenement dat is aangemaakt in Thunderbird, wordt correct weergegeven in de Nextcloud-kalender.
- De titel, datum, tijd en locatie van het evenement komen overeen met wat is ingevoerd in Thunderbird.

<!-- Voeg hier eventueel een screenshot van het verwachte resultaat in. -->
