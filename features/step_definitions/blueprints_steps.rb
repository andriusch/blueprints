Given /^I have (\w+)$/ do |name|
  build name
end
Then /^(\w+) should (NOT )?be available$/ do |name, negative|
  instance_variable_get("@#{name}").send(negative.present? ? :should : :should_not, be_nil)
end
Then /^(\w+) should be a (\w+)$/ do |name, type|
  instance_variable_get("@#{name}").should be_instance_of(type.classify.constantize)
end
Then /^(\w+) species should be "([^\"]*)"$/ do |name, species|
  instance_variable_get("@#{name}").species.should == species
end
When /^big_cherry size is 10$/ do
  @big_cherry.average_diameter.should == 7
end
Then /^I set big_cherry size to 15$/ do
  @big_cherry.average_diameter = 15
end
