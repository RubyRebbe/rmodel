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

	rmodel -n -f employment.yml

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

Note that rmodel acts symmetrically:  if you specify a belongs_to relationship, rmodel will generate it and also its corresponding has_many relationship.

if you run rmodel as below in the root of a rails application directory

	rmodel -g -f employment.yml

it will actually run the scaffold commands and ensure that the model files are as above in the directory app/models

Rmodel extends the set of things that can be types for class attributes from the usual rails (scalar) database types (e.g. string, decimal, ...) to rails model objects.  Take a look at the following yaml specification of an object model:

--- 
Person: 
  name: string

Company: 
  name: string

Employment:
  consulting:  Person
  employment: Company
  compensation:  decimal

which models the notion that a person (a consultant) can work for multiple companies at the same time for different rates of compensation.

For this model, rmodel generates the following scaffolding

rails generate scaffold Person name:string
rails generate scaffold Employment consulting:references employment:references compensation:decimal
rails generate scaffold Company name:string

and the following rails model classes:

class Person < ActiveRecord::Base
	has_many :consultings, :class_name => "Employment", :foreign_key => "consulting_id"
end

class Employment < ActiveRecord::Base
	belongs_to :consulting, :class_name => "Person", :foreign_key => "consulting_id"
	belongs_to :employment, :class_name => "Company", :foreign_key => "employment_id"
end

class Company < ActiveRecord::Base
	has_many :employments, :class_name => "Employment", :foreign_key => "employment_id"
end

Here to, rmodel acts symmetrically to generate both the belongs_to and its corresponding has_many relationship.




