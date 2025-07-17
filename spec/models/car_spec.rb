require 'rails_helper'

RSpec.describe Car, type: :model do

    describe "validations" do

        it "is valid with valid attributes" do
            car = FactoryBot.build(:car)
            expect(car).to be_valid
        end

        it "is not valid without a model" do
            car = FactoryBot.build(:car, model: nil)
            expect(car).not_to be_valid
        end

        it  "is not valid without a registration number" do
            car = FactoryBot.build(:car, registration_number: nil)
            expect(car).not_to be_valid
        end

        it "is not valid with a duplicate registration number" do
            FactoryBot.create(:car, registration_number: "ABC123")
            car = FactoryBot.build(:car, registration_number: "ABC123")
            expect(car).not_to be_valid
        end
    
    end

    describe "associations" do

        it "belongs to a car owner" do
            car = FactoryBot.create(:car)
            expect(car.car_owner).to be_a(CarOwner)
        end

    end

    describe "callbacks" do
        it "creates a document after creation" do
            car = FactoryBot.create(:car)
            expect(car.documents.count).to eq(1)
            expect(car.documents.first.document_type).to eq("rc_document")
            expect(car.documents.first.number).to eq(car.registration_number)
        end
    end       

end