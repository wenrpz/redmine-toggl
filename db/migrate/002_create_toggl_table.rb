class CreateTogglTable < ActiveRecord::Migration
  def change
    create_table :toggl_entries do |t|
      t.references :time_entry
      t.string :toggl_id
      t.float :hours
      t.timestamps
    end
  end
end
