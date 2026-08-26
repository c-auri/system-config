# Shell Startup

The shell config is split across four files in the home directory, plus a directory of drop-ins:
```
~
├── .bash_profile           # Glue: sources .profile, then .bashrc.
├── .bashrc                 # Custom and third-party shell configs.
├── .inputrc                # Editing mode and key bindings read by all readline programs.
├── .profile                # Sets up PATH and env vars and sources drop-ins below.
└── .profiles/
    ├── local.sh            # Machine-specific env vars, aliases, functions (not committed).
    └── .templates/
        └── local.sh        # Expected shape of local.sh, copy out and fill in.
```
Bash picks which of these it reads based on how the shell was started:

| | Login | Non-login |
|---|---|---|
| **Interactive** | profile chain | `.bashrc` |
| **Non-interactive** | profile chain | `$BASH_ENV` (almost never set) |

**Profile chain** means `.bash_profile`, `.bash_login`, `.profile`, in that order. Bash reads only the **first** of these that exists and ignores the rest.

Both interactive cases occur in normal use:

- **Login** applies to every tmux pane, because tmux starts its pane shells as login shells, and to SSH and TTY logins.
- **Non-login** applies to a terminal started directly, for example by picking alacritty from the app launcher, because alacritty spawns bash without making it a login shell. Such a shell reads `.bashrc` only. It still has the full environment, inherited from the graphical session rather than sourced.

Bash never reads `.bashrc` for a login shell, interactive or not. Without further wiring, an SSH login would supply the environment from the profile chain but none of the interactive configuration: no aliases, no prompt, no completions.

## .bash_profile

`.bash_profile` provides that wiring. It sits first in the chain, so it is the file a login shell picks, and it sources `.profile` and `.bashrc` explicitly:
```bash
[ -f "$HOME/.profile" ] && . "$HOME/.profile"
[[ -n "$PS1" && -f "$HOME/.bashrc" ]] && . "$HOME/.bashrc"
```
The `$PS1` guard keeps interactive configuration out of non-interactive login shells while still loading it for interactive ones.

Bash does none of this on its own. Sourcing one startup file from another is a convention each setup implements by hand, and it could be done from `.profile` instead. A separate `.bash_profile` exists because installers such as rustup, nvm, and conda append their `export PATH=...` to `~/.bash_profile`, creating the file if it does not exist. A file created that way would take precedence in the profile chain and shadow `.profile` along with every drop-in. Keeping `.bash_profile` in place means such appends land in a file that already sources the rest.

## .bashrc

`.bashrc` holds everything that only matters in an interactive shell: aliases, functions, the prompt, completions, and third-party integrations such as fzf, nvm, and cargo.

Bash reads it directly only for a non-login interactive shell. Login shells reach it through `.bash_profile`, which is what makes both paths equivalent. 

But Bash also sources it for non-interactive shells started by a remote shell daemon, which covers `ssh host command` and the shells behind `scp` and `rsync`. Those transfers break on any output, so the file returns immediately when `$-` shows the shell is not interactive.

## .profile

Two independent actors source `.profile`:

- **GDM, once per graphical session.** The display manager runs `/etc/gdm3/Xsession`, which sources `/etc/profile` and then `~/.profile` before launching awesome. The graphical session is not started by a shell, so this pass is the only source of environment for awesome and for everything started from it, including rofi, dunst, and terminals opened from the app launcher.
- **Every login shell, once each.** `.bash_profile` sources it explicitly, which covers tmux panes, SSH sessions, and TTY logins.

A tmux pane therefore runs the file twice, once for the session and once for the pane's login shell, and each further nested login shell adds another pass.

Two constraints follow:

- **Keep it sh-compatible.** The GDM pass runs the file from a POSIX shell script rather than from bash.
- **Keep it idempotent.** Any statement that mutates a variable instead of assigning it runs once per pass. An unguarded `PATH="$new:$PATH"` accumulates a duplicate entry per pass, compounding with each nested login shell.

## Drop-ins

`.profile` sources every `*.sh` in `.profiles/` instead of naming the files individually, so a drop-in is added by creating a file and removed by deleting it. This means any context that needs its own file can have one, for example a `secrets.sh` exporting API tokens. `.gitignore` matches `.profiles/*.sh`, which means a new drop-in stays uncommitted without further setup.

Load order matters, because other drop-ins read values that `local.sh` sets, such as `PROJECTS_DIR`. `.profile` therefore sources `local.sh` by name before the loop, and skips it inside.

`local.sh` is never committed, but the repository tracks a template that is meant to be copied over and filled out on a fresh machine. This means the list of variables that are expected to be defined stays under version control even though the values never are.
