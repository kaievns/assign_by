require 'rubygems'
require 'test/unit' # <- rspec want it here
require 'spec'
require 'active_record'

dir = File.dirname(__FILE__)

unless defined? AssignBy
  require "#{dir}/../init.rb"
end

RAILS_ROOT = '' unless defined? RAILS_ROOT

# configuration of the test database environoment
$db_file = "#{dir}/db/test.sqlite3"
FileUtils.rm_rf($db_file)
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => $db_file)


# run mibrations
require "#{dir}/db/migrate/create_users.rb"
require "#{dir}/db/migrate/create_messages.rb"
require "#{dir}/db/migrate/create_articles.rb"

ActiveRecord::Migration.verbose = false

CreateUsersTable.migrate(:up)
CreateMessagesTable.migrate(:up)
CreateArticlesTable.migrate(:up)

