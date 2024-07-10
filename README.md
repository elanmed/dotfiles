# dotfiles

A collection of configuration files and custom scripts, centralized in a repo for easy mobility. Uses `stow` to symlink everything properly, based on this blog [post](https://www.jakewiesler.com/blog/managing-dotfiles).

---

Clone with submodules:

```sh
git clone --recurse-submodules https://github.com/ElanMedoff/dotfiles
```

Bootstrap:

- Install [Alacritty](https://alacritty.org/)
- Install [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads)
- Install [deno](https://docs.deno.com/runtime/manual/getting_started/installation)
- Add deno to the path for the current terminal session:

```sh
export PATH=$PATH:~/.deno/bin/
```

Bootstrap:

```sh
deno task oh-my-zsh
deno task stow
deno task zsh
deno task tmux
deno task neovim
```

Keep submodules up-to-date:

```sh
git submodule foreach git pull origin master
```
