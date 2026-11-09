---
lang: en
permalink: /en/blog/n8n-credentials-vault-infisical/
alt_url: /it/blog/n8n-credentials-vault-infisical/
title: "n8n credentials vs Infisical/Vault: when n8n's credentials database becomes your single point of failure"
date: 2026-11-16 07:30:00 +0200
author: "Antonio Trento"
description: "How n8n encrypts credentials and what happens if you lose N8N_ENCRYPTION_KEY, how to back up the key, when to move to an external vault (Infisical, Vault/OpenBao), how to rotate tokens without stopping flows, a three-environment model, auditing who saw a secret and a key-disaster procedure."
keywords: ["n8n credentials vault infisical", "n8n encryption key", "sme secret management", "automation credentials backup", "infisical docker", "n8n token rotation"]
image: /assets/images/posts/n8n-credentials-vault-infisical.jpg
pillar: stack-sovrano
related: [/en/blog/self-hosted-n8n-openai-privacy/, /en/blog/docker-sme-sovereign-stack/]
---

## The server came back up. The credentials didn't.

One Friday evening the disk of the VPS hosting n8n fills up, the container crashes, someone recreates it with a "clean" `docker compose up` after freeing some space. The Postgres database is intact, mounted on a separate volume. The workflows are all there: you can see them in the editor, with their nodes and connections. But every execution fails with the same error: the credentials can't be decrypted.

The reason is a line nobody had ever looked at. The key n8n uses to encrypt credentials was not set as an environment variable: n8n had generated it by itself on first start and saved it in a file inside the container's data folder. That folder was not on a persistent volume. Recreating the container, the key vanished. With it, the ability to read forty credentials: CRM tokens, SMTP passwords, API keys, ERP access, the PEC mailbox.

The following Monday was spent recreating credentials one by one, asking colleagues, suppliers and consultants for passwords. Some nobody had any more.

This piece is about **n8n credentials and external vaults like Infisical or Vault**: how n8n stores secrets, why the encryption key is the real point of failure, how to back up that key, when it makes sense to move secrets to an external vault, how to rotate tokens without stopping flows, how to separate environments, how to find out who had access to a secret, and what to do the day the key is lost or leaks.

## Is this for you?

It is for you if:

- you run self-hosted n8n in production, with credentials to systems that matter (CRM, ERP, email, banks, public administration);
- you don't know, off the top of your head, where your `N8N_ENCRYPTION_KEY` is;
- the team building workflows is growing, or you have several environments (development, test, production).

It is not for you if you use managed n8n in the cloud: there the provider handles encryption and the key, and your problem is a different one (who has access to the workspace). And it is not for you if you have three personal workflows with no sensitive credentials: the section on backing up the key still applies, the rest doesn't.

## Where credentials live and with which key

In self-hosted n8n, credentials — everything you create in the Credentials section: OAuth tokens, API keys, usernames and passwords — are stored **in n8n's database** (SQLite by default, Postgres in serious installations), in a dedicated table. The field holding the sensitive data is **encrypted** with a symmetric key: the instance's **encryption key**.

The key comes from one of two sources:

1. **the `N8N_ENCRYPTION_KEY` environment variable**, if set;
2. otherwise, **a configuration file in n8n's data folder** (in the container, typically in the `.n8n` folder of the `node` user's home), where n8n writes a random key generated on first start.

The second option is the default, and it's the one that causes damage. If the data folder is on a persistent volume and you back it up, fine, until someone changes the volume. If it isn't persistent, the key lives as long as the container.

Three things to know straight away:

- **Workflows are not encrypted.** The workflow definitions (nodes, connections, parameters) are in clear in the database. Workflows only contain a reference to the credential (ID and name), not the secret.
- **Execution data is not encrypted** with that key. If a node receives a token in an HTTP response and passes it on, that token can end up in clear in the execution history. It's a different problem, but a real one: limit execution-data saving on workflows that handle secrets.
- **All instances sharing a database must have the same key.** In queue mode, main and workers read the same credentials: a different key on one worker produces decryption errors only on executions that land on that worker, the most hateful kind of intermittent failure to diagnose.

## Losing N8N_ENCRYPTION_KEY = losing the flows

The section title is deliberately brutal, and needs qualifying. If you lose the key you don't lose the workflows as definitions: they stay in the database, you can open, export and read them. You lose **all the credentials**: they become encrypted data nobody can read any more. And a workflow without credentials, in an installation that talks to ten external systems, is a drawing.

Recovering means:

- for each credential, finding the original secret (or generating a new one from the source system);
- recreating it in n8n, preferably with the same name, and re-linking it to the workflows that used it;
- for OAuth credentials, repeating the authorisation flow, often with an administrator of the external system;
- checking every workflow, because some links will break.

With 10 credentials it's a bad day. With 80, spread across systems from different suppliers, it's a week of work and a few flows stopped until a supplier answers.

> **Encryption key warning.** `N8N_ENCRYPTION_KEY` is the only thing that allows reading the credentials stored in n8n. There is no recovery mechanism: without the key, credentials are lost. It must be set explicitly before the first production start, kept outside the server in at least two places, never committed to a repository, and identical on every instance (main and workers) using the same database. Whoever has the key and a copy of the database has **all** of the automation's secrets in clear.

The last sentence is the other side of the coin: the key must be protected not only from loss but from leakage. A database backup and a `.env` file in the same folder are a complete package for whoever finds them.

## Backing up the key: procedures

The key is a string. Backing it up is technically trivial and organisationally hard: it must survive the server, people changing, infrastructure moves, and at the same time must not end up where it shouldn't.

### Set it explicitly

First step, before anything else: the key must be **set**, not left to be generated. If the instance is already in production with an auto-generated key, recover it from the configuration file and set it as a variable, so it stops depending on the file.

```bash
# recovering the auto-generated key from an existing instance (running container)
docker compose exec n8n sh -c 'cat /home/node/.n8n/config'
# {"encryptionKey":"..."}  ← this value must be saved as a secret and set explicitly

# generating a new key for a new installation (before the first start!)
openssl rand -base64 48 > ./secrets/n8n_encryption_key
chmod 600 ./secrets/n8n_encryption_key
```

And in the compose file, as a Docker secret rather than as a plain variable in the file. n8n supports the `_FILE` suffix to read the value of many variables from a file: check the exact list in your version's documentation, and after the first start check that a credential actually opens.

```yaml
services:
  n8n:
    image: docker.n8n.io/n8nio/n8n:1.x.y     # pinned version
    environment:
      N8N_ENCRYPTION_KEY_FILE: /run/secrets/n8n_encryption_key
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: postgres
      DB_POSTGRESDB_PASSWORD_FILE: /run/secrets/n8n_db_password
    secrets:
      - n8n_encryption_key
      - n8n_db_password
    volumes:
      - n8n_data:/home/node/.n8n

secrets:
  n8n_encryption_key:
    file: ./secrets/n8n_encryption_key
  n8n_db_password:
    file: ./secrets/n8n_db_password

volumes:
  n8n_data: {}
```

### Where to keep it

The rules I use, adapted to an SME:

- **Two copies outside the server**, in independent places: for example the company password manager (in a vault accessible to two people) and an encrypted copy printed or on offline media in a physical safe.
- **Never in the same place as the database backup.** The nightly Postgres backup goes offsite; the key goes somewhere else, with different access. If an attacker steals the backup bucket, they must not find the key there too.
- **Two custodians.** Two people (for example the owner or a manager and whoever runs the infrastructure) know where it is and can retrieve it. Neither alone must be the human single point of failure.
- **Encrypted at rest** if it lives in a file: a simple file encrypted with a passphrase kept separately.

```bash
# encrypted copy of the key for the offline archive (age: a simple, modern tool)
age -p -o n8n_encryption_key.age ./secrets/n8n_encryption_key
# the passphrase goes in the company password manager, NOT next to the .age file

# periodic (quarterly) check: the archive copy decrypts and matches the one in use
age -d n8n_encryption_key.age | diff - ./secrets/n8n_encryption_key && echo "copy OK"
```

### The test nobody does

An unverified key backup is not a backup. Once a quarter, on an empty machine, you restore the database from the last backup, start n8n with the key retrieved **from the archive** (not the one in use), and run a test workflow that uses a real credential. If it runs, the chain works. If it doesn't, you've found out on a quiet day.

### Exporting credentials: with great caution

n8n has command-line commands to export and import credentials. Export can be done in **encrypted** form (useful as an extra backup, but readable only with the same key) or **decrypted** (all secrets in clear in a JSON file). The latter is a tool for migrations and disaster recovery, not for routine backups: a file with all secrets in clear is the most valuable target in the whole infrastructure. If you need it, do it on a controlled machine, let the file live for minutes, and securely delete it right after the import.

## External vault: when the team grows

With two people building workflows, credentials inside n8n are perfectly fine, as long as key and backup are done well. Things change when:

- **several people create and use credentials**, and it's unclear who has access to what;
- **the same secrets are also needed outside n8n** (scripts, other applications, agents), and live in three copies that drift apart;
- **rotation becomes frequent** or policy-mandated, and updating it by hand in n8n, scripts and `.env` files is a ritual someone skips;
- **there are several environments**, with different secrets for each;
- **an audit is needed** of who read or changed a secret, for a client, an internal audit or an incident.

At that point it pays to move the **source of truth** for secrets into an external vault, and leave n8n as a consumer.

### Self-hosted options

- **Infisical**: an open-source secret manager, installed with Docker, with a web interface understandable even to non-sysadmins, handling projects, environments, secret versions, per-person and per-machine access. For an SME it's often the best compromise between power and simplicity. Some advanced features are in the paid version: check what you need.
- **HashiCorp Vault**: the de facto standard in more structured companies, very powerful (dynamic secrets, PKI, encryption as a service), but more complex to run (unseal, policies, high availability). Since 2023 its licence is no longer open source in the strict sense: those wanting an open licence look at **OpenBao**, the community fork.
- **Your European cloud's secret manager**, if you're already on a provider with an equivalent service: fine if the rest of the stack is there.

### How n8n connects

There are two paths, with important differences.

**1. n8n's "external secrets" feature.** In paid editions, n8n connects natively to various secret managers (including Vault and Infisical) and lets you use vault secrets inside credential fields with an expression of the form `$secrets.<provider>.<name>`. The secret isn't saved in n8n's database: it's read from the vault and held in a cache that refreshes periodically. It's the cleanest solution, but it requires the licence.

**2. Injecting secrets at start-up.** With the community edition, you use the vault to populate environment variables or Docker secret files when the container starts (with the vault's CLI or a sidecar agent), and limit n8n credentials to those that can read environment variables, or keep storing them in n8n but create and update them via API from the vault. It works, but it's more hand-made, and n8n's database goes back to containing the secrets.

For many SMEs the pragmatic choice is in between: **n8n's encryption key** and infrastructure secrets (database password, backup keys) live in the vault and are injected at start-up; **application credentials** stay in n8n, with a record in the vault of which ones exist, who owns them and when they must be rotated. The vault becomes the place where the truth lives, even when n8n keeps an operational copy.

## Rotating API tokens in nodes

Rotating a secret without stopping flows is a sequencing problem, not a technology one. The key rule in n8n: **a credential has an ID, and workflows reference that ID**. If you update the value inside the same credential, every workflow using it picks up the new value on its next execution, with no changes.

### Rotation runbook

For a classic API token (static key):

1. **Inventory**: which workflows use that credential (in the interface, or by querying the database for references to the ID), and whether the same secret is also used outside n8n.
2. **Generate the new token** on the source system, **without revoking the old one**. Almost every system allows two active keys at once; if it doesn't, you need a maintenance window.
3. **Update the existing credential** in n8n (same ID, new value). If you use a vault with external secrets, update the secret in the vault and wait for (or force) the cache refresh.
4. **Run a test workflow** that uses the credential, or the credential's test function.
5. **Watch real executions** for a period suited to the flows' frequency (an hour for frequent ones, a day for daily ones): no 401/403 errors.
6. **Revoke the old token** on the source system.
7. **Watch again**: if something fails now, there was a use of the old token that wasn't in the inventory (a script, another instance, a colleague). Note it.
8. **Record the rotation**: date, who, reason, next due date.

For **OAuth2** credentials rotation is different: the access token renews by itself, but the OAuth application's client secret must be rotated at the provider and updated in the credential; sometimes the change requires re-authorising. Plan it with whoever administers the external system.

For **service passwords** (SMTP, external databases, PEC) the same scheme applies, but there are rarely two active passwords: you need a short window, outside the hours when flows run.

A detail that saves hours: give credentials **meaningful names and a note** (system, environment, owner, expiry or next rotation date). "HTTP Header Auth account 3" says nothing to anyone six months later.

## Environments: dev/staging/prod and mixed credentials

The mistake I see most often in n8n installations that grew fast: **a single instance** where test and production workflows coexist, with production credentials used "to try something quickly". The test workflow that sends an email to every client through the real SMTP is a classic.

### Three-environment model

| | Development | Staging | Production |
|---|---|---|---|
| n8n instance | separate (even local) | separate | separate |
| Encryption key | its own | its own | its own, with backup and custodians |
| Credentials | external systems' sandboxes, test accounts | sandboxes or dedicated copies, never production | production, restricted access |
| Who creates workflows | developers | nobody by hand: they come from development | nobody by hand: they come from staging |
| Data | fake or synthetic | fake or anonymised | real |
| Secrets in the vault | "dev" project/environment | "staging" environment | "prod" environment, named access |

The rules that make the model real:

- **Identical credential names** across the three environments (e.g. `crm-api`), with different values. When a workflow moves from one environment to another, credentials re-link by name.
- **Workflow promotion** via JSON export/import or via Git sync (in editions that support it), **without** credentials: exported files contain references, not secrets.
- **Encryption keys differ** per environment. A copy of the staging database, even if it ends up in the wrong place, opens nothing in production.
- **No production credentials in development**, not even "for a moment". If a case only reproduces with real data, it's done in production with a controlled workflow, or you build a test dataset that reproduces it.

For an SME with a single automation person, three instances may seem too many. The bare minimum is two: one for testing with sandbox credentials, one for production. What matters is that production isn't where you test.

## Audit: who saw the secret

"Who saw the secret?" is the question that comes the day after a suspected leak: a token used from an unknown IP, an odd email sent from the service mailbox. With credentials inside n8n, the honest answer is often "we don't know precisely", for three reasons.

1. **n8n doesn't show credential values after saving**, but anyone who can *use* a credential in a workflow can, in practice, exfiltrate it: an HTTP node sending an authenticated request to an endpoint they control is enough. "Can't see the password" doesn't mean "can't use it for whatever they want".
2. **Credential sharing** between users (in versions that support it) is a permission to use, and it often widens over time without anyone reviewing it.
3. **The database and the key** give access to everything, to whoever has them: server administrators, whoever has access to backups, whoever has access to the machine.

What you can do, in order of cost:

- **Inventory of permissions**: who owns each credential, who it's shared with, reviewed every quarter. n8n's security audit command helps find risky credentials and nodes.
- **Least privilege on the credentials themselves**: a read-only token on the CRM does less damage than an admin one, even if it leaks.
- **n8n events**: creation, modification and deletion of credentials and workflows are loggable events (in editions with log streaming to an external system), and must be kept outside the instance.
- **Vault logs**: if the source of truth is a vault, every read of a secret by a person or a machine is recorded. It's the main reason why, beyond a certain size, a vault is worth its cost.
- **External systems' logs**: often the real answer to "who used the token" lies in the destination system's logs (IP, user agent, times). Knowing where they are before the incident saves hours.

## Key-disaster procedure

Two scenarios, with two different procedures: the key **lost** and the key **exposed**.

### Lost key

1. **Stop before making it worse.** Don't recreate containers, don't overwrite volumes, don't delete anything: if the key was in a file in the data folder, it might still be recoverable from a volume, a disk snapshot, a machine backup.
2. **Search every known place**: offline archive, password manager, data-folder backups, VPS snapshots, old machines a migration came from.
3. **If you find it**: set it explicitly, check a credential, then fix the cause (explicit variable, backup in two places).
4. **If you don't**, accept the loss and rebuild in an orderly way:
   - export the workflows (they aren't encrypted) and list the referenced credentials, by name and type;
   - generate a new key, save it immediately in the two places and with the two custodians;
   - recreate credentials starting from the most critical systems, **generating new secrets** where possible instead of hunting for the old ones;
   - re-link and test the workflows one by one, starting with those that touch clients and money;
   - note how long it took: it's the number that justifies backing up the key.

### Exposed key

If the key has leaked (committed to a repository, ended up in a ticket, present in a stolen backup), you must assume that **anyone who also has a copy of the database has all the secrets**. Changing the key isn't enough: the old secrets are already compromised.

1. **Assess the exposure**: where the key ended up, who may have seen it, whether a database backup is also exposed.
2. **Rotate secrets at the source**, starting with the most critical: tokens with write permissions, banking and PEC access, admin credentials. Use the rotation runbook above, shortening the observation times.
3. **Change n8n's key**: on a controlled machine, export credentials in decrypted form with the old key, start an instance with the new key, import the credentials (they get encrypted with the new one), securely delete the decrypted file. Since you've already rotated the secrets, what you import is the new ones.
4. **Clean up the source of exposure**: remove the key from the repository history (a commit deleting it isn't enough), from tickets, from exposed backups.
5. **Check the external systems' logs** for anomalous access during the exposure period.
6. **Write down what happened** and what changes in the process.

```text
# key-disaster.md — one page, printable, in the same folder as the backup runbooks

KEY LOST
[ ] stop: don't recreate containers / volumes
[ ] search: offline archive (safe), password manager ("infrastructure" vault),
            data-folder backup, VPS snapshot, old server
[ ] found → set N8N_ENCRYPTION_KEY_FILE, test a credential, update the two copies
[ ] not found → export workflows, list credentials, new key (2 copies, 2 custodians),
                recreate credentials from critical systems, test workflows by priority

KEY EXPOSED
[ ] assess: where, who, is the DB exposed too?
[ ] rotate at source: bank/PEC → write tokens → admin → the rest
[ ] change key: decrypted export on a controlled machine → new instance → import → wipe
[ ] clean up: Git history, tickets, exposed backups
[ ] check external systems' logs for the exposure period
[ ] incident report

Custodians: [name 1] [name 2]     Last restore check with archive key: [date]
```

## Reference architecture

For an SME with n8n in production and a growing team, the configuration I recommend:

- **n8n** (main and, if needed, workers) in Docker on an internal server or EU VPS, with Postgres, pinned versions.
- **Encryption key** set explicitly via Docker secret (`N8N_ENCRYPTION_KEY_FILE`), identical on main and workers, never in committed `.env` files.
- **Self-hosted vault** (Infisical, or Vault/OpenBao for those who already have the skills) as the source of truth for: n8n's key, database password, backup keys, and — progressively — application credentials.
- **Three environments** (or at least two) with separate instances, keys and credentials; workflow promotion without secrets.
- **Backups**: encrypted database offsite every night; key in two places separate from the backup, with two custodians; quarterly restore with the archive key.
- **Application credentials** with meaningful names, owner, rotation date; least privilege on external systems.
- **Execution history** limited on workflows that handle secrets or sensitive data.
- **Events and audit**: n8n and vault event logs kept outside their respective instances.

**What must never happen:** the key in the same bucket as the backup, the key in a repository, production credentials in the development instance, a decrypted export left on disk.

## Implementation path, step by step

1. **Find out where your key is today.** Environment variable or file? On a persistent volume? Copied anywhere?
2. **Make it explicit**: recover it, put it in a Docker secret, set `N8N_ENCRYPTION_KEY_FILE`, restart, check a credential.
3. **Make the two copies** outside the server, with two custodians, separate from the database backup.
4. **Do the first restore test** on an empty machine with the archive key.
5. **Inventory credentials**: name, system, owner, permissions, sharing, last rotation. Rename the unreadable ones.
6. **Separate environments**: at least one test instance with sandbox credentials.
7. **Write the rotation runbook** and do the first rotation on a low-criticality credential, to test it.
8. **Evaluate the vault**: if more than two or three people touch credentials, secrets are shared with other systems or audit is needed, install a self-hosted vault and move infrastructure secrets there first.
9. **Write and print** the key-disaster procedure.
10. **Put in the calendar** quarterly restore, quarterly permission review, rotations as due.

## Typical failures and how to spot them in the logs

**Different or missing key.**

```text
n8n  | Error: Credentials could not be decrypted. The likely reason is that a different "encryptionKey" was used to encrypt the data.
```

The message is explicit. If it appears after a restart, the key in use isn't the one the credentials were encrypted with: implicit key and lost file, or a wrong variable. Don't create new credentials until you've worked out which key is the right one.

**Intermittent errors in queue mode.**

```text
worker-2 | Credentials could not be decrypted ...  (execution 18233)
worker-1 | Execution 18234 finished successfully
```

Only some workers fail: they have a different key from main. It happens when workers were added with a different compose file or without the secret.

**Incomplete rotation.**

```text
2026-11-16T09:00:12 workflow="order-sync" node="HTTP Request" 401 Unauthorized
2026-11-16T09:00:12 workflow="daily-report" node="CRM" success
```

After revoking the old token, a single workflow fails: it uses a different credential (duplicated, with another name) holding the same secret. The inventory was incomplete.

**Secrets in executions.** A search of the execution history (or the database) for typical token prefixes finds values in clear: a node returning the token in a response or a workflow logging it. Reduce execution-data saving on that workflow and clean the history.

**The restore test that doesn't start.** It's the most useful failure of all: the archive copy of the key doesn't match the one in use (someone changed it and didn't update the archive). Better to find out this way.

## Costs: orders of magnitude

Indicative estimates.

| Item | Order of magnitude (estimate) | Notes |
|---|---|---|
| Making the key explicit + Docker secrets | 0.5–1 day | The best cost/benefit work in this article |
| Key backup + restore test | 0.5–1 day, then 1–2 hours a quarter | The test is what gets skipped, and it mustn't be |
| Credential inventory and renaming | 0.5–2 days | Depends on how many there are |
| Separate development/staging instance | 1–3 days + €5–20/month | A small VPS or an internal machine |
| Self-hosted vault (Infisical) | 1–3 days of setup + €5–20/month of infrastructure | Plus maintenance: updates, backing up the vault itself |
| Vault/OpenBao with high availability | 5–15 days + dedicated skills | For more structured contexts |
| n8n licence with external secrets | variable | Assess whether it's needed compared with start-up injection |
| Losing the key without a backup | from 1 day to 1–2 weeks of work | Plus flows stopped in the meantime |

A note: a vault also needs backups, unseal or recovery keys, custodians. Moving secrets into a vault doesn't remove the key problem: it **concentrates** it in a system designed to handle it. If you're not ready to run that system well, stay on n8n with the key done right.

## When NOT to do it

- **Don't install a vault** if you're one or two people, with a few dozen credentials used only by n8n. Explicit key, backup in two places, restore test, separate environments: you're already better than average, without one more system to maintain.
- **Don't use decrypted export as a routine backup.** It's a migration tool, not a strategy.
- **Don't build three environments** if nobody will really promote workflows from one to the next: they'll become three drifting instances. Better two, used with discipline.
- **Don't migrate all credentials to the vault in one go**: start with infrastructure secrets and those shared with other systems. Credentials used only in n8n can wait.
- **Don't postpone backing up the key** to do the vault project first: those are weeks in which a wrong `docker compose down -v` costs you everything.

## Operational checklist

- [ ] `N8N_ENCRYPTION_KEY` set explicitly (via `_FILE` and Docker secret), not auto-generated.
- [ ] Same key on main and all workers.
- [ ] Two copies of the key outside the server, separate from the database backup, with two custodians.
- [ ] Encrypted archive copy; passphrase kept elsewhere.
- [ ] Quarterly restore test with the archive key, passed and dated.
- [ ] No key or `.env` with secrets in repositories or tickets.
- [ ] Credential inventory: meaningful name, system, owner, permissions, sharing, next rotation.
- [ ] At least two environments, with separate keys and credentials; no production credentials in development.
- [ ] Rotation runbook written and tested.
- [ ] Execution history limited on workflows with secrets.
- [ ] n8n and vault events kept outside the instance.
- [ ] Key-disaster procedure printed, with custodians and date of last check.

## The verdict

n8n credentials aren't a problem as long as the key that encrypts them is where it should be. When it isn't — because nobody ever set it, because it lived in a file in a container, because the database backup existed but the key didn't — they become the single point of failure of the whole company automation: the workflows remain, but they no longer talk to anything.

The part that removes ninety per cent of the risk costs a day: explicit key, two copies outside the server, two custodians, a restore test every quarter. The external vault — Infisical for most SMEs, Vault or OpenBao for those who already have the skills — comes later, when the team grows, secrets leave n8n and you need to know who read what. At that point it's worth its cost. Before, it's one more system to keep running.

If your n8n has become the company's nervous system and you want to protect it from the wrong Friday evening, you'll find my background in the [biography]({{ site.main_site }}/biografia/) and the rest of my work on [antoniotrento.net]({{ site.main_site }}/). The other pieces on self-hosted infrastructure are collected in the guide to the [sovereign stack]({{ '/en/pillar/sovereign-stack/' | relative_url }}).

## FAQ

### Where does n8n store credentials?

In its own database (SQLite by default, Postgres in production installations), in a dedicated table, with the sensitive data encrypted using the instance's encryption key. Workflow definitions, on the other hand, are not encrypted and contain only a reference to the credential.

### What happens if I lose N8N_ENCRYPTION_KEY?

The stored credentials can no longer be read and there's no way to recover them. The workflows remain in the database, but every credential must be recreated, often generating new secrets on the source systems and repeating OAuth authorisations. That's why the key must be set explicitly and kept outside the server.

### Where is the encryption key if I didn't set it?

If the `N8N_ENCRYPTION_KEY` variable isn't set, n8n generates a key on first start and saves it in a configuration file in the data folder (in the container, under the `.n8n` folder of the user's home). If that folder isn't on a persistent volume, the key is lost when the container is recreated.

### How do you back up n8n's key?

By setting it explicitly as a Docker secret, keeping two copies outside the server in places different from the database backup (for example the company password manager and an encrypted offline archive), entrusting it to two custodians, and checking every quarter a full restore with the archive copy.

### When should you use Infisical or Vault with n8n?

When several people create and use credentials, when the same secrets are also needed outside n8n, when rotation is frequent, when there are several environments or you need an audit of who read a secret. For one or two people with a few credentials used only in n8n, a well-managed key is enough.

### How do you connect n8n to an external vault?

With the external secrets feature of the paid editions, which reads secrets from the vault and makes them available in credential fields without saving them in the database. With the community edition you can inject secrets as environment variables or Docker secrets at start-up, or update n8n credentials via API starting from the vault.

### How do you rotate an API token in n8n without stopping workflows?

You generate the new token without revoking the old one, update the value in the existing credential (same ID, so every workflow uses it), test, watch real executions for a suitable period, then revoke the old token and watch again to discover any uses that weren't in the inventory.

### How do you manage credentials across development, staging and production?

With separate instances, each with its own encryption key and credentials, using the same credential names in all three environments with different values. Workflows are promoted from one environment to the next without secrets, and production credentials are never used in development.

### Can you find out who saw a credential in n8n?

Only partly. n8n doesn't show the value after saving, but whoever can use a credential in a workflow can send it to an external endpoint. You need an inventory of permissions, least-privilege credentials, logging of events on credentials and workflows, and — for a complete audit of reads — a vault as the source of truth.

### What should you do if n8n's encryption key has been exposed?

Assume that whoever also has a copy of the database has all the secrets. Rotate secrets at the source starting from the most critical, change the key by exporting credentials in decrypted form on a controlled machine and re-importing them into an instance with a new key, securely delete the intermediate file, clean up the source of exposure and check the external systems' logs.
