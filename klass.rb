require 'active_support/inflector' # adds rails pluralize to String
require "railable.rb"
require "attribute.rb"

class Klass
	include Railable
	attr_accessor :name, :attributes, :error

	def initialize( name = nil)
		@name = name
		@attributes = {} # hash of Attribute objects by name
		@error = nil
	end

	def add_attribute( name, typus)
		a = Attribute.new( name, typus)
		attributes[name] = a
	end

	def to_scaffold( model = nil )
		prefix = "rails generate scaffold " + @name
		@attributes.reduce( prefix) { |s,p| s + " " + p[1].to_scaffold( model) }.strip
	end

	# string containing rails model representation of this klass
	def to_class( model = nil )
		prefix ="class #{@name} < ActiveRecord::Base"
		suffix = "end"
		slist = [ prefix, suffix ]

		# handle belongs_to and has_many
		if model != nil then
			slist = [ prefix ] + 
				belongs_to( model) + 
				has_many( model) + 
				through(model) +
				has_a( model) +
				[ suffix ]
		end

		slist.reduce( "") { |sum,v| sum + "\n" + v }
	end

	def has_a( model)
		l = attributes.find_all { |p| p[1].valid_model_type?(model) }.map { |p| p[1] }
		l.map { |a|
			belongs_to = "\tbelongs_to :#{a.name}, "
			class_name = ":class_name => \"#{a.typus}\", "
			foreign_key = ":foreign_key => \"#{a.name}_id\""

			belongs_to + class_name + foreign_key
		}
	end

	def through( model)
		model.find_through.find_all { |t| (t.from == self) || (t.to == self) }.map { |t|
			(t.from == self) ? t.from_stuff : t.to_stuff
		}.flatten
	end

  # returns array of belongs_to strings
	def belongs_to( model)
		self.find_belongs_to(model).map { |rel| 
				"\tbelongs_to :" + rel.to.name.downcase
			}
  end

	def find_has_many( model)
		# find all belongs_to relations which terminate on this klass
    model.find_belongs_to.find_all { |rel| rel.to == self }
	end

	# returns array of has_many strings"
	def has_many( model) # using rails pluralize extending String
		find_has_many( model).map { |rel| "\thas_many :" + rel.from.name.downcase.pluralize }
	end

	def to_hash
	{ 
		@name => @attributes.map { |n,a| a.to_hash }.reduce({}) { |sum,v| sum.merge( v) }
	}
	end

	# load a class from a hash of the form dumped by self.to_hash
	def from_hash( h)
		@name = h.keys.first
		h[@name].each { |k,v| self.add_attribute( k, v) }
	end

	# finds all belongs_to relationships of this klass, returns a list of Relation objects
	def find_belongs_to( model)
		attributes.find_all { |p| p[1].typus == "references" }.map { |p|
			Relation.new( self, model.classes[p[0].capitalize])
		}
	end

	# find all through (has_many through ...) relationships of this klass
	def find_through( model)
		attributes.find_all { |p| p[1].typus == "through" }.map { |p|
			Through.new( self, model.classes[p[0].capitalize])
		}
	end

	def valid?
		b = self.attributes.all? { |p| p[1].valid_db_type? }
		if b == false then
			@error = self.attributes.find_all { |p| !p[1].valid_db_type? }.first[1].error( self.name)
		end
		b
	end
end # class Klass
