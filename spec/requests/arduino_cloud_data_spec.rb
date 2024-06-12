require 'rails_helper'

RSpec.describe "ArduinoCloudData", type: :request do
  describe "GET /fetch_and_save" do
    it "returns http success" do
      get "/arduino_cloud_data/fetch_and_save"
      expect(response).to have_http_status(:success)
    end
  end

end
