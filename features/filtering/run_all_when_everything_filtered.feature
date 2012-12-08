Feature: run all when everything filtered

  Use the `run_all_when_everything_filtered` configuration option to do just
  that.  This works well when paired with an inclusion filter like ":focus =>
  true", as it will run all the examples when none match the inclusion filter.

  Background:
    Given a file named "spec/spec_helper.rb" with:
      """ruby
      RSpec.configure do |c|
        c.filter_run :focus => true
        c.filter_run_excluding :type => :request
        c.run_all_when_everything_filtered = true
      end
      """

  Scenario: no examples match inclusion filter (runs all examples)
    Given a file named "spec/sample_spec.rb" with:
      """ruby
      require "spec_helper"

      describe "group 1" do
        it "group 1 example 1" do
        end

        it "group 1 example 2" do
        end
      end

      describe "group 2" do
        it "group 2 example 1" do
        end
      end
      """
    When I run `rspec spec/sample_spec.rb --format doc`
    Then the output should contain "All examples were filtered out; ignoring include {:focus=>true}"
    And the examples should all pass
    And the output should contain:
      """
      group 1
        group 1 example 1
        group 1 example 2

      group 2
        group 2 example 1
      """

  Scenario: all examples match exclusion filter (runs all examples)
    Given a file named "spec/sample_spec.rb" with:
      """ruby
      require "spec_helper"

      describe "group 1", :type => :request do
        it "group 1 example 1" do
        end

        it "group 1 example 2" do
        end
      end

      describe "group 2", :type => :request do
        it "group 2 example 1" do
        end
      end
      """
    When I run `rspec spec/sample_spec.rb --format doc`
    Then the output should contain "All examples were filtered out; ignoring include {:focus=>true}"
    Then the output should contain "All examples were filtered out; ignoring exclude {:type=>:request}"
    And the examples should all pass
    And the output should contain:
      """
      group 1
        group 1 example 1
        group 1 example 2

      group 2
        group 2 example 1
      """

  Scenario: no examples match inclusion filter, but some match exclusion filter (runs all examples, but excluded)
    Given a file named "spec/sample_spec.rb" with:
      """ruby
      require "spec_helper"

      describe "group 1" do
        it "group 1 example 1" do
        end

        it "group 1 example 2" do
        end
      end

      describe "group 2", :type => :request do
        it "group 2 example 1" do
        end
      end
      """
    When I run `rspec spec/sample_spec.rb --format doc`
    Then the output should contain "All examples were filtered out; ignoring include {:focus=>true}"
    Then the output should not contain "All examples were filtered out; ignoring exclude {:type=>:request}"
    And the examples should all pass
    And the output should contain:
      """
      group 1
        group 1 example 1
        group 1 example 2
      """
    And the output should not contain:
      """
      group 2
        group 2 example 1
      """
