require "model.rb"
require "attribute.rb"

describe Attribute do
	before( :all) do
		@a = Attribute.new( "name", "string")
	end

	it "has a name and a type" do
	
		@a.name.should == "name" && @a.typus == "string"
	end

	it "contributes to rails scaffolding" do
		@a.to_scaffold.should == "name:string"
	end

	it "can render itself as a little hash" do
		@a.to_hash.should  == {"name"=>"string"}
	end

	it "can validate its db type" do
		@a.valid_db_type?.should == true
	end

	it "can validate its model type" do
		model = Model.new( Model.file_to_s( "modeltype.yml") )
		at = model.classes["Belong"].attributes["from"]
		at.typus.should == "Klass"
		at.valid_model_type?(model).should == true
	end
end
