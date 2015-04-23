class CreateCustomFieldToggl < ActiveRecord::Migration
  def self.up
    cf = CustomField.new
    cf.type = 'UserCustomField'
    cf.name = 'Toggl'
    cf.field_format = 'string'
    cf.editable = true
    cf.visible = true
    cf.min_length = 0
    cf.max_length = 0
    cf.save
  end

  def self.down
    unless (cf = CustomField.find_by_name("Toggl")).nil?
      cf.destroy
    end
  end
end
