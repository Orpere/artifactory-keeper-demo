# 03 — Connect & Authenticate (Keycloak SSO + API tokens)

<p align="center">
  <img src="../assets/icons/keycloak.svg" alt="Keycloak" width="20" height="20"/>
</p>

The registry `https://artifact-keeper.devopsexpress.site` is protected by
**Keycloak SSO** (OIDC). This page shows the two ways to authenticate with
the `ak` CLI:

- **Browser SSO** — interactive, for humans (recommended)
- **API token** — headless, for scripts and CI

**Official docs:** <https://artifactkeeper.com/docs/cli/quickstart/>

---

## 1. Add the registry as an instance

An *instance* is a named, saved reference to a registry server. Everything
the CLI does targets an instance.

```bash
ak instance add demo https://artifact-keeper.devopsexpress.site
```

Make it the default:

```bash
ak instance use demo
```

Verify:

```bash
ak instance list
```

```
NAME    URL                                      DEFAULT
demo    https://artifact-keeper.devopsexpress.site  *
```

Check connectivity and server version:

```bash
ak instance info demo
```

> [!TIP]
> **Multiple instances** (e.g., prod + staging): add both, switch with
> `ak instance use <name>`, or override per command with
> `ak repo list --instance prod`.

---

## 2. Browser SSO login (Keycloak)

```bash
ak auth login
```

What happens:

1. The CLI opens your default browser.
2. You land on Keycloak at `keycloak.devopsexpress.site` (realm is
   discovered automatically from the registry's OIDC configuration).
3. You sign in (and/or complete MFA, if configured).
4. Keycloak redirects back; the CLI stores the session/refresh token in
   your OS keychain (macOS Keychain / Linux Secret Service).

Verify who you are:

```bash
ak auth whoami
```

Expected shape:

```
User:      alice
Instance:  demo (https://artifact-keeper.devopsexpress.site)
Permissions: admin, deploy, read
```

---

## 3. Create an API token (for scripts & CI)

After the browser login, issue a scoped token once:

```bash
ak auth token create ci-demo
```

The token is printed once — copy it somewhere safe (e.g., your password
manager). List / revoke tokens:

```bash
ak auth token list
ak auth token revoke ci-demo
```

> [!TIP]
> **Headless alternative without browser**: if you already have a token
> (created in the web UI under *Profile → API tokens*), log in with:
>
> ```bash
> ak auth login --token
> ```
>
> …and paste the token at the prompt.

---

## 4. Use the token in scripts (non-interactive mode)

Export these variables in your shell (or in `.env`, see
[`.env.example`](../.env.example)):

```bash
export AK_INSTANCE=demo
export AK_TOKEN=<your-api-token>
export AK_NO_INPUT=1      # never prompt — fail instead
export AK_FORMAT=json     # table | json | yaml | quiet
```

Now every `ak` command works headless:

```bash
ak repo list
ak artifact search greet
```

The demo scripts in `scripts/` honour these variables automatically.

> [!WARNING]
> **Security notes**
> - Never commit `AK_TOKEN` — the repo's `.gitignore` excludes `.env`.
> - Prefer short-lived tokens for CI; revoke them when unused
>   (`ak auth token revoke ci-demo`).

---

## 5. Reference: auth commands

| Command | Purpose |
|---|---|
| `ak auth login` | Browser-based SSO (Keycloak) |
| `ak auth login --token` | Paste a token (headless) |
| `ak auth logout` | Clear stored credentials |
| `ak auth whoami` | Show current user + permissions |
| `ak auth switch <user>` | Switch accounts on the same instance |
| `ak auth token create <name>` | Create an API token |
| `ak auth token list` | List API tokens |
| `ak auth token revoke <name>` | Revoke an API token |

## 6. Global options

| Flag | Env var | Meaning |
|---|---|---|
| `--format <fmt>` | `AK_FORMAT` | `table` (default TTY) / `json` (default pipe) / `yaml` / `quiet` |
| `--instance <name>` | `AK_INSTANCE` | Target instance (overrides default) |
| `--no-input` | `AK_NO_INPUT` | Disable interactive prompts |
| `--color <mode>` | `AK_COLOR` | `auto` / `always` / `never` |

---

✅ Authenticated.

**Prev:** [02 — Install the ak CLI](02-install-cli.md) · **Next:** [04 — Create repositories](04-repositories.md)
