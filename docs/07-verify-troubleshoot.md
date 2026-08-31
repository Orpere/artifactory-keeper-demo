# 07 — Verification, Scanning & Troubleshooting

![opensearch](../assets/icons/opensearch.svg) ![nginx](../assets/icons/nginx.svg)

Everything you can do after the pushes to prove the registry works — plus
scanning, the TUI, and answers to common problems.

---

## 1. Verify the repositories

```bash
ak repo list
```

Expected:

```
docker-local   local   docker
maven-local    local   maven
```

## 2. Verify the artifacts

```bash
# Docker image
ak artifact list docker-local

# Maven artifact (list + search + info)
ak artifact list maven-local
ak artifact search hello-lib --pkg-format maven
ak artifact info maven-local com/example/hello-lib/1.0.0/hello-lib-1.0.0.jar
```

## 3. Verify via the registry APIs

### Docker — OCI tags endpoint

```bash
curl -s https://artifact-keeper.devopsexpress.site/v2/docker-local/greet-service/tags/list
```

(authenticated — the UI token, or after `docker login`, extract from
`~/.docker/config.json`).

### Maven — direct file fetch

```bash
curl -s -u "$USER:$TOKEN" -o /tmp/hello-lib.jar \
  https://artifact-keeper.devopsexpress.site/maven/releases/com/example/hello-lib/1.0.0/hello-lib-1.0.0.jar
```

### Round-trip pull (Scenario 1)

```bash
./scripts/05-verify.sh --pull
```

## 4. Vulnerability scanning

Artifact Keeper ships **Trivy** scanning at no extra cost. Trigger a scan
with the CLI:

```bash
ak scan run docker-local artifact-keeper.devopsexpress.site/docker-local/greet-service:1.0.0
```

```bash
ak scan run maven-local com/example/hello-lib/1.0.0
```

View scan results:

```bash
ak scan list docker-local
ak scan show docker-local <scan-id>
```

**In the Web UI** (`https://artifact-keeper.devopsexpress.site`):
every artifact shows a health score and CVE details; SBOM generation
(CycloneDX) and Dependency-Track integration are also available.

## 5. The TUI dashboard

```bash
ak tui
```

A full-screen dashboard: repositories, artifacts, scans, audit log —
keyboard-navigable. Run `ak doctor` first if anything feels off:

```bash
ak doctor
```

```
Checking instance 'demo' (https://artifact-keeper.devopsexpress.site)... ok
Server version: 1.5.0
Authentication: valid (user: alice, expires: 2026-12-31)
Checking package managers...
docker 29.7.2:   found
maven 3.9.x:     found
python 3.13:     found
All checks passed.
```

## 6. Search across the registry

```bash
ak artifact search "greet" --format json
ak artifact search "hello-lib" --pkg-format maven
```

## 7. Cleanup (local only)

Remove local images / files — **this never touches the registry**:

```bash
docker rmi artifact-keeper.devopsexpress.site/docker-local/greet-service:1.0.0 greet-service:1.0.0
rm -f /tmp/hello-lib.jar
# optional: remove local build output
rm -rf scenario-2-maven/target
```

To delete artifacts **from the registry** (be careful — deletes are
permanent):

```bash
# Maven: delete by repository path
ak artifact delete maven-local com/example/hello-lib/1.0.0

# Docker: the ak CLI deletes by artifact path — run `ak artifact list docker-local`
# to see the exact path, then:
ak artifact delete docker-local <path-shown-by-list>
```

> Need the exact path? `ak artifact list docker-local` shows the layout
> used by your instance (repo key + image name), so copy the path it prints.

## 8. CLI cheat-sheet (this demo)

```bash
ak instance add demo https://artifact-keeper.devopsexpress.site
ak instance use demo
ak auth login                      # Keycloak SSO (or: ak auth login --token)
ak auth token create ci-demo
ak repo create docker-local --pkg-format docker --repo-type local
ak repo create maven-local --pkg-format maven --repo-type local
ak repo list
docker login artifact-keeper.devopsexpress.site
docker push artifact-keeper.devopsexpress.site/docker-local/greet-service:1.0.0
mvn clean deploy                   # in scenario-2-maven/
ak artifact list docker-local
ak artifact list maven-local
ak scan run docker-local artifact-keeper.devopsexpress.site/docker-local/greet-service:1.0.0
ak tui
```

## 9. FAQ

**Q: Do I need the `ak` CLI for the pushes?**
No — `docker push` and `mvn deploy` speak the native protocols. The CLI is
used for instance management, repository creation, auth (tokens), listing,
scanning, and pull-back — that's the "everything via CLI" story.

**Q: Can I reuse my Keycloak password everywhere?**
Yes, but an **API token** (`ak auth token create`) is safer for
`docker login` and `settings.xml` — revocable and scoped.

**Q: Why is the image path `docker-local/greet-service`?**
The repository key namespaces artifacts: `<host>/<repo-key>/<artifact>:<tag>`.
Without a repo key the artifact would land in the format's default
repository.

**Q: Where do snapshots go?**
`…/maven/snapshots` (see docs/06 § Snapshot vs Release).

**Q: How do I proxy Maven Central through the registry?**
In `settings.xml`, mirror `central` to
`https://artifact-keeper.devopsexpress.site/maven` (pull-through caching).

**Q: How do I report a registry problem?**
`ak doctor` checks connectivity + auth; the Web UI exposes health at
`https://artifact-keeper.devopsexpress.site/health`; audit log shows every
action.

---

## Done!

You have now:

1. ✅ Installed the `ak` CLI on Arch/Ubuntu/macOS
2. ✅ Connected to `artifact-keeper.devopsexpress.site` via Keycloak SSO
3. ✅ Created `docker-local` and `maven-local` repositories with the CLI
4. ✅ Pushed a Docker image (`greet-service:1.0.0`)
5. ✅ Deployed a Maven artifact (`com.example:hello-lib:1.0.0`)
6. ✅ Verified, scanned, and (optionally) pulled everything back

Enjoy your private registry. 🎉
