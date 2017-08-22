require "spec_helper"

describe Xport::Export, "with rubyXL" do
  subject(:export) do
    UserExport.new(users)
  end

  let(:users) do
    [
      User.new(1, "John"),
      User.new(2, "Ben")
    ]
  end

  describe "#to_xlsx" do
    it "returns serialized contents" do
      export = UserExport.new(users)
      formatter = Xport::RubyXL::Formatter.new(export)
      content = export.to_file(formatter)
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
end
