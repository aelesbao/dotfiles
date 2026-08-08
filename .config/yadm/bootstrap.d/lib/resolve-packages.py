#!/usr/bin/env python3
"""Resolve packages.yml into a flat install plan for a given Linux OS family.

Each entry in the package list is projected onto exactly one backend:

    OS family key (archlinux / debian)  ->  repo, or aur when it is `{aur: ...}`
    flatpak                             ->  flatpak
    snap                                ->  snap
    (nothing)                           ->  repo, using `name`

The OS family key always wins, then flatpak beats snap. This mirrors the
JMESPath queries that the retired Ansible playbook used.
"""

import argparse
import sys

try:
    import yaml
except ImportError:  # pragma: no cover - guarded by the bootstrap script
    sys.exit("error: PyYAML is required (install python-yaml or python3-yaml)")

BACKENDS = ("repo", "aur", "flatpak", "snap")
DEFAULT_KEYRING = "/usr/share/keyrings/{name}-archive-keyring.gpg"


def resolve(entry, os_family):
    """Return the (backend, package) pair a single entry projects onto."""
    override = entry.get(os_family)
    if override is not None:
        if isinstance(override, dict):
            if "aur" in override:
                return "aur", override["aur"]
            return "repo", override.get("name", entry["name"])
        return "repo", override
    if entry.get("flatpak"):
        return "flatpak", entry["flatpak"]
    if entry.get("snap"):
        return "snap", entry["snap"]
    return "repo", entry["name"]


def selected(entry, tags, skip_tags):
    """Apply the opt-in --tags / --skip-tags filters to a single entry."""
    entry_tags = set(entry.get("tags") or [])
    if skip_tags and entry_tags & skip_tags:
        return False
    if tags and not entry_tags & tags:
        return False
    return True


def keyring_path(repo):
    """Pull the keyring destination out of the apt `signed-by=` option."""
    for option in repo.get("url", "").partition("[")[2].partition("]")[0].split():
        key, _, value = option.partition("=")
        if key == "signed-by":
            return value
    return DEFAULT_KEYRING.format(name=repo["name"])


def print_packages(data, args):
    seen = set()
    for entry in data.get("packages") or []:
        if not selected(entry, args.tags, args.skip_tags):
            continue
        backend, package = resolve(entry, args.os_family)
        if args.backend and backend != args.backend:
            continue
        if (backend, package) in seen:
            continue
        seen.add((backend, package))
        print(package if args.backend else f"{backend}\t{package}")


def print_repositories(data, args):
    repositories = (data.get("repositories") or {}).get(args.os_family) or []
    for repo in repositories:
        fields = (
            repo["name"],
            repo.get("url", ""),
            repo.get("key", ""),
            repo.get("policy", ""),
            keyring_path(repo),
        )
        print("\t".join(fields))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("file", help="path to packages.yml")
    parser.add_argument(
        "--os-family",
        required=True,
        choices=("archlinux", "debian"),
        help="OS family whose overrides should be applied",
    )
    parser.add_argument(
        "--backend",
        choices=BACKENDS,
        help="print only this backend's packages, one per line",
    )
    parser.add_argument(
        "--repositories",
        action="store_true",
        help="print the extra repositories for the OS family instead",
    )
    parser.add_argument(
        "--tags",
        default="",
        help="comma-separated tags; keep only entries carrying one of them",
    )
    parser.add_argument(
        "--skip-tags",
        default="",
        help="comma-separated tags; drop entries carrying one of them",
    )
    args = parser.parse_args()
    args.tags = {tag for tag in args.tags.split(",") if tag}
    args.skip_tags = {tag for tag in args.skip_tags.split(",") if tag}

    with open(args.file) as handle:
        data = yaml.safe_load(handle) or {}

    if args.repositories:
        print_repositories(data, args)
    else:
        print_packages(data, args)


if __name__ == "__main__":
    main()
