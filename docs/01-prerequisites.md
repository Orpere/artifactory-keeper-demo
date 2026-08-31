# 01 — Prerequisites

<p align="center">
  <img src="../assets/icons/docker.svg" alt="Docker" width="20" height="20"/>
  <img src="../assets/icons/python.svg" alt="Python" width="20" height="20"/>
  <img src="../assets/icons/apachemaven.svg" alt="Maven" width="20" height="20"/>
  <img src="../assets/icons/gnubash.svg" alt="Bash" width="20" height="20"/>
</p>

Install the toolchain you need for both scenarios. Choose your OS below.

| Tool | Needed for | Version |
|---|---|---|
| Docker | Scenario 1 — build & push the image | 20.10+ (Compose not required) |
| Python 3 | Scenario 1 — the demo app itself (only to run it locally) | 3.10+ |
| JDK 21 | Scenario 2 — compile the Java library | 21+ |
| Maven | Scenario 2 — build & deploy the artifact | 3.9+ |
| `jq` (optional) | Pretty-printing JSON responses | any |

---

## 1. Docker

### Arch Linux

```bash
sudo pacman -S --needed docker docker-buildx
sudo systemctl enable --now docker
# add your user to the docker group (re-login afterwards)
sudo usermod -aG docker "$USER"
```

### Ubuntu

```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-buildx
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
```

### macOS

Install [Docker Desktop](https://www.docker.com/products/docker-desktop/),
or via Homebrew:

```bash
brew install --cask docker
# launch Docker Desktop once, then verify:
docker --version
```

**Verify (all OS):**

```bash
docker --version
docker run --rm hello-world
```

---

## 2. Python 3 (Scenario 1 — the demo app)

You only need Python to run `greet-service` **locally**; building the image
does not require Python on your machine.

```bash
# Arch
sudo pacman -S --needed python

# Ubuntu
sudo apt-get install -y python3

# macOS
brew install python
```

Verify:

```bash
python3 --version   # 3.10+
```

---

## 3. JDK 21 + Maven (Scenario 2)

### Arch Linux

```bash
sudo pacman -S --needed jdk-openjdk maven
```

> [!NOTE]
> `jdk-openjdk` is OpenJDK 21+ on current Arch repos (or `jdk21-openjdk`
> for a pinned version). Verify with `java -version`.

### Ubuntu

```bash
sudo apt-get update
sudo apt-get install -y openjdk-21-jdk maven
```

> [!TIP]
> If `openjdk-21-jdk` is unavailable on older releases, install JDK 17
> (`openjdk-17-jdk`) and set `<maven.compiler.release>17</...>` in
> `scenario-2-maven/pom.xml` — the demo library uses no JDK-21-only APIs.

### macOS

```bash
brew install openjdk@21 maven
# Homebrew's OpenJDK is keg-only — link it:
sudo ln -sfn "$(brew --prefix)/opt/openjdk@21/libexec/openjdk.jdk" \
  /Library/Java/JavaVirtualMachines/openjdk-21.jdk
echo 'export PATH="$(brew --prefix)/opt/openjdk@21/bin:$PATH"' >> ~/.zshrc
```

**Verify (all OS):**

```bash
java -version   # openjdk 21.x
mvn -version    # Apache Maven 3.9.x
```

---

## 4. jq (optional, for pretty JSON)

```bash
# Arch
sudo pacman -S --needed jq
# Ubuntu
sudo apt-get install -y jq
# macOS
brew install jq
```

---

## 5. Summary check

```bash
docker --version  && python3 --version && java -version && mvn -version
```

All four should print versions. Then continue with the next step:

**Prev:** [00 — Overview](00-overview.md) · **Next:** [02 — Install the ak CLI](02-install-cli.md)
