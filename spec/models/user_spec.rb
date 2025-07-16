require 'rails_helper'

RSpec.describe User, type: :model do
    it "is valid with valid attributes" do
        user = FactoryBot.build(:user)
        expect(user).to be_valid
    end

    it "is not valid without an email" do
        user = FactoryBot.build(:user, email: nil)
        expect(user).not_to be_valid
    end

    it "is not valid without a password" do
        user = FactoryBot.build(:user, password: nil)
        expect(user).not_to be_valid
    end

    it "is not valid with a duplicate email" do
        FactoryBot.create(:user, email: "test@example.com")
        user = FactoryBot.build(:user, email: "test@example.com")
    end

    it "is not valid with a password that is too short" do
        user = FactoryBot.build(:user, password: "short")
        expect(user).not_to be_valid
    end

    it "calculates the correct invoice amount" do
        booking = FactoryBot.build(:booking)
        expected_amount = booking.service_types.sum(&:base_price)
        expect(booking.send(:calculate_invoice_amount)).to eq(expected_amount)
    end

    it "generates an invoice after creation" do
        booking = FactoryBot.create(:booking)
        expect(booking.invoice).to be_present
        expect(booking.invoice.amount).to eq(booking.send(:calculate_invoice_amount))
        expect(booking.invoice.status).to eq('pending')
        expect(booking.invoice.issued_at).to eq(Date.today)
    end
    
    it "updates the invoice after update" do
        booking = FactoryBot.create(:booking)
        old_amount = booking.invoice.amount
        booking.update(status: 'in_service')
        expect(booking.invoice.amount).to eq(old_amount) # Amount should not change on status update
        expect(booking.invoice.status).to eq('pending') # Status should remain pending
    end
end