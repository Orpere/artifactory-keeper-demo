# 04 — Create Repositories with `ak`

![docker](../assets/icons/docker.svg) ![apachemaven](../assets/icons/apachemaven.svg)

A **repository** is a named container for artifacts of one package format.
This demo uses two repositories:

| Repository | Format | Used by |
|---|---|---|
| `docker-local` | `docker` | Scenario 1 — container images |
| `maven-local` | `maven` | Scenario 2 — Java artifacts |

**Official docs:** <https://artifactkeeper.com/docs/cli/core-commands/>

---

## 1. List existing repositories

```bash
ak repo list
```

Filter by format or type:

```bash
ak repo list --pkg-format docker
ak repo list --pkg-format maven --repo-type local
```

Machine-readable output (great for scripts):

```bash
ak repo list --format json | jq -r '.[].key'
```

---

## 2. Create the Docker repository

```bash
ak repo create docker-local --pkg-format docker --repo-type local
```

- `--pkg-format docker` — OCI/Docker format
- `--repo-type local` — a local (owned) repository, as opposed to
  `remote` (proxy/cache) or `virtual` (aggregation)

Expected output (JSON, abbreviated):

```json
{
  "key": "docker-local",
  "pkg_format": "docker",
  "repo_type": "local",
  "status": "created"
}
```

---

## 3. Create the Maven repository

```bash
ak repo create maven-local --pkg-format maven --repo-type local
```

---

## 4. Inspect & manage

```bash
# Show details of one repository
ak repo show docker-local

# Details of all repos in JSON (or yaml / quiet)
ak repo list --format json
```

If you need to start over (⚠️ deletes artifacts too — use carefully):

```bash
ak repo delete docker-local   # prompts for confirmation
ak repo delete maven-local
```

---

## 5. One-shot bootstrap (this repo)

```bash
./scripts/02-bootstrap.sh
```

The script performs all steps from docs 03 + 04: instance add → login
(browser SSO, or token via `AK_TOKEN`) → create both repositories.

```bash
# Headless variant
AK_TOKEN=<token> ./scripts/02-bootstrap.sh
```

---

## 6. Repository naming conventions

- Use **hyphenated lowercase** keys: `docker-local`, `maven-local`.
- The repo key becomes part of the artifact path:
  - Docker image: `artifact-keeper.devopsexpress.site/**docker-local**/greet-service:1.0.0`
  - Maven URL: `https://artifact-keeper.devopsexpress.site/**maven**/...`
- `-local` suffix signals an owned repository (mirrors Artifactory naming).

---

## Reference: `ak repo` commands

| Command | Purpose |
|---|---|
| `ak repo list [--pkg-format <fmt>] [--repo-type <type>]` | List repositories |
| `ak repo show <key>` | Details for one repository |
| `ak repo create <key> --pkg-format <fmt> --repo-type <type>` | Create |
| `ak repo delete <key>` | Delete (requires confirmation) |

---

✅ Repositories ready. Next, pick a scenario:

- [05 — Scenario 1: Push a Docker image](05-scenario-docker.md)
- [06 — Scenario 2: Deploy a Maven artifact](06-scenario-maven.md)
