require "railable.rb"

class Attribute
	include Railable
	attr_accessor :name, :typus # add default value later

	def initialize( name, typus)
		@name, @typus = name, typus
	end

	def self.types
	[
		"string",
		"text",
		"integer",
		"float",
		"decimal",
		"datetime",
		"timestamp",
		"time",
		"date",
		"binary",
		"boolean",
		"references" # hmmm ... is this really necessary?
	]
	end

	def valid?
		Attribute.types.index( @typus) != nil
	end

	def to_scaffold
		@typus == "through" ? "" : ( @name + ":" + @typus )
	end

	def to_hash
		{ @name => @typus }
	end
end # class Attribute