# System Config
The configuration files for my operating system, currently Ubuntu 22.04. Managed using a bare git repository. For explanations on how that works see the [Atlassian Guide](https://www.atlassian.com/git/tutorials/dotfiles) or this [DistroTube video](https://www.youtube.com/watch?v=tBoLDpTWVOM).

Documentation about the configs themselves can be found:

- Either in dedicated files in [`docs/`](./) for central documentation that spans multiple components or plugins.
- Or in a `README.md` next to the code for a self-contained component, the way [`lockscreen`](../.local/share/lockscreen/) does.

## Setting up the Repository
1. Clone into your home directory as a bare repository:
    ```bash
   git clone --bare <repo-url> $HOME/.config/.git
    ```

1. Create `con` alias for the running terminal session:
    ```bash
   alias con="/usr/bin/git --git-dir=$HOME/.config/.git --work-tree=$HOME"
    ```

1. Fix the fetch refspec so remote tracking branches are created correctly, then fetch:
    ```bash
   con config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
   con remote set-head origin --auto
   con fetch
    ```
    (`git clone --bare` maps remote branches to local refs instead of remote tracking refs, so without this `origin/main` won't appear in the log.)

1. Checkout the content of the bare repository to your home directory:
    ```bash
   con checkout
    ```
    If the checkout fails because some files would be overwritten, move them to a backup location and try again.

1. Hide untracked files:
    ```bash
   con config --local status.showUntrackedFiles no
    ```

1. Create `~/.config/git/local.ini` and add your user name and email:
    ```ini
   [user]
       name = <git-user-name>
       email = <git-user-email>
    ```

1. Copy the local profile from the template and fill in the values:
    ```bash
   cp ~/.profiles/.templates/local.sh ~/.profiles/local.sh
    ```

1. Restart terminal

## Installations
### Package Manager
```bash
sudo apt install \
    awesome xterm \
    rofi dunst xdotool xsecurelock \
    arandr lxappearance lxsession lxpolkit \
    fd-find ripgrep tmux xclip jq \
    gimp feh flameshot mpv vlc
```
```bash
sudo snap install yq
```
> [!IMPORTANT]
> If all else fails, awesome defaults to xterm.
> So better make sure it's always there, even if you intend to use a different terminal.

### Manual
- [alacritty](https://github.com/alacritty/alacritty/blob/master/INSTALL.md)
- [neovim](https://github.com/neovim/neovim/blob/master/INSTALL.md) and [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
- [eza](https://github.com/eza-community/eza/blob/main/INSTALL.md)
- [delta](https://dandavison.github.io/delta/installation.html)
- [nvm](https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating) (running the install script should be enough)
- [fzf](https://github.com/junegunn/fzf?tab=readme-ov-file#using-git)
- [vivify](https://github.com/jannis-baum/vivify)
- [ImageMagick](https://imagemagick.org/script/download.php#gsc.tab=0) (make AppImage executable and put in a place that is added to PATH)
- [rustup](https://rustup.rs/), which provides the `cargo` used below and puts it in `~/.cargo/bin`

### Cargo
```bash
cargo install bat xidlehook
bat cache --build
```

## Customization
### GUI
Run `lxappearance` and select desired theme

### Firefox
1. install [Firefox Color Extension](https://addons.mozilla.org/en-US/firefox/addon/firefox-color/)
2. visit link to [custom theme](https://color.firefox.com/?theme=XQAAAAJ_AQAAAAAAAABBKYhm849SCia73laEGccwS-xMDPr1qJSHhuu4s9wMJLlJ9dAdxyHeE6nQeWdDnNzjA3gavA2wvQ_m7_lBdxtETuZvw3ss445xH-D8Zlnwg0tilN8DkBUCna7nTysJS7LuwKod9QJT53ou5ZBZ1kDi3K3mllfzIuqhNf8tVEKttOdqlEsXTBa_Db9C3ZKwkj-yAPH7x8-8UX7vdJgz90ODpINQ3fv_iufTf38dgIRa0hoxgo5E1hSb9bOM8_tWTSdIL8CY0ar9ZBsE)
3. install [Stylus Extension](https://addons.mozilla.org/en-US/firefox/addon/styl-us/) and import custom themes defined in `.config/stylus.json`

