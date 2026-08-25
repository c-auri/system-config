#!/bin/sh

# PATH and env variables belong here, keep sh-compatible and idempotent.
# See ~/docs/shell-startup.md for context.

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export LOGOUT_CMD="awesome-client 'awesome.quit()'"

# Prepend only what is missing.
prepend_path()
{
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$1:$PATH" ;;
    esac
}

[ -d "$HOME/.cargo/bin" ] && prepend_path "$HOME/.cargo/bin"
[ -d "$HOME/bin" ] && prepend_path "$HOME/bin"
[ -d "$HOME/.local/bin" ] && prepend_path "$HOME/.local/bin"
[ -d "$HOME/.local/bin/git-utils" ] && prepend_path "$HOME/.local/bin/git-utils"

unset -f prepend_path

# Drop-ins for machine-specific, secret, and context-specific config.
# Each context manages its own file, see .templates for the expected shape.
# local.sh goes first, because other drop-ins read values it sets. The glob
# cannot express that: collation ignores leading punctuation and case, so no
# filename prefix reliably sorts first.
local_profile="$HOME/.profiles/local.sh"
[ -f "$local_profile" ] && . "$local_profile"

for profile in "$HOME"/.profiles/*.sh
do
    [ "$profile" = "$local_profile" ] && continue
    [ -f "$profile" ] && . "$profile"
done
unset profile local_profile

