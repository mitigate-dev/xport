# frozen_string_literal: true

module Xport
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('../templates', __FILE__)

      def self.next_migration_number(dirname)
        if ActiveRecord::Base.timestamped_migrations
          Time.new.utc.strftime("%Y%m%d%H%M%S")
        else
          format("%.3d", current_migration_number(dirname) + 1)
        end
      end

      def create_migrations
        migration_template 'migration.rb', 'db/migrate/create_downloads.rb'
      end
    end
  end
end
