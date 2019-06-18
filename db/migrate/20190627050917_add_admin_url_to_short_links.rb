class AddAdminUrlToShortLinks < ActiveRecord::Migration[5.2]
  def change
    add_column :short_links, :admin_url, :string, null: false
    add_index :short_links, :admin_url, unique: true
  end
end
