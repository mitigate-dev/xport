$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "xport"
require "saxlsx"

User = Struct.new(:id, :name, :email)
User.class_eval do
  def self.human_attribute_name(name)
    name
  end
end

class UserExport < Xport::Export
  include Xport::CSV
  include Xport::Axlsx
  include Xport::RubyXL

  columns do
    column :id, width: 10
    column :name, header: "Full name" do |user|
      user.name.upcase
    end
    column :email do |user|
      cell = Xport::Cell.new
      cell.value = "#{user.id}@example.com"
      cell.color = "AAAAAA"
      cell
    end
  end
end
