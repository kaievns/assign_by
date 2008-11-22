class CreateArticlesTable < ActiveRecord::Migration
  def self.up
    create_table "articles", :force => true do |t|
      t.integer :author_id
      t.integer :editor_id
    end
  end
  
  def self.down
    drop_table "articles"
  end
end
