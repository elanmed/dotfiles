require '~/.dotfiles/helpers'
require 'fileutils'

if is_linux
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
