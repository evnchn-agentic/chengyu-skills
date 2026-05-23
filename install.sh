#!/usr/bin/env bash
# Symlink (or unlink) each skill dir (any dir containing SKILL.md) into ~/.claude/skills/
# Usage:
#   install.sh             # install (symlink */ containing SKILL.md → ~/.claude/skills/)
#   install.sh uninstall   # remove only the symlinks this repo created

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="${HOME}/.claude/skills"
ACTION="${1:-install}"

mkdir -p "${SKILLS_DIR}"

# Discover all skill dirs (any subdir containing SKILL.md) — handles chengyu-*/
# and non-chengyu meta-skills like panda-doctor uniformly.
shopt -s nullglob
skill_dirs=()
for d in "${REPO_DIR}"/*/; do
    [[ -f "${d}SKILL.md" ]] && skill_dirs+=("$d")
done
shopt -u nullglob

if [[ ${#skill_dirs[@]} -eq 0 ]]; then
    echo "no skill dirs (with SKILL.md) found in ${REPO_DIR}" >&2
    exit 1
fi

case "${ACTION}" in
    install)
        for src in "${skill_dirs[@]}"; do
            name="$(basename "${src}")"
            dest="${SKILLS_DIR}/${name}"
            if [[ -e "${dest}" && ! -L "${dest}" ]]; then
                echo "SKIP: ${dest} exists and is not a symlink (refusing to overwrite)" >&2
                continue
            fi
            ln -sfn "${src%/}" "${dest}"
            echo "linked: ${dest} → ${src%/}"
        done
        echo
        echo "done. restart Claude Code or start a new session for the skills to be discovered."
        ;;
    uninstall)
        for src in "${skill_dirs[@]}"; do
            name="$(basename "${src}")"
            dest="${SKILLS_DIR}/${name}"
            if [[ -L "${dest}" ]]; then
                rm "${dest}"
                echo "unlinked: ${dest}"
            elif [[ -e "${dest}" ]]; then
                echo "SKIP: ${dest} is not a symlink (left alone)" >&2
            fi
        done
        ;;
    *)
        echo "usage: $0 [install|uninstall]" >&2
        exit 2
        ;;
esac
