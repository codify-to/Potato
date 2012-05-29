#!/usr/bin/env ruby                                                         
require 'fileutils'

puts "Potato project creator"

class ProjectCreator

  TEMPLATE_PATH = File.join(File.dirname(__FILE__), 'template')
  POTATO_PATH = File.join(File.dirname(__FILE__), 'source')

  def initialize(project_path, project_name)
    @project_path = project_path
    @project_name = project_name.downcase

    puts

    if File.exists? project_destination
      puts "Folder already exists, do you really want to coninue? [y/n]".red
      response = STDIN.gets
      return unless response == "y\n"
    end

    puts "creating project named: #{project_name.green} at: #{project_path.green}"

    #Creating project structure
    puts "Project structure...".yellow
    FileUtils.cp_r TEMPLATE_PATH + "/.", project_destination, :verbose => true
    FileUtils.mkdir File.join(project_destination, 'source', 'swc') rescue nil
    FileUtils.mkdir File.join(project_destination, 'source', 'fla') rescue nil

    #Copying libs..
    puts "Project dependencies".yellow
    FileUtils.cp_r File.join(POTATO_PATH, 'libs/.'), File.join(project_destination, 'source', 'libs'), :verbose => true
    FileUtils.cp_r File.join(POTATO_PATH, 'classes/.'), File.join(project_destination, 'source', 'libs'), :verbose => true

    #Renaming package folder
    puts "Setting up project".yellow
    FileUtils.mv File.join(project_destination, 'source/classes/project_name'), File.join(project_destination, 'source/classes', @project_name), :verbose => true
    FileUtils.mv File.join(project_destination, 'source/classes/main.as'), File.join(project_destination, 'source/classes', @project_name+"_main.as"), :verbose => true
    FileUtils.mv File.join(project_destination, 'source/classes/loader.as'), File.join(project_destination, 'source/classes', @project_name+"_loader.as"), :verbose => true
    #list
    puts "Replacing patterns...".yellow
    Dir.glob(File.join project_destination, '**/*').each do |file_name|
      if File.file? file_name
        text = File.read(file_name)
        File.open(file_name, "w") {|file| file.puts text.gsub(/\{project_name\}/, @project_name)} 
      end
    end

    puts "Done!".blue


  end

  #Destination folder
  def project_destination
    @project_path
  end
end

class String
  def red
    "\e[31m" + to_s + "\e[0m"
  end
  def green
    "\e[32m" + to_s + "\e[0m"
  end
  def blue
    "\e[34m" + to_s + "\e[0m"
  end
  def yellow
    "\e[33m" + to_s + "\e[0m"
  end
end

#print help
if ARGV.size == 0 || ARGV[0] == '-h' || ARGV[0] == '--help'
  puts "Usage:\n" +
  "ruby create_project.rb where/to/save project_name".green
  exit
#create the project
elsif ARGV.size == 2
  ProjectCreator.new(File.expand_path(ARGV[0]), ARGV[1]);
else
  puts "unknown option, try --help"
end

