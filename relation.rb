require 'active_support/inflector' # adds rails pluralize to String
require "railable.rb" # for class Through

# we will first use this Relation class to represent belongs_to

class Relation # binary relationship
	attr_accessor :from, :to

	# from and to are of type Klass
	def initialize( from = nil, to = nil)
		@from, @to = from, to
	end
end # class relation

class Through < Relation
	include Railable

	def name # ruby rails class name of the join-object
		from.name  + to.name
	end

	def ref( n)
		n.downcase + ":references"
	end

	def to_scaffold
		prefix  = "rails generate scaffold "
		prefix + self.name + " " + ref(from.name) + " " + ref(to.name)
	end

	def belongs_to( n)
		"belongs_to :" + n.downcase
	end

	def to_class
		[
			"class #{self.name} < ActiveRecord::Base",
			"\t" + belongs_to(from.name),
			"\t" + belongs_to(to.name),
			"end"
		].reduce( "") { |sum,v| sum + "\n" + v }
	end

	# for lack of a better name ...
	def join_name
		self.name.tableize
	end

	# Through knows how to generate the from-side model class
	# this is temporary code for developing the ideas and will probably be mined
	def from_to_class
		[
			"class #{from.name} < ActiveRecord::Base",
			"\thas_many :" + join_name,
			"\thas_many :" + to.name.downcase.pluralize + " :through => " + join_name,
			"end"
		].reduce( "") { |sum,v| sum + "\n" + v }
	end

	def from_stuff
		[
			"\thas_many :" + join_name,
			"\thas_many :" + to.name.downcase.pluralize + " :through => " + join_name
		]
	end

	def to_stuff
		[
			"\thas_many :" + join_name,
			"\thas_many :" + from.name.downcase.pluralize + " :through => " + join_name
		]
	end
	
	# Through knows how to generate the to-side model class
	# this is temporary code for developing the ideas and will probably be mined
	def to_to_class
		[
			"class #{to.name} < ActiveRecord::Base",
			"\thas_many :" + join_name,
			"\thas_many :" + from.name.downcase.pluralize + " :through => " + join_name,
			"end"
		].reduce( "") { |sum,v| sum + "\n" + v }
	end
end
