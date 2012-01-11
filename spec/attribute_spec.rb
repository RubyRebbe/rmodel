require "attribute.rb"

describe Attribute do
	before( :all) do
		@a = Attribute.new( "name", "string")
	end

	it "has a name and a type" do
	
		@a.name.should == "name" && @a.typus == "string"
	end

	it "can validate the type" do
		@a.valid?.should == true
	end

	it "contributes to rails scaffolding" do
		@a.to_scaffold.should == "name:string"
	end

	it "can render itself as a little hash" do
		@a.to_hash.should  == {"name"=>"string"}
	end
end
