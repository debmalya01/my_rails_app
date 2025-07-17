# spec/factories/invoices.rb
FactoryBot.define do
  factory :invoice do
    booking
    amount { 1000 }
    issued_at { Date.today }
    status { 'pending' }
  end
end
