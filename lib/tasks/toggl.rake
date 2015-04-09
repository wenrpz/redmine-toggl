require_relative "../../vendor/togglv8-master/togglV8"
require 'awesome_print'
require 'time'

namespace :toggl do
  desc "TODO"
  task :sync => :environment do
    User.all.each do |current_user|
   	  #recorrer  custom fields para obtener el token
      cf = current_user.custom_field_values
      unless cf[0].nil?
        next if cf[0].value.nil?
        #sustituir el token dinamicamente
        token = cf[0].value
       	#validar si tiene token , de no tener continue
        toggl = Toggl.new token
        time_entries = toggl.get_time_entries DateTime.now.beginning_of_day
        time_entries.each do |t|
          date = Time.new t.at
          match = t.description.match /#([0-9]*)/
          if match
            issue = Issue.find(match[1].to_i)
            #borrar y crear nuevos time_entries
            issue.time_entries.delete_all
            #pasar parametros, incluyendo time_entries
            te = issue.time_entries.new
            te.project_id = issue.project_id
            te.user_id = current_user.id
            te.hours = t.duration / 60 / 60
            te.comments = t.description
            te.tyear = date.year
            te.tmonth = date.month
            te.tweek = date.strftime('%W')
            te.spent_on = date
            te.activity_id = TimeEntryActivity.last.id
            te.save
            ap te
          end
        end
      end
    end
  end
end