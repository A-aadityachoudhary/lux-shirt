class AddFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string
    add_column :users, :email_address, :string
    add_column :users, :password_digest, :string
    add_column :users, :role, :string, default: "user"

    add_index :users, :email_address, unique: true
  end
end