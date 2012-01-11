require 'rmodel.rb'

describe RailsModelFactory do
	before( :all) do
		@factory = RailsModelFactory.new
	end

	it "can load an explicit file" do
		@factory.from_file "employment.yml"
		@factory.model.classes.map { |kname,klass| kname }.should == [ "Person", "Company" ]
	end

	it "can generate model scaffolding, including the join classes" do
		@factory.to_scaffold.each { |s| puts s }
	end

	it "can generate rails model class string representations, including the join classes" do
		@factory.to_class.each { |c| puts c }
	end
end # describe RailsModelFactory
