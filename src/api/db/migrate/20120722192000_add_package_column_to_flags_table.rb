class AddFlagsPackageColumn < ActiveRecord::Migration
  def up
    add_column :flags, :package, :binary, :limit => 256, :null => true
  end

  def down
    remove_column :flags, :package
  end
end
