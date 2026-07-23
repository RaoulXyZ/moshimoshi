---
name: release
description: Effettua una release di versione dell'app Android (APK/AAB) di MoshiMoshi. Usala quando l'utente chiede di "fare una release", "rilasciare una nuova versione", "buildare l'APK di release", "taggare una versione", "bump della versione" o "aggiornare il changelog". Segue SemVer, aggiorna pubspec.yaml, mantiene CHANGELOG.md (Keep a Changelog), builda l'artefatto firmato e crea il tag git.
---

# Release — App Android (MoshiMoshi)

Guida operativa per pubblicare una nuova versione dell'app. L'obiettivo è un
processo **ripetibile, tracciabile e reversibile**: SemVer per il numero di
versione, un CHANGELOG leggibile, un tag git per ogni release e un artefatto
firmato verificato.

## Principi

- **SemVer** (`MAJOR.MINOR.PATCH`):
  - `MAJOR` → cambiamenti incompatibili / breaking (es. reset dati locali Hive, cambio schema che invalida i dati esistenti).
  - `MINOR` → nuove funzionalità retrocompatibili.
  - `PATCH` → bugfix retrocompatibili.
- **Build number Android** (`versionCode`): il numero dopo `+` in `pubspec.yaml`
  (`version: X.Y.Z+N`). Deve essere **monotòno crescente** ad ogni build caricato,
  altrimenti Play Store / installazioni over-the-top rifiutano l'APK. Incrementalo
  SEMPRE, anche per una re-build della stessa versione.
- **Un tag git per release**: `vX.Y.Z`. Il tag è la fonte di verità di cosa è stato spedito.
- **Nulla di distruttivo senza conferma**: non forzare push, non cancellare tag, non sovrascrivere artefatti esistenti.

## Prerequisiti (verifica prima di iniziare)

1. Working tree **pulito** (`git status`). Se ci sono modifiche non committate,
   chiedi all'utente se includerle o metterle da parte — non committare a sorpresa.
2. Il file **`.env`** esiste nella root (è un asset in `pubspec.yaml`: senza, la
   build fallisce o l'app parte senza config). Non stamparne mai il contenuto.
3. Sei sul branch corretto (di norma `main`).

## Procedura

Esegui i passi in ordine. Fermati e segnala se un passo fallisce.

### 1. Determina la nuova versione

Leggi la versione attuale da `pubspec.yaml` (campo `version:`). Chiedi all'utente
il tipo di bump se non è già chiaro dalla richiesta:

- Se manca il build number (`+N`) nella versione attuale, adotta la convenzione
  `X.Y.Z+N` da questa release in poi (parti da `+1`, oppure allinea al numero di release).
- Calcola la nuova `MAJOR.MINOR.PATCH` secondo SemVer e **incrementa il build number**.

Esempio: da `1.3.0` (senza build) → nuova minor → `1.4.0+1`; successiva patch → `1.4.1+2`.

Puoi usare lo script helper per il bump automatico:

```powershell
# dalla root del progetto (Windows PowerShell 5.1 o pwsh)
powershell -File .claude/skills/release/bump_version.ps1 -Part minor   # major | minor | patch
```

Lo script aggiorna `version:` in `pubspec.yaml` incrementando la parte scelta e il
build number, e stampa la nuova versione. Scrive in UTF-8 senza BOM. Verifica
sempre il risultato con `git diff pubspec.yaml`.

### 2. Aggiorna il CHANGELOG

Mantieni `CHANGELOG.md` nel formato [Keep a Changelog](https://keepachangelog.com/it/1.1.0/).

- Sposta le voci dalla sezione `## [Unreleased]` in una nuova sezione
  `## [X.Y.Z] - AAAA-MM-GG` (data odierna, ISO 8601).
- Raggruppa le voci sotto le intestazioni standard, includendo solo quelle non vuote:
  `Added` (Aggiunto), `Changed` (Modificato), `Deprecated`, `Removed` (Rimosso),
  `Fixed` (Corretto), `Security`.
- Se `## [Unreleased]` è vuoto, ricava le voci dai commit dopo l'ultimo tag:
  `git log <ultimo-tag>..HEAD --oneline` (o da tutti i commit se non esistono tag).
  Riscrivi i messaggi in italiano, orientati all'utente finale (non "refactor X" ma
  cosa cambia per chi usa l'app). Scarta commit puramente interni (merge, format, CI).
- Lascia in cima una sezione `## [Unreleased]` vuota per il ciclo successivo.
- Aggiorna in fondo i link di confronto se presenti.

### 3. Controlli di qualità (devono passare)

```bash
flutter pub get
flutter analyze          # deve passare senza errori (vedi analysis_options.yaml + dart_code_metrics)
flutter test             # esegui la suite
```

Se `flutter analyze` o i test falliscono, **fermati**: non si rilascia su un albero rosso.
Riporta l'output all'utente.

### 4. Commit di release

Committa versione + changelog insieme, con un messaggio convenzionale:

```bash
git add pubspec.yaml CHANGELOG.md
git commit -m "chore(release): v X.Y.Z"
```

(Termina il messaggio con la riga `Co-Authored-By` come da convenzioni della repo.)

### 5. Build dell'artefatto firmato

> ℹ️ **Percorso ufficiale di produzione = CI.** Al push di un tag `vX.Y.Z` il workflow
> [.github/workflows/release-apk.yml](../../../.github/workflows/release-apk.yml) builda
> l'APK **firmato con il keystore di produzione** (secret su GitHub) e crea la GitHub
> Release con l'APK allegato. La build locale qui sotto usa la firma di **debug** (fallback
> quando manca `android/key.properties`) ed è quindi solo per test/verifica locale.

Genera l'APK di release (ed eventualmente l'App Bundle per il Play Store):

```bash
# APK universale (installazione diretta / distribuzione fuori dallo Store)
flutter build apk --release

# Consigliato per il Play Store (più piccolo, split per ABI):
flutter build appbundle --release
```

Artefatti prodotti:
- APK → `build/app/outputs/flutter-apk/app-release.apk`
- AAB → `build/app/outputs/bundle/release/app-release.aab`

> ⚠️ **Firma**: attualmente `android/app/build.gradle` firma la release con la
> `signingConfig signingConfigs.debug` (chiave di debug). Va bene per test interni,
> **NON per una pubblicazione pubblica / Play Store**. Se la release è pubblica,
> avvisa l'utente e proponi di configurare un keystore dedicato (vedi "Firma di
> produzione" sotto) prima di procedere. Non generare o committare keystore/password.

Verifica versione dell'artefatto (facoltativo ma consigliato):

```bash
# richiede Android SDK build-tools nel PATH
aapt dump badging build/app/outputs/flutter-apk/app-release.apk | Select-String "versionName|versionCode"
```

### 6. Tag e pubblicazione

Crea un tag annotato che punta al commit di release. **Chiedi conferma prima di pushare.**

```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z"
# dopo conferma esplicita dell'utente:
git push origin main
git push origin vX.Y.Z
```

Se la repo usa le GitHub Release: proponi di creare la release con il corpo preso
dalla sezione del CHANGELOG e l'APK/AAB allegato (`gh release create vX.Y.Z <artefatto> --notes-file ...`).
Non farlo senza conferma: è un'azione pubblica.

### 7. Riepilogo

Riporta all'utente: versione nuova, build number, percorso dell'artefatto, tag creato,
ed eventuali passi pubblici in sospeso (push, GitHub Release) che attendono conferma.

## Firma di produzione (setup una-tantum, opzionale)

Se serve una firma reale al posto di quella di debug:

1. Genera un keystore (fuori dalla repo, mai committarlo):
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Crea `android/key.properties` (aggiungilo a `.gitignore`):
   ```
   storePassword=...
   keyPassword=...
   keyAlias=upload
   storeFile=/percorso/assoluto/upload-keystore.jks
   ```
3. In `android/app/build.gradle`, carica `key.properties`, definisci un
   `signingConfigs.release` e usalo in `buildTypes.release` al posto di
   `signingConfigs.debug`.

## Checklist rapida

- [ ] Working tree pulito, `.env` presente, branch corretto
- [ ] Versione bumpata in `pubspec.yaml` (SemVer + build number incrementato)
- [ ] `CHANGELOG.md` aggiornato con data e voci per l'utente
- [ ] `flutter analyze` e `flutter test` verdi
- [ ] Commit `chore(release): vX.Y.Z`
- [ ] Build APK/AAB di release generata e verificata
- [ ] Firma adeguata al canale di distribuzione
- [ ] Tag `vX.Y.Z` creato (push solo dopo conferma)
