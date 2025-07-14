class ServiceCenter < ApplicationRecord
    after_create :create_document
    belongs_to :user, class_name: 'GarageAdmin'
    has_many :bookings
    has_many :service_center_brands
    has_many :vehicle_brands, through: :service_center_brands

    has_many :documents, as: :documentable, dependent: :destroy

    validates :garage_name, :phone, :pincode, presence: true
    validates :phone, format: { with: /\A\d{10}\z/, message: "must be a 10-digit number" }
    validates :pincode, format: { with: /\A\d{6}\z/, message: "must be a 6-digit number" }
    validates :max_capacity_per_day, numericality: { only_integer: true, greater_than: 0 }

    def self.ransackable_attributes(auth_object = nil)
        %w[garage_name phone pincode max_capacity_per_day license_number] 
    end

    def self.ransackable_associations(auth_object = nil)
        %w[bookings user]
    end

    def bookings_count
        bookings.count
    end

    private
    def create_document
        Document.create!(
            documentable: self,
            document_type: :license,
            number: license_number,
            issued_at: Date.today
        )
    end
    
end
