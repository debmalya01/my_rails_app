require 'rails_helper'

RSpec.describe Invoice, type: :model do

  it "is valid with valid attributes" do
    invoice = FactoryBot.build(:invoice)
    expect(invoice).to be_valid
  end

  it "belongs to a booking" do
    booking = FactoryBot.create(:booking)
    invoice = FactoryBot.create(:invoice, booking: booking)
    expect(invoice.booking).to eq(booking)
  end
  
  it "can access car_owner through booking" do
    owner = FactoryBot.create(:car_owner)
    booking = FactoryBot.create(:booking, user: owner)
    invoice = FactoryBot.create(:invoice, booking: booking)
    expect(invoice.car_owner).to eq(owner)
  end

  it "is invalid without an amount" do
    invoice = FactoryBot.build(:invoice, amount: nil)
    expect(invoice).not_to be_valid
  end
end