require File.dirname(__FILE__) + "/../spec_helper"

class User < ActiveRecord::Base
end

class Message < ActiveRecord::Base
  belongs_to :user,   :assign_by => :login
  belongs_to :author, :class_name => "User", :assign_by => :login
  belongs_to :editor, :class_name => "User", :assign_by => [:login, :email]
  belongs_to :reader, :class_name => "User"
end

describe ActiveRecord::AssignBy do 
  before :all do 
    @user   = User.create :login => 'user',   :email => 'user@email'
    @author = User.create :login => 'author', :email => 'author@email'
    @editor = User.create :login => 'editor', :email => 'editor@email'
    @reader = User.create :login => 'reader', :email => 'reader@email'
    
    @message = Message.new
  end

  it "should generate the 'user_login' field setter and getter" do 
    @message.should be_respond_to(:user_login)
    @message.should be_respond_to(:user_login=)
  end

  it "should generate an 'author_login' setter and getter" do 
    @message.should be_respond_to(:author_login)
    @message.should be_respond_to(:author_login=)
  end
  
  it "should generate the 'editor_login' field setter and getter" do 
    @message.should be_respond_to(:editor_login)
    @message.should be_respond_to(:editor_login=)
  end
  
  it "should generate the 'editor_email' field setter and getter" do 
    @message.should be_respond_to(:editor_email)
    @message.should be_respond_to(:editor_email=)
  end
  
  it "should not generate getters and setters for the reader relation" do 
    @message.should_not be_respond_to(:reader_login)
    @message.should_not be_respond_to(:reader_login=)
  end
  
  it "should initially return nil for all the virtual fields" do 
    @message.user_login.should be_nil
    @message.author_login.should be_nil
    @message.editor_login.should be_nil
    @message.editor_email.should be_nil
  end
end