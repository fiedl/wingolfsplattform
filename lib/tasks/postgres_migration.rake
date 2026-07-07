# Verification tooling for the mysql-to-postgres data migration.
# https://github.com/fiedl/wingolfsplattform/issues/123
namespace :postgres do
  namespace :migration do

    desc "Per-table row counts, max ids and sequence positions — diff against the mysql source"
    task counts: :environment do
      connection = ActiveRecord::Base.connection
      connection.tables.sort.each do |table|
        quoted_table = connection.quote_table_name(table)
        line = "#{table} count=#{connection.select_value("SELECT COUNT(*) FROM #{quoted_table}")}"
        if connection.columns(table).collect(&:name).include? "id"
          max_id = connection.select_value("SELECT COALESCE(MAX(id), 0) FROM #{quoted_table}").to_i
          line += " max_id=#{max_id}"
          if sequence = connection.select_value("SELECT pg_get_serial_sequence('#{table}', 'id')")
            last_value = connection.select_value("SELECT last_value FROM #{sequence}").to_i
            line += " sequence=#{last_value}"
            line += " SEQUENCE_BEHIND" if last_value < max_id
          end
        end
        puts line
      end
    end

    desc "Spot checks on the migrated data — newest record per large table, direct dag links"
    task spot_checks: :environment do
      puts "users: #{User.count}, newest created_at: #{User.order(:created_at).last.try(:created_at)}"
      puts "dag_links: #{DagLink.unscoped.count}, direct: #{DagLink.unscoped.where(direct: true).count}"
      puts "groups: #{Group.count}, corporations: #{Corporation.count}"
      puts "pages: #{Page.count}, events: #{Event.count}, posts: #{Post.count}"
      puts "profile_fields: #{ProfileField.count}, attachments: #{Attachment.count}"
    end

  end
end
