class Car < ApplicationRecord
    after_create :create_document

    belongs_to :car_owner, class_name: 'CarOwner', foreign_key: 'user_id' 
    has_many :bookings, dependent: :destroy
    belongs_to :vehicle_brand
    has_one :document, as: :documentable, dependent: :destroy
    has_one :rc_document, through: :document

    validates :model, :registration_number, presence: true
    validates :registration_number, uniqueness: true
    
    private
    def create_document
        document = Document.create(documentable: self)
        RcDocument.create!(document: document, rc_number: registration_number, issue_date: Date.today)
    end
end
