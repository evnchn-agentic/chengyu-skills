#!/usr/bin/env bash
# Symlink (or unlink) each skill dir (any dir containing SKILL.md) into ~/.claude/skills/
# Usage:
#   install.sh             # install the FULL catalog (symlink */ containing SKILL.md)
#   install.sh core        # install ONLY the core pack (live-usage podium + dependency closure); additive
#   install.sh uninstall   # remove only the symlinks this repo created

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="${HOME}/.claude/skills"
ACTION="${1:-install}"

# Core pack = live-usage podium + the dependency closure that keeps it self-contained.
# create-something-from-nothing is pulled in because listen-all-sides inter-triggers it;
# omitting it would leave a dangling reference. Keep this list in sync with README.md.
CORE_SKILLS=(
    chengyu-throw-brick-attract-jade
    chengyu-review-old-know-new
    chengyu-listen-all-sides-see-clearly
    chengyu-create-something-from-nothing
)

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

in_core() {
    local name="$1"
    for c in "${CORE_SKILLS[@]}"; do [[ "${c}" == "${name}" ]] && return 0; done
    return 1
}

link_one() {
    local src="$1" name dest
    name="$(basename "${src}")"
    dest="${SKILLS_DIR}/${name}"
    if [[ -e "${dest}" && ! -L "${dest}" ]]; then
        echo "SKIP: ${dest} exists and is not a symlink (refusing to overwrite)" >&2
        return
    fi
    ln -sfn "${src%/}" "${dest}"
    echo "linked: ${dest} → ${src%/}"
}

case "${ACTION}" in
    install)
        for src in "${skill_dirs[@]}"; do link_one "${src}"; done
        echo
        echo "done (full catalog). restart Claude Code or start a new session for the skills to be discovered."
        ;;
    core)
        # Fail loud if any declared core skill is missing — an incomplete core pack is broken,
        # not something to install silently. Abort BEFORE linking anything.
        missing=0
        for c in "${CORE_SKILLS[@]}"; do
            [[ -f "${REPO_DIR}/${c}/SKILL.md" ]] || { echo "ERROR: declared core skill '${c}' is missing from the repo" >&2; missing=1; }
        done
        if [[ ${missing} -ne 0 ]]; then
            echo "aborting — core pack is incomplete; nothing was linked." >&2
            exit 1
        fi
        for src in "${skill_dirs[@]}"; do
            in_core "$(basename "${src}")" && link_one "${src}"
        done
        echo
        echo "done (core pack: ${#CORE_SKILLS[@]} skills). restart Claude Code or start a new session."
        echo "this is additive — run '${0} uninstall' first if you want ONLY the core installed."
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
        echo "usage: $0 [install|core|uninstall]" >&2
        exit 2
        ;;
esac
