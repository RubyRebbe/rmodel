require "yaml"
require "model.rb"

describe Model do
	before( :all) do
		@model = Model.new

		@c = Klass.new( "Person" )
		@c.add_attribute( "name", "string")
	end

	it "should initially be empty of classes" do
		@model.empty?.should == true
	end

	it "should be able to add a class to the model" do
		@model.add_class( @c)
		klass = @model.classes["Person"]
		klass.should_not == nil
		klass.name.should == "Person"
	end

	it "should be able to scaffold one class" do
		e = "rails generate scaffold Person name:string"
		@model.to_scaffold.each { |r| r.should == e }
	end

	it "should be able to scaffold many classes" do
		company = Klass.new( "Company")
		company.add_attribute( "name", "string")
		company.add_attribute( "description", "text" )

		@model.add_class company
		@model.classes.length.should == 2

		@model.to_scaffold.each { |r| puts r}
	end

	describe "Yaml services" do
		it "should be able to load itself from a hash" do
			yaml_object = Model.file_to_s "post.yml"

			puts "yaml_object:\n#{yaml_object}"
			amodel = Model.new
			amodel.from_hash YAML::load( yaml_object)
			puts "model.to_yaml:\n#{amodel.to_yaml}"
		end

		it "should be able to load itself from a yaml representation of a hash" do
			yaml_object = Model.file_to_s "post.yml"

			puts "yaml_object:\n#{yaml_object}"
			amodel = Model.new
			amodel.from_yaml yaml_object
			puts "model.to_yaml:\n#{amodel.to_yaml}"		
		end

		it "should be able to dump itself to a hash" do
			puts @model.to_hash
		end

		it "should be able to dump itself to yaml" do
			puts @model.to_yaml
		end
	end # describe Yaml services

	describe "belongs_to relationships" do
		before( :all) do
			yaml_object = Model.file_to_s "post.yml"
			@amodel = Model.new
			@amodel.from_yaml yaml_object
		end

		it "here is the yaml for class Comment" do
			puts YAML::dump( @amodel.classes["Comment"].to_hash)
		end

		it  "the list of belongs_to of class Comment should have length 1" do
			comment = @amodel.classes["Comment"]
			l = comment.find_belongs_to @amodel
			l.length.should == 1
		end

		it "the list of belongs_to for the model should have length 1" do
			@amodel.find_belongs_to.length.should == 1
		end

		it "Comment belongs to Post" do
			rel = @amodel.find_belongs_to.first

			rel.from.should == @amodel.classes["Comment"] &&
				rel.to.should == @amodel.classes["Post"]
		end

		it "here are the belongs_to relations in the videostore model" do
			videostore = Model.new Model.file_to_s( "videostore.yml")
			puts "number of model classes:  #{videostore.classes.length}"
			l = videostore.find_belongs_to
			puts "number of belongs_to in model: #{l.length}"
			l.each { |r| puts "#{r.from.name} belongs_to #{r.to.name}" }
		end

		it "can generate the rails class representation for class Comment" do
			comment = @amodel.classes["Comment"]
			puts comment.to_class( @amodel)
		end
	end # describe belongs_to relationships

	describe "has_many relationships" do
		before( :all) do
			@amodel = Model.new( Model.file_to_s( "post.yml") )
		end

		it "can find the has_many relations from Post to ..." do
			post = @amodel.classes["Post"]
			post.name.should == "Post"
			l = post.find_has_many( @amodel)
			l.length.should == 1
			rel = l.first
			rel.from.name.should == "Comment"
		end

		it "can generate the has_many strings for Post" do
			post = @amodel.classes["Post"]
			slist = post.has_many @amodel
			slist.length.should == 1
			slist.first.should == "\thas_many :" + "comments"
		end

		it "can generate the rails class rep for the klass Post with has_many" do
			post = @amodel.classes["Post"]
			puts post.to_class( @amodel)
		end

		it "can generate the rails class reps for the videostore model" do
			videostore = Model.new Model.file_to_s( "videostore.yml")
			videostore.classes.each { |classname,klass|
				puts klass.to_class videostore
			}
		end
	end # describe has_many relationships
end # describe Model
