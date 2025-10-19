require 'rails_helper'

RSpec.describe Client, type: :model do
  it "is valid with name and identification" do
    c = Client.new(name: "ACME", identification: "80012345", email: "a@b.com")
    expect(c).to be_valid
  end

  it "is invalid without name" do
    c = Client.new(identification: "80012345")
    expect(c).not_to be_valid
  end
end
