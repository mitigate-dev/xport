require "bundler/setup"
require "xport"
require "axlsx"

User = Struct.new(:id, :name, :email)
User.class_eval do
  def self.human_attribute_name(name)
    name
  end
end

users = [
  User.new(1, "John"),
  User.new(2, "Ben")
]

class UserExport < Xport::Export
  include Xport::Axlsx

  columns do
    column(:id,    group: "User")
    column(:name,  group: "User")
    column(:email, group: "User")
    column(:admin, group: "Roles") { |u| "No" }
    column(:owner, group: "Roles") { |u| "Yes" }
  end
end

File.open("export.xlsx", "wb") do |f|
  f.write UserExport.new(users).to_xlsx.read
end
