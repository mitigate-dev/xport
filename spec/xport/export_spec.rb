require "spec_helper"
require "saxlsx"

describe Xport::Export do
  User = Struct.new(:id, :name, :email)
  User.class_eval do
    def self.human_attribute_name(name)
      name
    end
  end

  class UserExport < Xport::Export
    include Xport::Axlsx
    include Xport::CSV

    columns do
      column :id
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

  let(:users) do
    [
      User.new(1, "John"),
      User.new(2, "Ben")
    ]
  end

  describe "#to_xlsx" do
    it "returns serialized contents" do
      content = UserExport.new(users).to_xlsx
      file = Tempfile.new(['export', '.xlsx'], encoding: 'ascii-8bit')
      file.write content.read
      file.rewind
      rows = []
      Saxlsx::Workbook.open(file.path) do |doc|
        rows = doc.sheets[0].rows.to_a
      end
      expect(rows).to eq([
        ["id", "Full name", "email"],
        [1.0, "JOHN", "1@example.com"],
        [2.0, "BEN", "2@example.com"]
      ])
    end
  end

  describe "#to_csv" do
    it "returns serialized contents" do
      content = UserExport.new(users).to_csv
      expect(content.read).to eq(<<-EOS)
id,Full name,email
1,JOHN,1@example.com
2,BEN,2@example.com
EOS
    end
  end
end
