# Testrapport Matrix.org

- Uitvoerder(s) test: Leonard Van Iseghem
- Uitgevoerd op: 14/05
- Github commit: [05df4f3](https://github.com/HoGentTIN/sep2324-gent-g03/commit/05df4f3e8a068d7d8eff855881cf1d92f78ca8c1) & [2fca711](https://github.com/HoGentTIN/sep2324-gent-g03/commit/2fca711d81d6aef9c1072cef9922815d517432d2#diff-89ebe87d289209ef1c6541dca474acfd39db4dbc4c68748191b8dfafd5d37011)
- Auteur(s) testplan: Jasper Spilliaert

## Test: Is de provisioning succesvol gelukt?

Testprocedure: voer binnen de map /sep23-gent-g03/uitwerking/VMs/Linux het volgende commando in:

```powershell
    vagrant up matrix
```

Verkregen resultaat: 

![Provisioning](./img/provisioning.png)

## Test: Staat de Synapse service aan en werk die op localhost?

Testprocedure: Kijk na de provisioning of de synapse service draait door middel van volgende commando's.

```bash
    sudo systemctl status synapse
```

```bash
    curl localhost:8008
```

Verkregen resultaat:

![Synapse werkt](./img/synapse.png)
![curl](./img/curl_matrix.png)

Test geslaagd:

- [x] Ja
- [ ] Nee

## Test: Staat de webserver message service aan?

Testprocedure: Kijk of de webserver message service werkt zodat die berichten kan sturen naar de Encrypted Room.

```bash
    sudo systemctl status matrix_message_on_shutdown.service
```

![Matrix message](./img/matrix_message.png)

Test geslaagd:

- [x] Ja
- [ ] Nee

## Test: Staat de discord service aan?

Testprocedure: Na de provisioning moet er gekeken worden of de discord service draait met het volgende commando:

```bash
    sudo systemctl status discord
```

Verkregen resultaat:

![dc](./img/discordservice.png)

Test geslaagd:

- [x] Ja
- [ ] Nee

## Test: Kan je via Element op de WinClient de homeserver bereiken?

Testprocedure: Ga naar [Element](https://app.element.io/#/login), Druk bij homeserver op Edit en voer het homeserver adres in: https://matrix.g03-fft.internal

Verkregen resultaat:

![element](./img/SingIn.png)

Test geslaagd:

- [x] Ja
- [ ] Nee

Opmerkingen:

- Op de demo werkte dit met https://matrix.g03-fft.internal, maar we hebben er geen screenshot van gemaakt tijdens het uitvoeren van het testrapport

## Test: Is de Encrypted room succesvol aangemaakt en kun je een geëncrypteerd gesprek voeren met 2 users?

Testprocedure:

- Log in op 2 incongnito browsers op de homeserver met de gebruikers Jasper en Jorik
- Kijk of de room aangemaakt is en of de gebruiker Jasper erin zit
- Jasper inviteert Jorik tot het gesprek
- Stuur een bericht en kijk of het werkt

Verkregen resultaat:

![gesprek](./img/webserverMsg_Test.png)
![encrypted](./img/encrypted.png)

Test geslaagd:

- [x] Ja
- [ ] Nee

## Test: Wordt er een bericht verstuurd wanneer je de webserver stopt of heropstart?

Testprocedure:

- Ga naar de Encrypted room en voer het volgende commando uit op de matrix.org server:

```bash
    sudo systemctl restart nginx
```

Verkregen resultaat:

![](./img/webserverMsg_Test.png)

Test geslaagd:

- [x] Ja
- [ ] Nee

## Test: Heb je een Discord bot? En heeft die discord bot Administrator rechten op een Discord guild?

Testprocedure:

1. Zorg er eerst voor dat je een Discord account en Discord server hebt! -> Je kan je hiervoor registreren op Discord.com en een server maak je door in de discord applicatie of browser op het plusje te klikken en dan op "Create my Own" + "For me and my friends" en klik dan op Create.

Verkregen resultaat:

![](./img/Discordserver.png)

2. Dan maak je een Discord bot aan en daarvoor ga je naar [Discord Developer Portal](https://discord.com/developers/applications). Hiervoor klik je op de knop "New application", geef je discord bot daarna een naam en druk op "Create". Nu is je bot aangemaakt

Verkregen resultaat:

![](./img/NewBot.png)
![](./img/CreateBot.png)

3. Nu moet je de Bot toevoegen aan de Discord server. Eerst moet je een token krijgen van de bot en dat doe je door op aan de linker kant te klikken op "Bot" en dan druk je op Reset Token en kopiëer je die en sla je die ergens op (deze heb je later nodig). Na dat je dit deed klik je nu links op het tabblad "0Auth2". Ga naar URL Generator -> Selecteer bij "Scopes": bot, "Bot Permissions": Administrator. Nu zal je onderaan een link te zien krijgen. Kopiëer deze en plak die in je browser. Nu zal er gevraagd worden aan welke server je de bot wil toevoegen en dan kies je je gewenste server. Hierna zal er staan "Gelukt" en dan kan je klikken om naar de server te gaan.

Verkregen resultaat:

![](./img/ResetToken.png)
![](./img/0Auth2.png)
![](./img/LinkDCbot.png)
![](./img/serverConnect.png)
![](./img/Eindresultaat.png)

Eindresultaat:

![](./img/Eindresultaat2.png)

Test geslaagd:

- [x] Ja
- [ ] Nee

Opmerking:

- Alles hiervan moest maar 1x gebeuren op voorhand, dus zelfde screenshots als in Testplan

## Test: Werkt de Discord bridge?

Testprocedure:

- Log in als gebruiker Jasper of Jorik op Element
- Start een chat met de discordbot: @discordbot:matrix.g03-fft.internal
- Stuur een bericht, en voer het volgende commando in om je discord Bot te connecteren:

```bash
    login-token bot <Token-ID>
```

Verkregen resultaat:

![Chat](./img/Discord1_Test.png)

- Maak hierna een unencrypted room aan en invite de Discord bot. Stuur dan het volgende in de chat door:

```bash
    !discord guilds bridge <Guild-ID>
```

Verkregen resultaat:

![In room bridge maken](./img/Discord2.png)

- De gebruiker werd nu geïnviteerd door de Discord Bot om de Server te joinen. Accepteer dit. Daarna verstuur je als discord-user een bericht in een channel en krijgt de user hier ook een invite toe.

Verkregen resultaat:

![Generaal-chat](./img/Discord4_Test.png)
![Chat op discord](./img/Discord5_Test.png)

Test geslaagd:

- [x] Ja
- [ ] Nee

Opmerking:

- Geen screenshot gemaakt van !discord guilds bridge <Guild-ID>, maar werkte wel zoals hierboven te zien.
