require 'optparse'

class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def error
    colorize(31)
  end

  def query
    colorize(32)
  end

  def doing
    colorize(35)
  end

  def noop
    colorize(34)
  end
end

def has_package(package_manager, package_name)
  validate_package_manager package_manager

  case package_manager
  when 'brew'
    `brew ls --versions #{package_name}`
    $? == 0
  when 'dnf'
    `dnf list installed #{package_name}`
    $? == 0
  end
end

def install_package(package_manager, package_name)
  validate_package_manager package_manager

  if has_package package_manager, package_name
    puts "#{package_name} already installed".noop
    return
  end

  puts "installing #{package_name}...".doing
  case package_manager
  when 'brew'
    `brew ls --versions #{package_name}`
    $? == 0
  when 'dnf'
    `dnf list installed #{package_name}`
    $? == 0
  end
end

def validate_package_manager(package_manager)
  raise 'package_manager must be brew,dnf' if package_manager != 'brew' && package_manager != 'dnf'
end

def get_package_manager_arg
  options = {}
  OptionParser.new do |opt|
    opt.on('-p', '--package_manager Package manager') { |o| options['package_manager'] = o }
  end.parse!

  validate_package_manager options['package_manager']
  options['package_manager']
end

def stream_command(command)
  IO.popen(command).each do |line|
    puts line
  end
end
