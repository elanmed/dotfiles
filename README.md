# dotfiles

A collection of configuration files and custom scripts, centralized for easy mobility. Uses `stow` to symlink everything
properly, based on this blog [post](https://www.jakewiesler.com/blog/managing-dotfiles).

---

#### Clone with submodules:

```sh
git clone https://github.com/ElanMedoff/dotfiles .dotfiles
git submodule init
git submodule update
```

#### Prereqs:

- Install [Alacritty](https://alacritty.org/)
- Install [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads)

#### Bootstrap:

```sh
chmod +x ./bootstrap.sh
./bootstrap.sh --pm={brew,dnf}
```

#### Keep submodules up-to-date:

```sh
git submodule foreach git pull origin master
```

#### Notes when using on a server:

- Update the urls in `.gitmodules` from `git@` to `https://`
- Run the root `bootstrap.sh` with the `--server` flag to avoid unecessarily stowing directories
- Update the `~/.spaceshiprc.zsh` to differentiate the shell prompt
- Update the `vi` alias to `nvim -u ~/.dotfiles/neovim/.config/nvim/barebones.lua "$@"`
- disable `tmux` functionality:
  - Remove the `tmux` call in `~/.dotfiles/zsh/.config/zsh/.zshrc`
  - Replace `~/.dotfiles/scripts/.local/bin/n.sh` with:
  ```bash
  nvim -u ~/.dotfiles/neovim/.config/nvim/barebones.lua "$@"
  ```
