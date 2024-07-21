# dotfiles

A collection of configuration files and custom scripts, centralized for easy mobility. Uses `stow` to symlink everything
properly, based on this blog [post](https://www.jakewiesler.com/blog/managing-dotfiles).

---

Clone with submodules:

```sh
git clone --recurse-submodules https://github.com/ElanMedoff/dotfiles .dotfiles
```

Bootstrap:

- Install [Alacritty](https://alacritty.org/)
- Install [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads)

Bootstrap:

```sh
chmod +x ./bootstrap.sh
./bootstrap.sh
```

Keep submodules up-to-date:

```sh
git submodule foreach git pull origin master
```
