---
lang: it
permalink: /it/blog/reverse-engineering-oracle-iban/
title: "Reverse engineering su Oracle: come trovare la colonna IBAN senza schema (REPL, catalogo, e il rischio di fare damage in produzione)"
date: 2026-10-09 07:30:00 +0200
author: "Antonio Trento"
description: "Metodo cauto per esplorare un DB Oracle legacy senza documentazione: read replica o utente SELECT-only, ricerca nel data dictionary (all_tab_columns, commenti, constraint), pattern IBAN/ABI/CAB, PII e quando fermarsi e chiamare il DBA."
keywords: ["reverse engineering oracle iban", "oracle data dictionary", "sqlplus catalogo", "ricerca colonne oracle", "replica read-only", "esplorare db legacy"]
image: /assets/images/posts/reverse-engineering-oracle-iban.jpg
pillar: integrazioni-dati
related: [/it/blog/salesforce-jwt-export-csv-docker/, /it/blog/agente-imap-pec-fatture/]
---

## Ti danno un Oracle di vent'anni e ti dicono "l'IBAN è lì dentro"

La richiesta arriva così: "dobbiamo tirare fuori gli IBAN dei clienti da quel database, l'integrazione nuova ne ha bisogno". Ti danno le credenziali di un Oracle che gira da vent'anni, senza uno schema documentato, senza un ERD aggiornato, con nomi di tabelle come `ANAG_CLI_T` e `TAB_RAPP_02` e chi ha scritto tutto questo è andato in pensione nel 2011. Da qualche parte, in una delle centinaia di tabelle, c'è la colonna con l'IBAN. Devi trovarla senza rompere niente.

Questo è il **reverse engineering su Oracle** per trovare l'IBAN (o qualsiasi altro dato) senza schema, ed è un mestiere che si fa in punta di piedi: il database è in produzione, ci lavorano applicazioni vere, e una query esplorativa fatta male può bloccare tabelle, saturare risorse e causare un disservizio. L'angolo di questo pezzo è deliberato: **legacy integration, cauta e professionale.** Non "smanettare finché non trovi", ma un metodo con regole di ingaggio precise.

Vedremo perché i legacy non hanno un ERD aggiornato, perché si esplora **solo** su una read replica o con un utente SELECT-only (mai toccare prod), come interrogare il **data dictionary di Oracle** (`all_tab_columns`, i commenti, i constraint) per ricostruire lo schema, come cercare l'IBAN per nome *e* per pattern dei dati (attenzione ai nomi legacy italiani: ABI, CAB, CIN), perché si lavora da REPL e script versionati e non a colpi di click su una GUI, come non esportare otto milioni di clienti "per provare", come documentare ciò che trovi, e — soprattutto — quando fermarsi e chiamare il DBA.

È lo stesso rispetto per i dati e per i sistemi di produzione della ricetta di export che ho descritto per {{ '/it/blog/salesforce-jwt-export-csv-docker/' | relative_url }}: privilegio minimo, sola lettura, niente sorprese. Qui il sistema è più vecchio e più fragile, quindi la cautela è ancora maggiore.

## Perché i legacy non hanno un ERD aggiornato

Prima del metodo, il contesto, perché spiega tutte le cautele. Un database legacy di produzione, tipicamente:

- **Non ha documentazione allineata.** Se un ERD è mai esistito, è su un file Visio del 2009 che non corrisponde più alla realtà: negli anni sono state aggiunte colonne, create tabelle "temporanee" diventate permanenti, aggiunti campi con nomi criptici da chi andava di fretta.
- **Ha nomi opachi.** Convenzioni di naming di epoche diverse, abbreviazioni, numeri progressivi (`TAB_02`, `RAPP_STOR`), campi riusati per scopi diversi da quello originale.
- **Ha dati "sporchi" e storici.** Colonne obsolete mai rimosse, valori di test in mezzo a quelli veri, formati cambiati nel tempo.
- **È vivo e critico.** Ci girano sopra applicazioni in produzione. Non è un dataset da laboratorio: è il cuore operativo di qualcosa, e va trattato con il rispetto che merita un sistema che se cade blocca il lavoro di qualcuno.

Da qui la regola d'oro che governa tutto: **esplorare un legacy è un'operazione a rischio, e il rischio va gestito prima ancora di scrivere la prima query.** Il valore che porti non è "so scrivere SQL": è che sai farlo *senza fare danni* e producendo qualcosa di durevole (la documentazione dello schema). Chi si butta a smanettare su prod è un pericolo, non un professionista.

## Read replica o utente SELECT-only: non toccare la produzione

La prima decisione, prima di qualsiasi query, è **dove** esplori. E la risposta non è mai "sul database di produzione con l'utente che mi hanno dato". Le opzioni, in ordine di preferenza:

- **Read replica (la migliore).** Una copia in sola lettura del database (in Oracle, tipicamente uno standby di Data Guard aperto in read-only, o una replica logica). Esplori lì: qualsiasi query, anche pesante, non tocca la produzione. Se satura la replica, hai rallentato una copia, non il sistema vero.
- **Utente SELECT-only su produzione (accettabile con cautela).** Se non c'è una replica, ti fai creare dal DBA un utente con **solo il privilegio SELECT** sugli schemi che ti servono, e nient'altro. Niente UPDATE, DELETE, INSERT, niente DDL. Meglio ancora, imposta la sessione in sola lettura.
- **Mai** l'utente applicativo con permessi di scrittura, "tanto faccio solo SELECT". Un utente che *può* scrivere è un utente con cui *puoi sbagliare* a scrivere. La sicurezza non deve dipendere dalla tua attenzione: deve essere strutturale.

La **replica read-only** o l'utente SELECT-only non sono burocrazia: sono ciò che rende impossibile il danno peggiore. Con un utente che può solo leggere, il caso peggiore di un errore è "una query lenta", non "ho aggiornato per sbaglio diecimila record". E se lavori su una replica, nemmeno la query lenta tocca la produzione.

Imposta esplicitamente la sessione in sola lettura, come cintura di sicurezza in più:

```sql
-- Cintura di sicurezza: la sessione non può scrivere, nemmeno per errore.
SET TRANSACTION READ ONLY;
-- (su una read replica standby è già così; su prod con utente SELECT-only,
--  è comunque una protezione esplicita e dichiarata)
```

Il rischio del "**damage in produzione**" del titolo è reale e va nominato: una query esplorativa che fa un full scan su una tabella da otto milioni di righe, lanciata in orario di lavoro su prod, può saturare I/O e CPU e rallentare le applicazioni vere fino al disservizio. Non serve un UPDATE per fare danni: basta una SELECT ingorda nel momento sbagliato. Ecco perché la replica è la risposta giusta, e perché anche in sola lettura si lavora con testa (limiti, orari, EXPLAIN PLAN — ci arrivo).

## Il catalogo: all_tab_columns, commenti, constraint

Ora il cuore tecnico. Oracle espone il proprio schema attraverso il **data dictionary**: viste di sistema che descrivono tabelle, colonne, commenti, vincoli. Sono la mappa del tesoro, e imparare a interrogarle è metà del mestiere. Le viste che uso, con il prefisso giusto:

- `ALL_TABLES` / `ALL_TAB_COLUMNS`: le tabelle e le colonne accessibili al tuo utente (con tipo, lunghezza, nullabilità).
- `ALL_COL_COMMENTS` / `ALL_TAB_COMMENTS`: i **commenti** su colonne e tabelle. Spesso sono l'unica documentazione superstite: un vecchio DBA che ha scritto `-- codice IBAN cliente` su una colonna ti risparmia ore.
- `ALL_CONSTRAINTS` / `ALL_CONS_COLUMNS`: i vincoli — chiavi primarie, chiavi esterne, unique. Le **foreign key** ti ricostruiscono le relazioni, cioè l'ERD che non ti hanno dato.
- `ALL_IND_COLUMNS`: gli indici, che spesso rivelano quali colonne sono importanti (le colonne indicizzate sono quelle su cui si cerca).

Nota il prefisso: `ALL_*` mostra ciò che il tuo utente può vedere; `USER_*` solo il tuo schema; `DBA_*` tutto ma richiede privilegi da DBA. Per un'esplorazione con utente SELECT-only, `ALL_*` è ciò che userai.

La prima query, sempre, è capire *quanto è grande il problema*:

```sql
-- Quante tabelle, quante colonne: la scala dell'esplorazione
SELECT COUNT(DISTINCT table_name) AS tabelle, COUNT(*) AS colonne
FROM all_tab_columns
WHERE owner = 'SCHEMA_LEGACY';
```

E poi si legge la documentazione superstite, i commenti:

```sql
-- I commenti sono spesso l'unica documentazione rimasta
SELECT c.table_name, c.column_name, m.comments
FROM all_tab_columns c
LEFT JOIN all_col_comments m
  ON m.owner = c.owner AND m.table_name = c.table_name
 AND m.column_name = c.column_name
WHERE c.owner = 'SCHEMA_LEGACY'
  AND m.comments IS NOT NULL;
```

Il **catalogo via sqlplus** (o qualsiasi client scriptabile) è il punto di partenza di ogni reverse engineering serio: prima capisci la forma del database dal dizionario, poi vai a cercare il dato specifico. Saltare questo passo e andare "a naso" sulle tabelle è come cercare una via in una città senza guardare la mappa.

## Ricerca semantica: IBAN, SWIFT, e i nomi legacy italiani

Ora la caccia all'IBAN. Si procede su due binari paralleli: **ricerca per nome** (come si chiama la colonna) e **ricerca per pattern dei dati** (che forma hanno i valori). Servono entrambi, perché nei legacy il nome spesso mente.

### Ricerca per nome

Cerchi nel dizionario le colonne il cui nome assomiglia a ciò che cerchi:

```sql
-- Colonne che "suonano" come IBAN / coordinate bancarie
SELECT owner, table_name, column_name, data_type, data_length
FROM all_tab_columns
WHERE owner = 'SCHEMA_LEGACY'
  AND (  UPPER(column_name) LIKE '%IBAN%'
      OR UPPER(column_name) LIKE '%SWIFT%'
      OR UPPER(column_name) LIKE '%BIC%'
      OR UPPER(column_name) LIKE '%CONTO%'
      OR UPPER(column_name) LIKE '%RAPP%'      -- "rapporto" bancario
      OR UPPER(column_name) LIKE '%COORD%' )
ORDER BY table_name, column_name;
```

E qui il punto che frega chi non conosce i legacy bancari italiani: **prima dell'IBAN, in Italia si usavano ABI, CAB, CIN e numero conto.** Un database vecchio potrebbe non avere affatto una colonna `IBAN`, ma avere `COD_ABI`, `COD_CAB`, `CIN`, `NUM_CONTO` da cui l'IBAN si *ricostruisce*. Oppure avere sia i campi storici sia un IBAN aggiunto dopo. La **ricerca delle colonne** deve includere questi termini italiani, o cercherai un IBAN che non esiste come tale mentre i dati sono lì, sotto altri nomi.

```sql
-- Nomi legacy bancari italiani: ABI, CAB, CIN, conto
SELECT owner, table_name, column_name, data_type
FROM all_tab_columns
WHERE owner = 'SCHEMA_LEGACY'
  AND ( UPPER(column_name) LIKE '%ABI%'
     OR UPPER(column_name) LIKE '%CAB%'
     OR UPPER(column_name) LIKE '%CIN%'
     OR UPPER(column_name) LIKE '%C_C%'
     OR UPPER(column_name) LIKE '%NUM_CONTO%' );
```

### Ricerca per pattern dei dati

Il nome può ingannare: una colonna `NOTE` o `CAMPO_LIBERO_3` potrebbe contenere IBAN infilati lì negli anni. Per questo si cerca anche per **forma del dato**, con estrema cautela sui volumi (vedi la sezione PII): un IBAN italiano ha un formato riconoscibile (`IT` + 2 cifre + 1 lettera + 22 cifre). Su un **campione**, non sull'intera tabella:

```sql
-- Cerca valori che SEMBRANO IBAN, su un CAMPIONE (mai tutta la tabella)
SELECT column_value_sospetto
FROM (
  SELECT qualche_colonna AS column_value_sospetto
  FROM SCHEMA_LEGACY.TABELLA_SOSPETTA
  WHERE ROWNUM <= 100                       -- CAMPIONE: limita sempre
)
WHERE REGEXP_LIKE(column_value_sospetto, '^IT[0-9]{2}[A-Z][0-9]{22}$');
```

La **ricerca semantica** combina i due binari: il nome ti dà i candidati, il pattern conferma quale contiene davvero l'IBAN e in che formato (con o senza spazi, con o senza il prefisso paese). Trovare la colonna è solo metà: devi capire il *formato* con cui è memorizzata, perché l'integrazione a valle dovrà normalizzarlo.

## Dall'IBAN al cliente: ricostruire il join

Trovare la colonna IBAN è metà del lavoro. L'altra metà è capire **a chi appartiene**: l'integrazione non vuole una lista di IBAN nel vuoto, vuole "IBAN del cliente X". E qui entra in gioco la ricostruzione delle relazioni, che nei legacy è dove si annidano le trappole più costose.

Le foreign key nel dizionario ti danno la mappa dei join. Le interroghi così:

```sql
-- Le foreign key in uscita dalla tabella dei rapporti: dove punta?
SELECT c.constraint_name, cc.column_name AS colonna_locale,
       r.table_name AS tab_riferita, rc.column_name AS colonna_riferita
FROM all_constraints c
JOIN all_cons_columns cc ON cc.constraint_name = c.constraint_name
JOIN all_constraints r   ON r.constraint_name = c.r_constraint_name
JOIN all_cons_columns rc ON rc.constraint_name = r.constraint_name
WHERE c.owner = 'SCHEMA_LEGACY'
  AND c.table_name = 'ANAG_RAPP_T'
  AND c.constraint_type = 'R';        -- R = referential (foreign key)
```

Scopri così che `ANAG_RAPP_T.ID_CLIENTE` punta a `ANAG_CLI_T.ID`, e hai il join. Ma prima di scriverlo nell'integrazione, tre trappole tipiche dei legacy che vanno verificate sul campione:

- **Un cliente, molti rapporti (uno-a-molti).** Un cliente può avere più conti, quindi più IBAN. La query di export deve gestire il molti — non assumere un IBAN per cliente, o perdi dati o duplichi righe. Verifica con un `COUNT` per cliente su un campione.
- **Rapporti chiusi o cessati.** Un cliente può avere IBAN storici di conti chiusi accanto a quello attivo. Spesso c'è una colonna di stato (`FLG_ATTIVO`, `DT_CHIUSURA`): l'integrazione vuole l'IBAN *attivo*, non quello di un conto chiuso nel 2015. Cerca la colonna di stato e filtra.
- **Foreign key "logiche" non dichiarate.** Nei legacy peggiori la relazione esiste nei dati ma **non** come constraint dichiarato (join fatti a mano nel codice applicativo). Se `all_constraints` non mostra la FK, cerca colonne con lo stesso nome/tipo tra le tabelle (`ID_CLIENTE` in entrambe) e verifica sul campione che i valori combacino. Documenta che è una relazione *dedotta*, non garantita dal database.

La lezione: **il join non si assume, si verifica.** Un'integrazione costruita su una relazione sbagliata (un IBAN attribuito al cliente sbagliato, o quello di un conto chiuso) è peggio di nessuna integrazione, perché produce dati plausibili ma falsi. Ricostruisci le relazioni dalle foreign key dove ci sono, deducile con cautela dove non ci sono, e in entrambi i casi conferma su un campione prima di fidarti.

## REPL e script batch: niente click a caso sulla GUI

Un principio metodologico che separa i professionisti dai pericoli: **si esplora da REPL scriptabile (sqlplus, o un client da riga di comando) con query salvate in file `.sql` versionati, non cliccando a caso in una GUI.** Le ragioni sono serie, non stilistiche:

- **Riproducibilità.** Una query salvata in un file la rilanci identica, la rivedi, la condividi col DBA per validazione. Un click in una GUI è un gesto che sparisce: non sai più cosa hai eseguito.
- **Sicurezza.** Le GUI da DBA (i vari tool grafici) hanno menù contestuali dove un click sbagliato può lanciare un'azione distruttiva, o aprire un editor che con un tasto esegue un DDL. Da riga di comando, esegui *solo* ciò che scrivi, e lo vedi prima di premere invio.
- **Controllo del volume.** In una GUI è facile fare doppio click su una tabella e "aprirla", scatenando un `SELECT *` implicito su milioni di righe. Da script, il `WHERE ROWNUM <= N` lo scrivi tu, coscientemente.
- **Tracciabilità.** Gli script versionati sono la storia di cosa hai esplorato — utile per te, per il DBA, e per l'audit (stai toccando dati sensibili).

```bash
# Esplorazione riproducibile: query in file .sql versionati, output su file
sqlplus -S utente_readonly/@replica @01_conta_tabelle.sql   > out/01.txt
sqlplus -S utente_readonly/@replica @02_cerca_iban_nome.sql > out/02.txt
sqlplus -S utente_readonly/@replica @03_pattern_iban.sql    > out/03.txt
# ogni .sql è versionato in git: sai esattamente cosa hai eseguito e quando
```

Questo non è pedanteria: è la differenza tra un'esplorazione che puoi difendere ("ecco esattamente le query che ho lanciato, tutte in sola lettura, tutte con limiti") e un'esplorazione che è stata un pomeriggio di click di cui non resta traccia. Su un sistema di produzione con dati bancari, la prima è professionale, la seconda è un rischio legale oltre che tecnico.

## PII: come non esportare otto milioni di clienti "per provare"

Qui la cautela diventa questione di compliance, non solo di prudenza tecnica. Il database contiene **dati personali** — anzi, dati bancari, tra i più sensibili. La tentazione, esplorando, è fare `SELECT * FROM CLIENTI` "per vedere com'è fatto". Su una tabella da otto milioni di clienti, quel comando è: un carico enorme sul database, un potenziale trasferimento di milioni di dati personali sul tuo schermo/file, e — se salvi l'output — un archivio di PII che ti sei creato senza alcuna base né protezione. Un data breach autoinflitto "per provare".

Le regole non negoziabili sull'esposizione dei dati durante l'esplorazione:

- **Campiona, non scaricare.** Per capire la forma di una colonna bastano dieci righe (`WHERE ROWNUM <= 10`), non otto milioni. Il formato dell'IBAN lo capisci da un campione minuscolo.
- **Lavora su dati mascherati quando possibile.** Se esiste una replica con dati mascherati/anonimizzati per sviluppo, esplora lì: capisci lo schema senza mai vedere un IBAN vero.
- **Non salvare output con PII.** Gli output delle tue query esplorative, se contengono dati reali, non finiscono su file lasciati in giro. Salvi la *struttura* (nomi, tipi, formati), non i *valori*.
- **Minimizza sempre.** Il principio GDPR di minimizzazione vale anche in fase di esplorazione: guardi il minimo indispensabile per capire, non "tutto per sicurezza".

Il punto: **esplorare lo schema non richiede di vedere i dati di tutti.** Ti serve sapere *dove* sta l'IBAN e *com'è formattato*, non leggere gli IBAN di otto milioni di persone. Un professionista capisce la struttura con dieci righe di campione; un incauto scarica tutto e si crea un problema. La differenza, di nuovo, non è tecnica: è disciplina sui dati.

## L'architettura di riferimento (regole di ingaggio)

Ecco come dispongo un'esplorazione legacy, con i confini che sono, in questo caso, delle vere e proprie **regole di ingaggio**.

```
   DB Oracle LEGACY (PRODUZIONE) ─── ⛔ NON esplorare qui direttamente
            │
            │ (replica / privilegi minimi)
            ▼
   ┌────────────────────────────────────────────────┐
   │ AMBIENTE DI ESPLORAZIONE                          │
   │  • READ REPLICA (preferito) oppure               │
   │  • utente SELECT-only + SET TRANSACTION READ ONLY │
   └───────────────────┬──────────────────────────────┘
                       ▼
   ┌────────────────────────────────────────────────┐
   │ CATALOGO: all_tab_columns, *_comments,           │
   │ all_constraints (relazioni via FK)               │
   └───────────────────┬──────────────────────────────┘
                       ▼
   ┌────────────────────────────────────────────────┐
   │ RICERCA: per nome (IBAN/ABI/CAB/CIN) +           │
   │ per pattern dati su CAMPIONE (ROWNUM<=N)         │
   └───────────────────┬──────────────────────────────┘
                       ▼
   ┌────────────────────────────────────────────────┐
   │ DOCUMENTAZIONE schema (markdown versionato)      │
   └────────────────────────────────────────────────┘
   Tutto da REPL/script .sql versionati · DBA coinvolto per dubbi/privilegi
```

**Le regole di ingaggio (cosa NON si fa, mai):**

- **Nessuna scrittura:** no UPDATE, DELETE, INSERT, DDL. Utente in sola lettura, sessione read-only.
- **Nessun carico su prod:** si esplora su replica; se proprio su prod, con limiti (`ROWNUM`), fuori orario di punta, e con l'EXPLAIN PLAN prima delle query pesanti.
- **Nessun scarico di PII:** campioni minuscoli, mai `SELECT *` su tabelle grandi, mai salvare valori reali.
- **Niente GUI a caso:** query scritte, viste, versionate, non click.
- **DBA nel loop:** per i privilegi, per validare le query pesanti, e nei momenti di dubbio.

Queste regole sono lo stesso principio di privilegio minimo e rispetto della produzione dell'export Salesforce, portato all'estremo perché il sistema è più fragile e i dati più sensibili. Su un legacy bancario, la cautela non è mai troppa.

## Documentare lo schema trovato: markdown, non nella testa

Ecco l'errore che vanifica tutto il lavoro: trovare la colonna IBAN, usarla per l'integrazione, e **non documentare nulla.** Sei mesi dopo (o il collega dopo di te) si ritrova a rifare la stessa caccia da zero, perché la conoscenza era nella tua testa e la tua testa era occupata. Il **prodotto** del reverse engineering non è "ho trovato l'IBAN": è **la documentazione dello schema** che hai ricostruito, versionata, condivisibile.

Un template markdown per documentare ciò che trovi:

```markdown
# Schema legacy Oracle — mappatura per integrazione (SCHEMA_LEGACY)
_Ultimo aggiornamento: 2026-10-09 — esplorato da: [nome] — su: read replica_

## Coordinate bancarie cliente
| Dato        | Tabella        | Colonna      | Tipo        | Formato / note |
|-------------|----------------|--------------|-------------|----------------|
| IBAN        | ANAG_RAPP_T    | COD_IBAN     | VARCHAR2(27)| `ITkk...`, senza spazi, ~5% NULL |
| ABI (legacy)| ANAG_RAPP_T    | COD_ABI      | CHAR(5)     | storico, presente su record < 2008 |
| CAB (legacy)| ANAG_RAPP_T    | COD_CAB      | CHAR(5)     | storico |
| Cliente FK  | ANAG_RAPP_T    | ID_CLIENTE   | NUMBER      | → ANAG_CLI_T.ID |

## Relazioni rilevanti (da all_constraints)
- `ANAG_RAPP_T.ID_CLIENTE` → FK → `ANAG_CLI_T.ID` (un cliente, N rapporti)

## Note / trappole
- Alcuni IBAN esteri non rispettano il pattern IT: gestire nel mapping.
- `CAMPO_NOTE_3` conteneva IBAN a mano in vecchi record: NON affidabile.

## Query usate (riferimento ai file versionati)
- `02_cerca_iban_nome.sql`, `03_pattern_iban.sql`
```

La documentazione è il deliverable durevole. Include: dove sta il dato, in che formato, quanto è "sporco" (percentuale di NULL, eccezioni), le relazioni ricostruite dalle foreign key, le trappole trovate, e i riferimenti alle query usate. **Documentare in markdown versionato, non nella testa**, trasforma un'esplorazione una tantum in conoscenza aziendale riutilizzabile — che è il vero valore del lavoro.

## Percorso di implementazione, a step

1. **Concorda l'accesso col DBA:** ottieni una read replica o un utente SELECT-only sugli schemi necessari. Mai l'utente applicativo di scrittura.
2. **Imposta la sessione in sola lettura** e verifica di non poter scrivere.
3. **Misura la scala** dal dizionario: quante tabelle, quante colonne, quali schemi.
4. **Leggi i commenti** (`all_col_comments`, `all_tab_comments`): spesso sono l'unica documentazione.
5. **Cerca per nome** l'IBAN e i termini legacy italiani (ABI, CAB, CIN, conto, rapporto).
6. **Conferma per pattern** su campioni minuscoli (`ROWNUM`), verificando il formato reale.
7. **Ricostruisci le relazioni** dalle foreign key (`all_constraints`, `all_cons_columns`).
8. **Documenta in markdown versionato** tabelle, colonne, formati, trappole, relazioni.
9. **Coinvolgi il DBA** per validare le query pesanti e nei dubbi.
10. **Consegna la documentazione** come deliverable, non solo "ho trovato la colonna".

## I fallimenti tipici e come li riconosci

- **Query esplorativa che rallenta la produzione.** Un full scan su una tabella enorme in orario di punta: il DBA vede picchi di I/O/CPU e sessioni lente. Sintomo: lamentele dalle applicazioni mentre esplori. Fix: replica, limiti, EXPLAIN PLAN, fuori orario.
- **`ORA-00942: table or view does not exist`** su una tabella che "dovrebbe" esserci: il tuo utente non ha il SELECT su quello schema, o cerchi in `USER_*` invece di `ALL_*`. Verifica i grant e il prefisso della vista di dizionario.
- **IBAN cercato e non trovato… perché non esiste come IBAN.** Il legacy ha ABI/CAB/CIN/conto separati, non un campo IBAN. Se cerchi solo "IBAN" concludi erroneamente "non c'è". Cerca i nomi legacy italiani.
- **Colonna trovata ma piena di formati diversi.** IBAN con spazi, senza spazi, con/senza prefisso paese, valori esteri, campi liberi inquinati. Un campione lo rivela; affidarsi al nome no. Documenta il formato reale.
- **Output con PII salvato su file.** Ti ritrovi un `.csv` con IBAN veri sul disco "dai test": è un problema. Cancellalo, e d'ora in poi salva struttura, non valori.
- **`ORA-01031: insufficient privileges`** quando provi a leggere `DBA_*`: usa `ALL_*`, o chiedi al DBA. Non è un ostacolo da aggirare, è un confine.

La regola: **se una query ti preoccupa (volume, lentezza, privilegi), fermati e chiedi al DBA prima di lanciarla.** Su un legacy di produzione, il dubbio è un segnale, non un fastidio.

## Costi: ordini di grandezza

Stime dichiarate.

- **Accesso:** creare una read replica ha un costo (storage, licenza Oracle a seconda dell'opzione di replica) che il cliente probabilmente ha già per il disaster recovery; se no, un utente SELECT-only è a costo zero ma sposta il rischio su prod (da mitigare coi limiti). Il DBA quantifica.
- **Tempo di esplorazione:** come ordine di grandezza, da mezza a qualche giornata per trovare e documentare un dato specifico in uno schema legacy medio, di più se lo schema è vasto e mal documentato. Il grosso del tempo è capire i nomi opachi e le trappole, non scrivere le query.
- **Calcolo:** le query di dizionario sono leggerissime; le query sui dati, se campionate, trascurabili. Il costo computazionale è un problema solo se sbagli e fai full scan su prod — motivo in più per la replica.
- **Il valore prodotto:** la documentazione dello schema è un asset riutilizzabile che evita di rifare la caccia ogni volta. Si ripaga alla seconda integrazione che pesca dallo stesso legacy.
- **Costo del farlo male:** un disservizio in produzione causato da una query ingorda, o un data breach da un export "di prova" di dati bancari. Entrambi costano molto più della cautela — in denaro, in fiducia, e potenzialmente in sanzioni.

## Quando NON farlo (e quando chiamare il DBA)

- **Se non hai una replica né un utente SELECT-only**, non esplorare con un utente che può scrivere: fermati e fatti dare l'accesso giusto. L'accesso corretto è la precondizione, non un dettaglio.
- **Se una query rischia di pesare su prod** e non c'è replica, non lanciarla "per vedere": chiedi al DBA di validarla, usa EXPLAIN PLAN, e schedulala fuori orario. Il DBA conosce il carico del sistema meglio di te.
- **Se ti serve un privilegio che non hai** (leggere `DBA_*`, accedere a uno schema), non cercare workaround: chiedi. I confini di privilegio ci sono per un motivo.
- **Se stai per esportare dati reali "per analizzare"**, fermati: campiona, o lavora su dati mascherati. Non creare un archivio di PII bancaria fuori dal database.
- **Nel dubbio, chiama il DBA.** Non è un fallimento: è professionalità. Su un sistema di produzione critico, il DBA è il custode, e coinvolgerlo per le operazioni sensibili è la cosa giusta. Sapere quando fermarsi e chiedere è ciò che distingue chi puoi far lavorare su un legacy da chi no.

## Checklist operativa prima di iniziare

- [ ] **Accesso in sola lettura** concordato: read replica (preferita) o utente SELECT-only.
- [ ] **`SET TRANSACTION READ ONLY`** impostato; verificato di non poter scrivere.
- [ ] **Esplorazione da REPL/script `.sql` versionati**, non da click su GUI.
- [ ] **Dizionario prima dei dati:** scala, commenti, poi ricerca.
- [ ] **Ricerca per nome** che include i termini legacy italiani (ABI, CAB, CIN, conto, rapporto).
- [ ] **Conferma per pattern su campioni** (`ROWNUM <= N`), mai su tabelle intere.
- [ ] **Relazioni ricostruite** dalle foreign key (`all_constraints`).
- [ ] **Nessun `SELECT *`** su tabelle grandi; nessun output con PII salvato.
- [ ] **Documentazione markdown versionata** di tabelle, colonne, formati, trappole, relazioni.
- [ ] **DBA coinvolto** per privilegi, query pesanti e dubbi.
- [ ] **EXPLAIN PLAN** prima di query potenzialmente pesanti (se proprio su prod).

## Il verdetto

Il **reverse engineering su Oracle** per trovare l'IBAN senza schema è un lavoro che si giudica non da "ho trovato la colonna", ma da *come* ci sei arrivato e da *cosa* lasci dietro. Il metodo professionale è cauto per costruzione: esplori su una read replica o con un utente in sola lettura, così il danno peggiore è una query lenta, non un dato corrotto; interroghi il data dictionary prima di toccare i dati, perché la mappa viene prima del territorio; cerchi l'IBAN per nome *e* per pattern, sapendo che nei legacy italiani il dato può nascondersi dietro ABI, CAB, CIN e numero conto; lavori da REPL con query versionate, non a colpi di click che non lasciano traccia; e non scarichi mai otto milioni di clienti "per provare", perché per capire lo schema bastano dieci righe.

Ma la parte che trasforma un'esplorazione in valore è il deliverable: **la documentazione dello schema, in markdown versionato, non nella tua testa.** Dove sta il dato, com'è formattato, quanto è sporco, come si relaziona: questa è la conoscenza che evita di rifare la caccia ogni volta, ed è il vero prodotto del lavoro. Senza, hai risolto un problema una volta; con, hai creato un asset per l'azienda.

E la cautela non è timidezza: è competenza. Sapere quando una query può pesare sulla produzione, quando serve il DBA, quando fermarsi e chiedere invece di forzare — è esattamente ciò che distingue chi puoi mettere le mani su un sistema legacy critico da chi no. Su un database bancario di vent'anni, che regge operazioni vere, il professionista è quello che trova l'IBAN senza che nessuno si accorga che stava cercando. La differenza non è quanto SQL sai: è quanto rispetti il sistema e i dati di chi ci lavora.

Se hai un legacy Oracle da cui devi estrarre dati per un'integrazione nuova, e vuoi che l'esplorazione sia fatta senza rischi per la produzione e con una documentazione che resta, puoi vedere come lavoro su [antoniotrento.net]({{ site.main_site }}/biografia/) o scrivermi dalla pagina [contatti]({{ site.main_site }}/contatti/). Legacy integration cauta e professionale, non smanettamento su prod.

## FAQ

### Posso esplorare direttamente il database di produzione?
Preferibilmente no. La strada giusta è una read replica in sola lettura: lì qualsiasi query, anche pesante, non tocca la produzione. Se non c'è, ti fai creare un utente con solo SELECT sugli schemi necessari e imposti la sessione in sola lettura. Mai usare l'utente applicativo con permessi di scrittura "tanto faccio solo query": un utente che può scrivere è un utente con cui puoi sbagliare a scrivere.

### Come faccio a rischiare di "fare damage" con delle SELECT?
Non serve un UPDATE per fare danni. Una SELECT che fa un full scan su una tabella da milioni di righe, lanciata in orario di punta su produzione, può saturare I/O e CPU e rallentare le applicazioni vere fino al disservizio. Per questo si esplora su replica, si limitano le query con ROWNUM, si usa EXPLAIN PLAN prima delle query pesanti e, nel dubbio, si coinvolge il DBA.

### Quali viste del data dictionary uso per capire lo schema?
Le principali: `ALL_TABLES` e `ALL_TAB_COLUMNS` per tabelle e colonne con i tipi; `ALL_COL_COMMENTS` e `ALL_TAB_COMMENTS` per i commenti, spesso l'unica documentazione rimasta; `ALL_CONSTRAINTS` e `ALL_CONS_COLUMNS` per i vincoli e le foreign key, da cui ricostruisci le relazioni; `ALL_IND_COLUMNS` per gli indici. Il prefisso `ALL_` mostra ciò che il tuo utente può vedere; `DBA_` richiede privilegi da amministratore.

### E se non trovo nessuna colonna chiamata IBAN?
Molto probabile su un legacy italiano: prima dell'IBAN si usavano ABI, CAB, CIN e numero conto, e un database vecchio potrebbe avere quei campi separati invece di un IBAN unico. Cerca nel dizionario anche `ABI`, `CAB`, `CIN`, `CONTO`, `RAPP` (rapporto). L'IBAN potrebbe essere ricostruibile da quei campi, oppure essere stato aggiunto dopo in una colonna a parte. Cercare solo "IBAN" ti fa concludere erroneamente che il dato non c'è.

### Perché non usare una GUI comoda invece di sqlplus?
Per riproducibilità e sicurezza. Le query salvate in file versionati le rilanci identiche, le rivedi e le fai validare al DBA; un click in una GUI sparisce e non sai più cosa hai eseguito. Inoltre le GUI hanno menù contestuali dove un click sbagliato può lanciare azioni distruttive o un `SELECT *` implicito su milioni di righe. Da riga di comando esegui solo ciò che scrivi, e lo vedi prima di premere invio.

### Come cerco l'IBAN per pattern senza esporre troppi dati?
Su un campione minuscolo, mai sull'intera tabella. Con `WHERE ROWNUM <= 100` prendi poche righe e verifichi con una regex se i valori assomigliano a un IBAN (`^IT[0-9]{2}[A-Z][0-9]{22}$`). Ti basta per confermare quale colonna contiene il dato e in che formato. Per capire la struttura non ti serve leggere milioni di IBAN veri: dieci righe di campione dicono tutto ciò che serve.

### Posso esportare la tabella clienti per analizzarla con calma?
No, è esattamente ciò da non fare. Una tabella da milioni di clienti con dati bancari è PII pesante: esportarla "per provare" crea un archivio di dati personali fuori dal database, senza base né protezione — un data breach autoinflitto. Campiona (poche righe), lavora su dati mascherati se esistono, e salva la struttura (nomi, tipi, formati), mai i valori reali. La minimizzazione GDPR vale anche in fase di esplorazione.

### Cosa consegno alla fine del lavoro?
La documentazione dello schema, non solo "ho trovato la colonna". Un documento markdown versionato con: dove sta il dato (tabella, colonna, tipo), il formato reale, quanto è sporco (percentuale di NULL, eccezioni, valori esteri), le relazioni ricostruite dalle foreign key, le trappole trovate, e i riferimenti alle query usate. È l'asset durevole che evita di rifare la caccia alla prossima integrazione dallo stesso legacy.

### Quando devo fermarmi e chiamare il DBA?
Quando ti serve un privilegio che non hai, quando una query potrebbe pesare sulla produzione, quando devi toccare prod e non c'è replica, o semplicemente quando hai un dubbio. Non è un fallimento: è professionalità. Il DBA è il custode del sistema, conosce il carico e i vincoli meglio di te, e coinvolgerlo per le operazioni sensibili è la cosa giusta. Sapere quando fermarsi distingue chi può lavorare su un legacy critico da chi è un rischio.

### Come capisco se una query è pesante prima di lanciarla?
Con `EXPLAIN PLAN FOR <query>` seguito da `SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY)`: Oracle ti mostra il piano di esecuzione senza eseguire la query, con il costo stimato e — soprattutto — se farà un `TABLE ACCESS FULL` (full scan) su una tabella grande. Un full scan su milioni di righe è il segnale rosso: o aggiungi un filtro selettivo su una colonna indicizzata, o la sposti su replica e fuori orario, o la fai validare al DBA. Leggere il piano prima di premere invio è l'abitudine che evita gli incidenti in produzione: il costo lo scopri stimandolo, non subendolo.

### Questo metodo vale solo per Oracle?
Il principio è generale per qualsiasi database legacy: esplora in sola lettura (replica o utente SELECT-only), interroga il catalogo di sistema prima dei dati, cerca per nome e per pattern, lavora da script riproducibili, minimizza l'esposizione di PII, documenta ciò che trovi. Cambiano i dettagli (le viste di dizionario si chiamano diversamente in PostgreSQL, SQL Server, MySQL), ma la cautela e il metodo restano identici: rispetta il sistema di produzione e i dati di chi ci lavora.
