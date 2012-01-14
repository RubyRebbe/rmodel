require "railable.rb"

class Attribute
	include Railable
	attr_accessor :name, :typus # add default value later

	def initialize( name, typus)
		@name, @typus = name, typus
	end

	def self.types # rails db types
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
		"references",
		"through"		# not a rails db type, but an rmodel type
	]
	end

	def valid_db_type?
		Attribute.types.index( @typus) != nil
	end

	def valid_model_type?(model)
		model.classes.key?( @typus)
	end

	def to_scaffold( model = nil)
		r = ""
		if model == nil then
			r = ( @typus == "through" ) ? "" : ( @name + ":" + @typus )
		elsif valid_model_type?( model) then
			r = @name + ":" + "references"
		else
			r = ( @typus == "through" ) ? "" : ( @name + ":" + @typus )
		end
		r
	end

	def to_s
 		@name + ":" + @typus
	end

	def to_hash
		{ @name => @typus }
	end

	def error(klassname)
		klassname + " " + self.to_s
	end
end # class Attribute
