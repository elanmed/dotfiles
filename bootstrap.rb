require '~/.dotfiles/helpers'
require 'optparse'
require 'English'

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

`which zsh`
if $CHILD_STATUS
  puts 'zsh already installed'.noop
else
  install_package(options['package_manager'], 'zsh')
  puts 'exiting early, re-run the script'.noop
  exit 0
end

shell = `echo "$SHELL"`
unless shell.include?('zsh')
  puts 'setting the default shell to zsh'.doing

  which_zsh = `which zsh`
  `chsh -s #{which_zsh}`

  puts 'exiting early, restart the shell and re-run the script'.noop
  exit 0
end

puts "this script delete your ~/.zshrc. confirm 'y' for yes, anything else to abort: ".query
answer = gets.chomp

unless answer == 'y'
  puts 'aborting'.error
  exit 0
end

puts 'removing ~/.zshrc'
FileUtils.rm([File.expand_path('~/.zshrc')])

install_package(options['package_manager'], 'stow')
install_package(options['package_manager'], 'shfmt')
install_package(options['package_manager'], 'spellcheck')
install_package(options['package_manager'], 'ranger')
install_package(options['package_manager'], 'tmux')
install_package(options['package_manager'], 'xclip')
install_package(options['package_manager'], 'fzf')
install_package(options['package_manager'], 'source-highlight')
install_package(options['package_manager'], 'highlight')

puts "writing #{server ? 0 : 1} to .is_server"
File.write('./.is_server', server ? 0 : 1)

desktop_only_dirs = %w[fonts nvm tmux base16 wezterm]
Dir.glob('./*').each do |dir|
  if server && desktop_only_dirs.include?(dir)
    puts "SKIPPING: running 'stow #{dir}'".noop
  else
    puts "running 'stow #{dir}'".doing
  end
end

if server
  puts 'SKIPPING: bootstrapping tmux'.noop
else
  puts 'bootstrapping tmux'.doing
  `~/.tmux/plugins/tpm/bin/install_plugins`
end

if server
  puts 'SKIPPING: bootstrapping fonts'.noop
else
  puts 'bootstrapping fonts'.doing

  if linux?
    puts 'fonts already in the correct directory'.noop
    return
  end

  fonts_dir = File.expand_path('~/.dotfiles/fonts/.local/share/fonts/*')
  Dir.glob(fonts_dir).each do |dir|
    FileUtils.cp_r(
      dir,
      File.expand_path('~/.dotfiles/tester')
    )
  end
end

puts 'bootstrapping nvm'.doing
puts 'sourcing nvm'.doing
`source "$HOME/.nvm/nvm.sh"`

if server
  puts 'SKIPPING: installing the latest version of node'.noop
else
  puts 'installing the latest version of node'.doing
  `nvm install`
end

puts 'bootstrapping zsh'.doing
zap_dir = File.expand_path('~/.local/share/zap')
if FileTest.exist?(zap_dir)
  puts 'zap already installed'.noop
else
  puts 'installing zap'.doing
  `zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1 --keep`
end

puts 'symlinking zshrc'.doing
FileUtils.ln_s(
  File.expand_path('~/.dotfiles/zsh/.config/zsh/.zshrc'),
  File.expand_path('~/.zshrc')
)
puts 'symlinking spaceshiprc'.doing
FileUtils.ln_s(
  File.expand_path('~/.dotfiles/zsh/.config/zsh/.spaceshiprc.zsh'),
  File.expand_path('~/.spaceshiprc.zsh')
)
