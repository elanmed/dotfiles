# dotfiles

A collection of configuration files and custom scripts, centralized in a repo for easy mobility. Uses `stow` to symlink everything properly, based on this blog [post](https://www.jakewiesler.com/blog/managing-dotfiles).

---

Clone with submodules:

```sh
git clone --recurse-submodules https://github.com/ElanMedoff/dotfiles
```

Bootstrap:

- Install [deno](https://docs.deno.com/runtime/manual/getting_started/installation)
- Install [zx](https://google.github.io/zx/v7/getting-started#install)

```sh
deno task root
deno task tmux
deno task neovim
```

Keep submodules up-to-date:

```sh
git submodule foreach git pull origin master
```
