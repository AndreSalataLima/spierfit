require 'rails_helper'

RSpec.describe "Personals", type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:gym) { Gym.create!(name: "Test Gym", email: "gym@test.com", password: "password123") }
  let!(:personal) { Personal.create!(name: "Test Personal", email: "personal@test.com", password: "password123") }
  let(:valid_attributes) { { name: "New Personal", email: "new@test.com", password: "password123" } }
  let(:invalid_attributes) { { name: "", email: "invalid" } }

  before do
    gym.personals << personal
    personal.reload
  end

  describe "GET /index" do
    it "lists personals for a gym" do
      get gym_personals_path(gym)
      expect(response).to be_successful
      expect(response.body).to include(personal.name)
    end
  end

  describe "GET /show" do
    context "when authorized" do
      before do
        sign_in personal
        post select_gym_personal_path(personal), params: { gym_id: gym.id }
      end

      it "shows personal details" do
        get personal_path(personal)
        expect(response).to be_successful
        expect(response.body).to include(personal.name)
      end
    end

    context "when unauthorized" do
      it "redirects to login" do
        get personal_path(personal)
        expect(response).to redirect_to(new_personal_session_path)
      end
    end
  end

  describe "GET /new" do
    context "as authenticated gym" do
      before { sign_in gym }

      it "renders new form" do
        get new_gym_personal_path(gym)
        expect(response).to be_successful
        expect(response.body).to include("New Personal")
      end
    end

    context "as unauthenticated user" do
      it "redirects to login" do
        get personal_path(personal)
        expect(response).to redirect_to(new_personal_session_path)
      end
    end
  end

  describe "POST /create" do
    context "as authenticated gym" do
      before { sign_in gym }

      context "with valid params" do
        it "creates new personal" do
          expect {
            post gym_personals_path(gym), params: { personal: valid_attributes }
          }.to change(Personal, :count).by(1)

          expect(response).to redirect_to(gym_personals_path(gym))
          expect(flash[:notice]).to be_present
        end
      end

      context "with duplicate email" do
        before { Personal.create!(valid_attributes) }

        it "rejects duplicate email" do
          expect {
            post gym_personals_path(gym), params: { personal: valid_attributes }
          }.not_to change(Personal, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(flash[:alert]).to include("já está em uso")
        end
      end

      context "with invalid params" do
        it "rejects invalid data" do
          expect {
            post gym_personals_path(gym), params: { personal: invalid_attributes }
          }.not_to change(Personal, :count)

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe "GET /edit" do
    context "when authorized" do
      before do
        sign_in personal
        post select_gym_personal_path(personal), params: { gym_id: gym.id }
      end

      it "shows edit form" do
        get edit_personal_path(personal)
        expect(response).to be_successful
        expect(response.body).to include("Editing Personal")
      end
    end
  end

  describe "PATCH /update" do
    context "when authorized" do
      before do
        sign_in personal
        post select_gym_personal_path(personal), params: { gym_id: gym.id }
      end

      context "with valid params" do
        it "updates personal" do
          patch personal_path(personal), params: { personal: { name: "Updated Name" } }
          personal.reload
          expect(personal.name).to eq("Updated Name")
          expect(response).to redirect_to(personal_path(personal))
        end
      end

      context "with invalid params" do
        it "rejects invalid updates" do
          patch personal_path(personal), params: { personal: { email: "" } }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe "DELETE /destroy" do
    context "when authorized" do
      before do
        sign_in personal
        post select_gym_personal_path(personal), params: { gym_id: gym.id }
      end

      it "destroys personal" do
        expect {
          delete personal_path(personal)
        }.to change(Personal, :count).by(-1)
        expect(response).to redirect_to(personals_url)
      end
    end
  end

  describe "remove_from_gym" do
    before { sign_in gym }

    it "removes gym association" do
      expect {
        delete remove_from_gym_personal_path(personal, gym_id: gym.id)
      }.to change { personal.gyms.count }.by(-1)

      expect(response).to redirect_to(gym_personals_path(gym))
    end
  end
end
