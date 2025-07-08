class Car < ApplicationRecord
    after_create :create_document

    belongs_to :car_owner, class_name: 'CarOwner', foreign_key: 'user_id' 
    has_many :bookings, dependent: :destroy
    belongs_to :vehicle_brand
    has_many :documents, as: :documentable, dependent: :destroy

    validates :model, :registration_number, presence: true
    validates :registration_number, uniqueness: true
    
    def self.ransackable_attributes(auth_object = nil)
        %w[make year model registration_number user_id car_owner_id bookings_id documents_id]
    end

    def self.ransackable_associations(auth_object = nil)
        %w[vehicle_brand car_owner]
    end

    def car_owner_id
        user_id
    end


    private
    def create_document
        Document.create!(
            documentable: self,
            document_type: :rc_document,
            number: registration_number,
            issued_at: Date.today
        )
    end
end
