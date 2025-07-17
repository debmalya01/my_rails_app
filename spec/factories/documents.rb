FactoryBot.define do
  factory :document do
    document_type { :rc_document }
    number { "DOC123456" }
    issued_at { Date.today }

    # associate with any model, here using Car as an example
    association :documentable, factory: :car
  end
end
