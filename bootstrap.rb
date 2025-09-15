#!/usr/bin/env ruby

require '~/.dotfiles/helpers'
require '~/.dotfiles/neovim/.config/nvim/bootstrap'
require 'optparse'
require 'English'
require 'fileutils'

options = {}

OptionParser.new do |opts|
  opts.banner = 'Usage: ./scratch.rb [options]'

  opts.on('-s', '--server') do
    options['server'] = true
  end

  opts.on('-pPACKAGE_MANAGER', '--package-manager=PACKAGE_MANAGER', '{brew,pacman,dnf,apt}') do |opt|
    options['package_manager'] = opt
    raise OptionParser::InvalidArgument unless validate_package_manager opt
  end
end.parse!

raise OptionParser::MissingArgument if options['package_manager'].nil?

`which zsh >/dev/null 2>&1`
if $CHILD_STATUS == 0
  puts 'zsh already installed'.noop
else
  install_package(options['package_manager'], 'zsh')
  puts 'exiting early, re-run the script'.noop
  exit 0
end

shell = `echo "$SHELL"`
unless shell.include?('zsh')
  puts 'setting the default shell to zsh'.doing

  which_zsh = `which zsh`.strip
  `chsh -s #{which_zsh}`

  puts 'exiting early, restart the shell and re-run the script'.noop
  exit 0
end

install_package(options['package_manager'], 'stow')
install_package(options['package_manager'], 'shfmt')
install_package(options['package_manager'], 'spellcheck')
install_package(options['package_manager'], 'ranger')
install_package(options['package_manager'], 'tmux')
install_package(options['package_manager'], 'xclip')
install_package(options['package_manager'], 'fzf')
install_package(options['package_manager'], 'source-highlight')
install_package(options['package_manager'], 'highlight')
install_package(options['package_manager'], 'lazygit')

puts "writing #{options['server'] ? 0 : 1} to .is_server"
File.write('./.is_server', options['server'] ? 0 : 1)

desktop_only_dirs = %w[fonts nvm tmux base16 wezterm]
Dir.glob('./*').each do |raw_dir|
  next unless FileTest.directory?(raw_dir)

  dir = File.basename(raw_dir)
  if options['server'] && desktop_only_dirs.include?(dir)
    puts "SKIPPING: running 'stow #{dir}'".noop
  else
    puts "running 'stow #{dir}'".doing
    `stow #{dir}`
  end
end

if options['server']
  puts 'SKIPPING: bootstrapping tmux'.noop
else
  puts 'bootstrapping tmux'.doing
  `~/.tmux/plugins/tpm/bin/install_plugins`
end

if options['server']
  puts 'SKIPPING: bootstrapping fonts'.noop
else
  puts 'bootstrapping fonts'.doing

  if linux?
    puts 'fonts already in the correct directory'.noop
  else
    fonts_dir = File.expand_path('~/.dotfiles/fonts/.local/share/fonts/*')
    Dir.glob(fonts_dir).each do |dir|
      FileUtils.cp_r(
        dir,
        File.expand_path('~/Library/Fonts')
      )
    end
  end
end

puts 'bootstrapping zsh'.doing
puts 'symlinking zshrc'.doing
FileUtils.ln_sf(
  File.expand_path('~/.dotfiles/zsh/.config/zsh/.zshrc'),
  File.expand_path('~/.zshrc')
)
puts 'symlinking spaceshiprc'.doing
FileUtils.ln_sf(
  File.expand_path('~/.dotfiles/zsh/.config/zsh/.spaceshiprc.zsh'),
  File.expand_path('~/.spaceshiprc.zsh')
)
puts 'restart the shell to install zap'.noop

puts 'bootstrapping neovim'.doing

server = options['server'] or false
bootstrap_nvim(server: server, package_manager: options['package_manager'])
