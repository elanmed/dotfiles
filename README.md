# dotfiles

A collection of configuration files and custom scripts, centralized for easy mobility. Uses `stow` to symlink everything
properly, based on this blog [post](https://www.jakewiesler.com/blog/managing-dotfiles).

---

#### Clone with submodules:

```sh
git clone git@github.com:elanmed/dotfiles .dotfiles
# or git clone https://github.com/elanmed/dotfiles .dotfiles
# if necessary, update the urls in `.gitmodules` from `git@` to `https://`
./bootstrap.sh --package-manager {brew,dnf,apt} --desktop-env {mate,gnome,macos,server}
```

```sh
git submodule foreach git pull origin master
```
