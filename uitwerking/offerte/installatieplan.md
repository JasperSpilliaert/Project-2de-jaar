# Installatieplan

Dit uitgebreide installatieplan vormt de leidraad voor het opzetten van de serverruimte van onze onderneming.

## Plaatsing van Hardware

### Wandkast

- **Beschrijving:** 18U wandkast met glazen deur 600x600x900mm
- **Aantal:** 1
- **Plaatsing:**
  - Gepositioneerd in het midden van de serverruimte voor optimale toegankelijkheid.

### Servers

- **Beschrijving:** Server Dell R430 8SFF
- **Aantal:** 2
- **Plaatsing:**
  - Monteer de servers in de wandkast op een rack voor gestructureerde opstelling.
  - Zorg voor voldoende ruimte tussen de servers voor luchtcirculatie.

### Switches

- **Beschrijving:** Cisco Catalyst Managed L2
- **Aantal:** 2
- **Plaatsing:**
  - Bevestig de switches in het bovenste gedeelte van de wandkast voor optimale connectiviteit.
  - Sluit aan op de serverinfrastructuur en zorg voor ordelijke bekabeling.

### Routers

- **Beschrijving:** Cisco C921-4P
- **Aantal:** 2
- **Plaatsing:**
  - Installeer de routers in de wandkast in de buurt van de switches.

### Randapparatuur

- **Beschrijving:** Lenovo IdeaPad, Logitech MK120, AOC 24B2XHM2, Cisco USB naar consolekabel, BlueBuilt HDMI Kabel
- **Aantal:** 1 van elk
- **Plaatsing:**
  - Plaats de randapparatuur bij de administratieve werkplek binnen de serverruimte.

### UPS

- **Beschrijving:** UPS for RTII 2000VA 1800W rack cabinet with LCD
- **Aantal:** 1
- **Plaatsing:**
  - Installeer de UPS aan de onderkant van de wandkast voor een gecontroleerde stroomvoorziening.
  - Zorg voor duidelijke labels voor snelle identificatie.

## Installatiestappen

1. **Netwerkkabels**

   - Verbind servers, switches en routers met de Goobay CAT 6 netwerkkabels.
   - Zorg voor ordelijke bekabeling.

2. **Overige randapparatuur**

   - Sluit alle randapparatuur aan op de serverapparatuur.
   - Installeer benodigde drivers of software.

3. **Software-installatie**
   - Configureer servers en switches volgens specificaties.
   - Installeer besturingssystemen en voer updates uit.
   - Voer uitgebreide testen uit van de configuratie.

### FullFiber Extended Installatieplan 

#### 1. Voorbereiding:
- Zorg dat de serverruimte klaar is voor de installatie.

#### 2. Fysieke Installatie:
- Werk samen met Proximus (serviceprovider) voor de installatie van glasvezelbekabeling van het aansluitpunt naar de serverruimte. De positie van het aansluitpunt bevind zich in de serverruimte.
- Bevestig glasvezelkabels op een veilige en ordelijke wijze.

#### 3. Verbinding met Apparatuur:

- Sluit de glasvezelkabels aan op de juiste poorten van netwerkapparatuur.
- Voer configuraties uit voor activering van de FullFiber verbinding.
- Voer testen uit voor performance & stabiliteit van de verbinding (+ signaalsterkte, latentie, ...)
- Configureer netwerkapparatuur voor optimaal gebruik van de FullFiber verbinding.