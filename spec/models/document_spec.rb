require 'rails_helper'

RSpec.describe Document, type: :model do
  it "is valid with valid attributes" do
    document = FactoryBot.build(:document)
    expect(document).to be_valid
  end

  it "is invalid without document_type" do
    doc = FactoryBot.build(:document, document_type: nil)
    expect(doc).not_to be_valid
    expect(doc.errors[:document_type]).to include("can't be blank")
  end

  it "is invalid without number" do
    doc = FactoryBot.build(:document, number: nil)
    expect(doc).not_to be_valid
    expect(doc.errors[:number]).to include("can't be blank")
  end

  it "belongs to a documentable (polymorphic)" do
    car = FactoryBot.create(:car)
    document = FactoryBot.create(:document, documentable: car)
    expect(document.documentable).to eq(car)
  end

  it "has expected enum values" do
    expect(Document.document_types.keys).to contain_exactly("rc_document", "license")
  end

  let(:service_center) { FactoryBot.create(:service_center, license_number: "LIC123") }

  it "associates with service center as documentable" do
    doc = FactoryBot.create(:document, documentable: service_center, number: "LIC123", document_type: "license")
    expect(doc.documentable).to eq(service_center)
  end

end
