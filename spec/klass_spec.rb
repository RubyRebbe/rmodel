require "klass.rb"
require "attribute.rb"

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
end
