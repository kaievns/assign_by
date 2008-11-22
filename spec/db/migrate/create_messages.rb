class CreateMessagesTable < ActiveRecord::Migration
  def self.up
    create_table "messages", :force => true do |t|
      t.integer :user_id
      t.integer :author_id
      t.integer :editor_id
      t.integer :reader_id
    end
  end
  
  def self.down
    drop_table "messages"
  end
end
