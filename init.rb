require 'active_record'
require File.dirname(__FILE__) + "/lib/assign_by"

ActiveRecord::Base.instance_eval do
  include ActiveRecord::AssignBy
end
