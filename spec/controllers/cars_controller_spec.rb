require 'rails_helper'

RSpec.describe CarsController, type: :controller do
  include Devise::Test::ControllerHelpers 

  let(:user) { FactoryBot.create(:car_owner) }
  let(:vehicle_brand) { FactoryBot.create(:vehicle_brand) }
  let!(:car) { FactoryBot.create(:car, car_owner: user, vehicle_brand: vehicle_brand) }

  before do
    sign_in user  
  end

  describe 'GET #index' do
    it 'renders the index page successfully' do
      get :index
      expect(response).to be_successful
      expect(assigns(:cars)).to eq([car])
    end
  end

  

  describe 'GET #new' do
    it 'renders the new page successfully' do
      get :new
      expect(response).to be_successful
      expect(assigns(:car)).to be_a_new(Car)
    end
  end

  describe 'POST #create' do
    it 'creates a new car and redirects' do
      expect {
        post :create, params: {
          car: {
            model: 'Civic',
            year: 2021,
            registration_number: 'MH12ABC1234',
            vehicle_brand_id: vehicle_brand.id
          }
        }
      }.to change(Car, :count).by(1)

      expect(response).to redirect_to(Car.last)
      expect(flash[:notice]).to eq("Car was successfully created.")
    end
  end

  describe 'GET #edit' do
    it 'renders the edit page successfully' do
      get :edit, params: { id: car.id }
      expect(response).to be_successful
      expect(assigns(:car)).to eq(car)
    end
  end

  describe 'PATCH #update' do
    it 'updates the car and redirects' do
      patch :update, params: {
        id: car.id,
        car: { model: 'Updated Model' }
      }
      expect(response).to redirect_to(car)
      expect(car.reload.model).to eq('Updated Model')
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the car and redirects' do
      expect {
        delete :destroy, params: { id: car.id }
      }.to change(Car, :count).by(-1)

      expect(response).to redirect_to(cars_path)
    end
  end
end
