require_relative "../../vendor/togglv8-master/togglV8"
require 'awesome_print'
require 'time'

namespace :toggl do
  desc "TODO"
  task :sync => :environment do
    today = DateTime.now.beginning_of_day
    User.all.each do |current_user|
   	  # recorrer custom fields para obtener el token
      cf = current_user.custom_field_values
      unless cf[0].nil?
        next if cf[0].value.nil?
        # sustituir el token dinamicamente
        token = cf[0].value
       	# validar si tiene token , de no tener continue
        toggl = Toggl.new token
        time_entries = toggl.get_time_entries(today)
        time_entries.each do |t|
          date = Time.parse t.at
          match = t.description.match /#([0-9]*)/
          if match
            duration = t.duration.to_f / 60 / 60
            issue = Issue.find(match[1].to_i)
            existing_toggl_entry = TogglEntry.find_by_toggl_id t.id
            if existing_toggl_entry
              existing_hours = existing_toggl_entry.hours.round(2)
              entry_hours = duration.round(2)
              if existing_hours != entry_hours
                existing_toggl_entry.hours = duration
                existing_toggl_entry.save
                existing_time_entry = TimeEntry.find(existing_toggl_entry.time_entry_id)
                existing_time_entry.hours = duration
                existing_time_entry.save
                puts t.id.to_s + ": Changed"
              else
                puts t.id.to_s + ": Not changed"
              end
            else
              te = issue.time_entries.new
              te.project_id = issue.project_id
              te.user_id = current_user.id
              te.hours = duration
              te.comments = t.description
              te.tyear = date.year
              te.tmonth = date.month
              te.tweek = date.strftime('%W')
              te.spent_on = date
              te.activity_id = TimeEntryActivity.last.id
              te.save
              TogglEntry.create(time_entry_id: te.id, toggl_id: t.id, hours: duration)
              puts t.id.to_s + ": New"
            end
          end
        end
      end
    end
  end
end