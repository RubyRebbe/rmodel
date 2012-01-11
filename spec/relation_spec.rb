require "relation.rb"
require "model.rb"

describe Through do
	before( :all) do
		@model = Model.new( Model.file_to_s( "employment.yml"))
	end

	it "publicly inherits the properties from and to, from Relation" do
		through = Through.new( 1, 2)
		through.from.should == 1
		through.to.should == 2
	end

	it "extends module railable - responds to to_scaffold and to_class" do
		through = @model.find_through.first
		through.respond_to?( :to_scaffold ).should == true
		through.respond_to?( :to_class ).should == true
	end

	it "can load the employment model" do
		puts @model.to_yaml
	end

	it "can determine if a klass has one or more 'through' attributes" do
		l = @model.classes["Person"].find_through( @model)
		l.length.should == 1
	end

	it "Company has no through attributes" do
		@model.classes["Company"].find_through( @model).empty?.should == true
	end

	it "Person has a through attribute to Company" do
		through = @model.classes["Person"].find_through( @model).first
		through.from.name.should == "Person"
		through.to.name.should == "Company"
	end

	it "should scaffold Person properly" do
		e = "rails generate scaffold Person name:string"
		@model.classes["Person"].to_scaffold.should == e
	end

	it "should scaffold Company properly" do
		e = "rails generate scaffold Company name:string"
		@model.classes["Company"].to_scaffold.should == e
	end

	# conjecture:  @model.find_through represents the collection of join classes,
	# possibly with duplicates
	it "can find model classes with one or more 'through' attributes" do
		ml = @model.find_through
		ml.length.should == 1
		through = ml.first
		through.from.name.should == "Person"
		through.to.name.should == "Company"
	end

	it "should handle scaffolding appropriately" do
		e = "rails generate scaffold PersonCompany person:references company:references"
		through = @model.find_through.first
		through.to_scaffold.should == e
	end

	describe "The String rep for the rails model classes" do
		before( :all) do
			@through = @model.find_through.first
		end

		it "should generate the class for the join-object PersonCompany" do
			@through.belongs_to( @through.from.name).should == "belongs_to :person"
			@through.belongs_to( @through.to.name).should == "belongs_to :company"
			puts @through.to_class	
		end

		it "should generate the class for Person" do
			puts @model.classes["Person"].to_class( @model)
		end

		it "should generate the class for Company" do
			puts @model.classes["Company"].to_class( @model)
		end
	end # describe "The String rep for the rails model classes"

	describe "video store model using the through attribute" do
		before( :all) do
			@videostore_model = Model.new( Model.file_to_s( "videostore.yml"))
		end

		it "should generate the model scaffolding" do
			@videostore_model.to_scaffold.each { |sc| puts sc }	
		end

		it "should generate the rails model classes" do
			@videostore_model.classes.each { |kname, klass| puts klass.to_class( @videostore_model ) }		
		end

		it "should generate all the join-object names" do

			e = ["PersonStore", "PersonItem", "ItemStore"]
			@videostore_model.find_through.map { |t| t.name }.should == e
		end

		it "should generate the join-object scaffolding" do
			@videostore_model.find_through.map { |t| t.to_scaffold }.each { |s| puts s }	
		end

		it "should generate the join-object model classes" do
			@videostore_model.find_through.map { |t| t.to_class }.each { |s| puts s }	
		end
	end # describe "video store model"
end
