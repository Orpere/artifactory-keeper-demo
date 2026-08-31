# 02 — Install the `ak` CLI

<p align="center">
  <img src="../assets/icons/gnubash.svg" alt="Bash" width="20" height="20"/>
  <img src="../assets/icons/homebrew.svg" alt="Homebrew" width="20" height="20"/>
  <img src="../assets/icons/rust.svg" alt="Rust" width="20" height="20"/>
  <img src="../assets/icons/snapcraft.svg" alt="Snap" width="20" height="20"/>
</p>

`ak` is the official Artifact Keeper CLI. It manages registry instances,
authentication, repositories, and artifacts — everything in this demo runs
through it.

**Official docs:** [Artifact Keeper — CLI installation](https://artifactkeeper.com/docs/cli/installation/)

## In this document

- [Method A — one-line installer (Linux & macOS)](#method-a--one-line-installer-linux--macos)
- [Method B — Homebrew (macOS, also works on Linux)](#method-b--homebrew-macos-also-works-on-linux)
- [Method C — Cargo (any platform with Rust)](#method-c--cargo-any-platform-with-rust)
- [Method D — Snap (Ubuntu)](#method-d--snap-ubuntu)
- [Method E — prebuilt binaries (manual, any OS)](#method-e--prebuilt-binaries-manual-any-os)
- [Method F — Docker (no local install at all)](#method-f--docker-no-local-install-at-all)
- [Verify the installation](#verify-the-installation)
- [Optional: shell completions & man pages](#optional-shell-completions--man-pages)
- [Scripted install (this repo)](#scripted-install-this-repo)

---

## Method A — one-line installer (Linux & macOS)

Works on Arch, Ubuntu, macOS, and any other Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/artifact-keeper/artifact-keeper-cli/main/install.sh | sh
```

The script detects your OS/architecture and installs `ak` to
`/usr/local/bin`.

> [!TIP]
> **Custom location** (no root needed):
>
> ```bash
> curl -fsSL https://raw.githubusercontent.com/artifact-keeper/artifact-keeper-cli/main/install.sh | sh -s -- --install-dir ~/.local/bin
> export PATH="$HOME/.local/bin:$PATH"   # add to ~/.bashrc / ~/.zshrc
> ```

---

## Method B — Homebrew (macOS, also works on Linux)

```bash
brew install artifact-keeper/tap/ak
```

Updates afterwards: `brew upgrade ak`

---

## Method C — Cargo (any platform with Rust)

Requires **Rust 1.86+** (builds from source, takes a few minutes):

```bash
cargo install artifact-keeper-cli
```

---

## Method D — Snap (Ubuntu)

```bash
sudo snap install ak --classic
```

> [!NOTE]
> `--classic` is required because the CLI writes config files, keychains,
> and package-manager configs outside the snap sandbox.

---

## Method E — prebuilt binaries (manual, any OS)

Download from the project's GitHub Releases page:
[artifact-keeper-cli releases](https://github.com/artifact-keeper/artifact-keeper-cli/releases)

| Binary | Platform |
|---|---|
| `ak-linux-amd64` | Linux x86_64 |
| `ak-linux-arm64` | Linux ARM64 |
| `ak-darwin-amd64` | macOS Intel |
| `ak-darwin-arm64` | macOS Apple Silicon |
| `ak-windows-amd64.exe` | Windows x86_64 |

Example (Linux amd64):

```bash
curl -fsSLo ak https://github.com/artifact-keeper/artifact-keeper-cli/releases/latest/download/ak-linux-amd64
chmod +x ak
sudo mv ak /usr/local/bin/ak
```

---

## Method F — Docker (no local install at all)

```bash
docker run --rm ghcr.io/artifact-keeper/ak:latest --help
```

Interactive use with your config mounted:

```bash
docker run --rm -it \
  -v ~/.config/artifact-keeper:/root/.config/artifact-keeper \
  ghcr.io/artifact-keeper/ak:latest repo list
```

---

## Verify the installation

```bash
ak --version
```

Expected output:

```
ak 1.0.0
```

## Optional: shell completions & man pages

```bash
# Bash
ak completion bash > ~/.bash_completion.d/ak && source ~/.bash_completion.d/ak

# Zsh
ak completion zsh > ~/.zfunc/_ak && source ~/.zfunc/_ak

# Fish
ak completion fish > ~/.config/fish/completions/ak.fish
```

```bash
# Man pages
ak man-pages ./man && sudo cp man/*.1 /usr/local/share/man/man1/
man ak repo
```

## Scripted install (this repo)

```bash
./scripts/01-install-cli.sh          # auto-detect: brew on macOS, curl on Linux
./scripts/01-install-cli.sh --method cargo
```

---

✅ The CLI is installed.

**Prev:** [01 — Prerequisites](01-prerequisites.md) · **Next:** [03 — Connect & authenticate](03-connect-auth.md)
