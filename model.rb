require "yaml"
require "railable.rb"
require "klass.rb"
require "relation.rb"

class Model
	include Railable
	attr_accessor :classes

	# returns yaml string
	def self.file_to_s( filename)
		f = File.new( filename )
			yaml_object = f.read
		f.close

		yaml_object
	end

	def initialize( yaml_string = "" )
		# hash of Klass'es on class name
		@classes = {}
		if yaml_string != "" then
			self.from_yaml( yaml_string)
		end
	end

	def empty?
		@classes.empty?
	end

	def add_class( klass)
		@classes[klass.name] = klass
	end

	# return array of strings, each string is a rails generate scaffold ... per model class
	def to_scaffold
		@classes.map { |klassname,klass| klass.to_scaffold( self) }
	end

	# returns a hash representation of the model
	def to_hash
		@classes.map { |name,klass| klass.to_hash }.reduce({}) { |sum,v| sum.merge( v) }
	end

	# load model from hash
	def from_hash( h)
		h.each { |name,attributes|
			klass = Klass.new
			klass.from_hash( { name => attributes } )
			self.add_class( klass)
		}

		# this is an experiment in handling "through" attributes
		# i.e. enriching the model with the join classes
	end

	# returns a yaml rep of the model
	def to_yaml
		YAML::dump self.to_hash
	end

	# load model from yaml
	def from_yaml( yaml_string)
		self.from_hash YAML::load( yaml_string)
	end

	# finds all belongs_to relationships, returns a list of Relation objects
	def find_belongs_to
		classes.reduce([]) { |s,p| s + p[1].find_belongs_to(self) }
	end

	# find all through (has_many through) relationships
	def find_through
		#self.classes.to_a.map { |p| p[1] }.reduce([]) { |sum,k| sum + k.find_through( self) }
		classes.reduce([]) { |s,p| s + p[1].find_through(self) }
	end

	def valid?
		classes.all? { |p| p[1].valid? }
	end

	# pre-condition: !valid?
	def error
		classes.find_all { |p| p[1].error != nil }.first[1].error
	end
end # class Model



