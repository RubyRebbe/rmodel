rmodel is a tool whose input is an object model represented as a yaml file.
The output is of two types:

	* rails scaffold commands

	* for each model class, its string representation

rmodel handles the following rails assocations:

	* belongs_to

	* has_many

	* has_many through

Notably, rmodel makes it easy to describe and automatically  generate all of the infrastructure for a join of two model classes.

Here is an example.  Say  the input yaml file is named 'employment.yml' and looks like:

--- 
Person: 
  name: string
  company: through
  
Company: 
  name: string

If you run this rmodel command

	./rmodel.rb -n -f employment.yml

you will see in standard output

rails generate scaffold Person name:string
rails generate scaffold Company name:string
rails generate scaffold PersonCompany person:references company:references

class Person < ActiveRecord::Base
	has_many :person_companies
	has_many :companies, :through => :person_companies
end

class Company < ActiveRecord::Base
	has_many :person_companies
	has_many :people, :through => :person_companies
end

class PersonCompany < ActiveRecord::Base
	belongs_to :person
	belongs_to :company
end

if you run rmodel as below in the root of a rails application directory

	./rmodel.rb -g -f employment.yml

it will actually run the scaffold commands and ensure that the model files are as above in the directory app/models

