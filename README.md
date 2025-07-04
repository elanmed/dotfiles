# dotfiles

A collection of configuration files and custom scripts, centralized for easy mobility. Uses `stow` to symlink everything
properly, based on this blog [post](https://www.jakewiesler.com/blog/managing-dotfiles).

---

#### Clone with submodules:

```sh
git clone https://github.com/elanmed/dotfiles .dotfiles
# if necessary, update the urls in `.gitmodules` from `git@` to `https://`
git submodule init
git submodule update
```

#### Bootstrap:

```sh
ruby bootstrap.rb --p={brew,pacman,dnf,apt} {--server}
```

#### Keep submodules up-to-date:

```sh
git submodule foreach git pull origin master
```
