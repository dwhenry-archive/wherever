Given /^a configured wherever system with keys "([^"]*)"$/ do |keys|
  @interface = Wherever.new(:keys => keys.split(','))
end

When /^I add data to the system for:$/ do |string|
  hash = JSON.parse(string)
  p hash
  @interface.add(hash)
end

Then /^I have have the following data:$/ do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end