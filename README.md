# 📍 Beacon

Beacon er en iOS-app som lar brukere utforske interessante steder i nærheten, basert på kategori og lokasjon.
Appen kombinerer kart, API-integrasjon og lokal lagring for å gi en enkel og inspirerende brukeropplevelse.

## ✨ Funksjoner

- 🔎 Søk etter steder med Geoapify Places API
- 🗺 Vis resultater på MapKit-kart og i listevisning
- 📍 Bruk GPS for å finne steder i nærheten
- ⭐ Gi vurderinger med stjerner (lagres med SwiftData)
- ❤️ Lagre favorittsteder lokalt
- 🔁 Pull-to-refresh og sortering
- ⚙️ Feilhåndtering og loading state

## 🧱 Teknologi

- Swift & SwiftUI
- Geoapify Places API
- SwiftData (lokal lagring)
- MapKit
- AppStorage & async/await

## 🚀 Kom i gang

1. Klon repoet:
   ```bash
   git clone https://github.com/chamL/Beacon.git


Prosjektet bruker en lokal fil Keys.plist for å lagre API-nøkler trygt. 
Denne filen er lagt til i .gitignore og er derfor ikke med i GitHub-repoet.
Du må opprette den manuelt for at appen skal fungere.

## Slik lager du Keys.plist:

Gå til prosjektmappen i Xcode.

Lag en ny fil med navn Keys.plist (File > New > File > Property List).

Legg til følgende innhold:

   <?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>GeoapifyAPIKey</key>
    <string>DIN_API_NØKKEL_HER</string>
</dict>
</plist>
