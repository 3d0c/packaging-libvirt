# packaging-libvirt

CI pipeline that builds libvirt RPM packages from [NVIDIA/libvirt](https://github.com/NVIDIA/libvirt) on GitHub Actions, targeting CentOS Stream 9 (x86_64 and aarch64).

## How it works

A pull request against `nvidia_stable-11.9` with a specially formatted title triggers the build:

```
build: <commit-sha>
build: <commit-sha>, qemu: <version>
```

The pipeline:

1. **build-srpm** — Clones NVIDIA/libvirt at the given commit, creates a source tarball, updates the spec file (pins commit, bumps release, optionally pins QEMU version), and builds an SRPM.
2. **build-rpms** — Installs the SRPM and its build dependencies in a CentOS Stream 9 container, then builds binary RPMs. Runs in parallel for x86_64 and aarch64.
3. **finalize** — Collects artifact URLs and commits a summary back to the PR branch.

Progress is tracked via commits pushed to the PR branch (`srpm ready`, `rpms ready`), each containing artifact download links.

## Getting started

### 1. Trigger a build

Create a branch off `nvidia_stable-11.9` and open a PR with a title like:

```
build: a1b2c3d4e5f6
```

The SHA must be a valid commit in [NVIDIA/libvirt](https://github.com/NVIDIA/libvirt).

### 2. Pin a specific QEMU version (optional)

If you need libvirt built against a specific QEMU from the [custom QEMU RPM repo](https://3d0c.github.io/qemu-rpms/), append it to the PR title:

```
build: a1b2c3d4e5f6, qemu: 10.2-1.el9
```

This sets `%global qemu_version 10.2-1.el9` in the spec, so `dnf builddep` resolves `qemu-img = 10.2-1.el9` exactly. When omitted, any available `qemu-img` satisfies the build.

### 3. Collect artifacts

Once the pipeline finishes, download RPMs from the GitHub Actions artifacts tab or from the links in the `rpms ready` commit message on your PR branch.

## Repository structure

```
.github/workflows/build.yml   # CI pipeline
scripts/create-tarball.sh      # Clones upstream, archives source as tar.xz
scripts/update-spec.sh         # Pins commit, optional QEMU version, bumps release
SPECS/libvirt.spec             # RPM spec file
SOURCES/                       # Tarball and patches (generated at build time)
```

## Spec file conventions

- `%global commit` — Tracks the upstream NVIDIA/libvirt commit SHA. Set automatically by CI.
- `# global qemu_version` — Commented out by default. When uncommented by CI, pins `BuildRequires: qemu-img` to an exact version.
- `Release:` — Auto-incremented on each build.
