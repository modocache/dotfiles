require 'rake'

HOME_DIR = ENV['HOME']

task :default => 'install:all'

namespace :install do

  desc "install all dotfiles into user's home directory"
  task :all => [ 'install:bash', 'install:vim' ]

  desc "install bash dotfiles into user's home directory"
  task :bash do
    bash_dir = File.join(File.dirname(__FILE__), 'bash')

    paths = [
      [File.join(HOME_DIR, '.bash_profile'), File.join(bash_dir, 'bash_profile')],
      [File.join(HOME_DIR, '.bashrc'), File.join(bash_dir, 'bashrc')],
    ]

    paths.each { |p| create_symlink(*p) }
  end

  desc "install vim dotfiles into user's home directory"
  task :vim do
    vim_dir = File.join(File.dirname(__FILE__), 'vim')

    paths = [
      [File.join(HOME_DIR, '.vimrc'), File.join(vim_dir, 'vimrc')],
      [File.join(HOME_DIR, '.vim'), vim_dir, {:is_dir => true}],
    ]

    paths.each { |p| create_symlink(*p) }
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
