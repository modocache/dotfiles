require 'rake'

HOME_DIR = ENV['HOME']


desc 'run all tasks'
task :all => [ 'configure', 'install' ]

desc "symlink all dotfiles into user's home directory"
task :configure => [ 'configure:bash', 'configure:vim' ]

namespace :configure do

  desc "symlink bash dotfiles into user's home directory"
  task :bash do
    bash_dir = File.join(File.dirname(__FILE__), 'bash')

    paths = [
      [File.join(HOME_DIR, '.bash_profile'), File.join(bash_dir, 'bash_profile')],
      [File.join(HOME_DIR, '.bashrc'), File.join(bash_dir, 'bashrc')],
    ]

    paths.each { |p| create_symlink(*p) }
  end

  desc "symlink vim dotfiles into user's home directory"
  task :vim do
    vim_dir = File.join(File.dirname(__FILE__), 'vim')

    paths = [
      [File.join(HOME_DIR, '.vimrc'), File.join(vim_dir, 'vimrc')],
      [File.join(HOME_DIR, '.vim'), vim_dir, {:is_dir => true}],
    ]

    paths.each { |p| create_symlink(*p) }
  end

end


desc "install everything"
task :install => [
  'install:homebrew',
  'install:python',
  'install:ruby',
  'install:vim',
]

namespace :install do
  desc 'install homebrew'
  task :homebrew do
    system %Q{ /usr/bin/ruby -e "$(/usr/bin/curl -fsSL https://raw.github.com/mxcl/homebrew/master/Library/Contributions/install_homebrew.rb)" }
  end

  
  desc 'install Python'
  task :python => ['install:python:packages']

  namespace :python do
    desc 'install Python prerequisites'
    task :prerequisites => ['install:homebrew'] do
      system('brew install readline sqlite gdbm')
    end

    desc 'install a universal build of latest Python 2.* via homebrew'
    task :install => ['install:python:prerequisites'] do
      system('brew install python --framework --universal')
      path = '/System/Library/Frameworks/Python.framework/Versions/Current'

      puts 'Need to use sudo in order to change symlink to default Python version...'
      system("sudo rm #{path}")
      system("sudo ln -s #{path} /usr/local/Cellar/python/2.7.2/Frameworks/Python.framework/Versions/Current")
      
      # Install pip package manager.
      system('easy_install pip')
    end

    desc 'install useful Python packages'
    task :packages => ['install:python:install'] do
      system('brew install pkg-config')
      system('pip install virtualenv virtualenvwrapper ipython')
      system('. /usr/local/share/python/virtualenvwrapper.sh')

      from = File.join(HOME_DIR, 'ipython', 'profile_default', 'startup')
      to = File.join(File.dirname(__FILE__), 'python', 'ipython_startup')
      create_symlink(from, to, {:is_dir => true})
    end
  end


  desc 'install Ruby'
  task :ruby => ['install:ruby:install']

  namespace :ruby do
    desc 'install RVM'
    task :rvm => ['install:bash'] do
      system('curl -L https://get.rvm.io | bash -s stable')
      system('. ~/bash_profile')
    end

    desc 'install latest stable Ruby (1.9.3) and alias to default'
    task :install => ['install:ruby:rvm'] do
      system('rvm install 1.9.3')
      system('rvm use 1.9.3 --default')
    end
  end

  desc 'build and install Vim with Python and Ruby support'
  task :vim => ['install:homebrew', 'install:ruby:rvm', 'install:python:install'] do
    system('brew install mercurial')
    system('rvm use system')

    system('mkdir ~/Mercurial')
    system('hg clone https://vim.googlecode.com/hg/ ~/Mercurial/vim')

    cmd_prefix = 'cd ~/Mercurial/vim && '
    commands = [
      'hg pull',
      'hg update',
      './configure --prefix=/usr/local --enable-rubyinterp --enable-pythoninterp --with-features=huge',
      'make',
      'make install',
    ]
    commands.each { |c| system("#{cmd_prefix} #{c}")}
  end

end

def create_symlink(from, to, options={})
  if confirm_overwrite(from, options)
    rm_command = options[:is_dir] ? 'rm -rf' : 'rm'

    system("#{rm_command} #{from}")
    system("ln -s #{to} #{from}")
  end
end

def confirm_overwrite(file, options={})
  if File.exists? file
    puts "Found \"#{file}\""
    puts "Would you like to overwrite \"#{file}\":"
    puts 'Yes (y), no (n), backup and overwrite (b), or quit (q)?'

    case $stdin.gets.chomp
    when 'y'
      puts "Overwriting \"#{file}\"."
      return true
    when 'n'
      puts "Skipping \"#{file}\"."
      return false
    when 'b'
      backup_file = "#{file}.dotfiles.backup.#{Time.now.to_i}"
      puts "Backing up \"#{file}\" to \"#{backup_file}\"."

      command = options[:is_dir] ? 'cp -r' : 'cp'
      system("#{command} #{file} #{backup_file}")

      puts "Overwriting \"#{file}\""
      return true
    when 'q'
      puts 'Aborting.'
      exit
    else
      return false
    end

  else
    return true
  end

end
