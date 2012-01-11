#!/usr/bin/ruby

require "yaml"
require "getopt/std"
require "model.rb"

class RailsModelFactory
	attr_accessor :model

	def initialize()
		@model = nil
	end

	def from_file( filename)
		@model = Model.new( Model.file_to_s( filename))
	end

	# generates a list of all scaffold statements, including join classes
	def to_scaffold
		@model.to_scaffold + @model.find_through.map { |t| t.to_scaffold }
	end

	# generates a list of strings
	# each of which represents a rails model class, including join classes
	def to_class
		@model.classes.map { |kname, klass| klass.to_class( @model ) } +
			@model.find_through.map { |t| t.to_class }
	end

	def help
	[
		"rmodel usage:",
		"no argument:  gets you this help listing",
		"-f : load model file .yml [default is model.yml]",
		"-t : a list of the names of the model objects",
		"-n : shows you what will be generated, both scaffolding and rails model files",
		"-g : creates the rails app via rails scaffold and rails model files"
	]
	end

	def run
		if ARGV.length == 0 then
			help.each { |s| puts s }
		else
			options = "tf:ng"
			opt = Getopt::Std.getopts( options)

			# load the .yml model, one way or t'other
			if opt["f"] then
				self.from_file( opt["f"] )
			else
				self.from_file "model.yml"
			end
			
			if opt["t"] then
				self.model.classes.each { |kname,k| puts kname }		
			end

			if opt["n"] then
				puts "This is what you will see if you generate the models:\n\n"
				self.to_scaffold.each { |s| puts s }
				self.to_class.each { |c| puts c }
			end

			if opt["g"] then # generate the models
				self.to_scaffold.each { |s| system s }
				self.to_class.each { |c|
					classname = c.split[1]
					filename = "app/models/" + classname.tableize.singularize + ".rb"
					file = File.new( filename, "w")
					file.puts( c)
					file.close
				}		
			end
		end
	end # method run
end # class RailsModelFactory

factory = RailsModelFactory.new
factory.run

