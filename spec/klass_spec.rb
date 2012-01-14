require "klass.rb"
require "attribute.rb"
require "model.rb"

describe Klass do
	before( :all) do
		@c = Klass.new( "Person" )
		@a = Attribute.new( "name", "string")
	end

	it "has a name" do
		@c.name.should == "Person"
	end

	it "can add an attribute" do
		@c.attributes[@a.name] = @a
		@c.attributes.has_key?( @a.name).should == true
		@c.attributes[@a.name].name.should == "name"
		@c.attributes[@a.name].typus.should == "string"
	end

	it "add_attribute method works" do
		@c.add_attribute( "email", "string")
		@c.attributes.has_key?( "email").should == true
		@c.attributes["email"].name.should == "email"
		@c.attributes["email"].typus.should == "string"
	end

	it "can participate in rails scaffolding" do
		expected = "rails generate scaffold Person name:string email:string"
		@c.to_scaffold.should == expected
	end

	it "can generate the prefix and suffix of its rails class representation as a string" do
		@c.to_class.should =~ /class Person < ActiveRecord::Base\nend/
	end

	it "can convert itself into a hash" do
		puts @c.to_hash
	end

	it "can load itself from a hash" do
		h = @c.to_hash
		klass = Klass.new
		klass.from_hash h
		klass.to_hash.should == h
	end

	describe "has_a capabilities" do
		before( :all) do
			@model = Model.new( Model.file_to_s( "modeltype.yml") )
			@belong = @model.classes["Belong"]
		end

		it "can find all the attributes with model types" do
			l = @belong.attributes.find_all { |p| p[1].valid_model_type?(@model) }.map { |p| p[1] }
			l.inspect.should == "[from:Klass, to:Klass]"	
		end

		it "can generate the rails model code for these attributes" do
			l = @belong.attributes.find_all { |p| p[1].valid_model_type?(@model) }.map { |p| p[1] }
			puts l.map { |a|
				belongs_to = "\tbelongs_to :#{a.name}, "
				class_name = ":class_name => \"#{a.typus}\", "
				foreign_key = ":foreign_key => \"#{a.name}_id\""

				belongs_to + class_name + foreign_key
			}.reduce( "") { |sum,e| sum + "\n" + e }
		end

		it "actual invocation of has_a()" do
			puts @belong.has_a(@model)
		end

		it "can generate the class rep of Belong with has_a and everything else" do
			puts @belong.to_class(@model)
		end

		it "can generate the proper scaffolding for Belong, given its has_a relationships" do
			puts @belong.to_scaffold(@model)
		end

		it "can invert the has_a relationship" do
			pending "design and implementation"
		end
	end
end
