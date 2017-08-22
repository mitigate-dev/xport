require "spec_helper"

describe Xport::Export, "with csv" do
  subject(:export) do
    UserExport.new(users)
  end

  let(:users) do
    [
      User.new(1, "John"),
      User.new(2, "Ben")
    ]
  end

  describe "#to_csv" do
    it "returns serialized contents" do
      content = export.to_csv
      expect(content.read).to eq(<<-EOS)
id,Full name,email
1,JOHN,1@example.com
2,BEN,2@example.com
EOS
    end
  end
end
