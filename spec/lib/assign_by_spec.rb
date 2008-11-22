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
    User.destroy_all
    
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
  
  describe "user assignment" do 
    before :each do 
      @message.user = nil
    end
    
    it "should be initially nil" do 
      @message.user.should be_nil
    end
    
    it "should assign the user by model" do 
      @message.user = @user
      @message.user.should == @user
      @message.user_login.should == @user.login
      @message.should be_valid
    end
    
    it "should assign user by his login" do 
      @message.user_login = @author.login
      @message.user.should == @author
      @message.user_login.should == @author.login
      @message.should be_valid
    end
    
    describe "by wrong string" do 
      before :each do 
        @message.user = @user
        
        @message.user_login = 'nonexisting login'
      end
      
      it "should should nullify the user" do 
        @message.user.should be_nil
      end
      
      it "should return the 'nonexisting login' string as the user login" do 
        @message.user_login.should == 'nonexisting login'
      end
      
      it "should have an error on the 'user_login' field" do 
        @message.should_not be_valid
        @message.errors.on(:user_login).should_not be_nil
      end
    end
  end
  
  describe "editor assignment" do 
    before :each do 
      @message.editor = nil
    end
    
    it "should assign editor by login name" do 
      @message.editor_login = @user.login
      @message.editor.should == @user
    end
    
    it "should assign editor by email name" do 
      @message.editor_email = @editor.email
      @message.editor.should == @editor
    end
    
    it "should handle wrong emails" do
      @message.editor_email = 'wrong email'
      @message.editor.should be_nil
      @message.should_not be_valid
      @message.errors.on(:editor_email).should_not be_nil
    end
  end
end