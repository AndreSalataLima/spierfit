require 'rails_helper'

RSpec.describe "ESP32 API", type: :request do
  # Para evitar problemas com ActionCable e Redis durante os testes,
  # você pode mockar o broadcast (se não quiser subir o Redis nos testes).
  # Descomente se quiser:
  #
  # before do
  #   allow(ActionCable.server).to receive(:broadcast)
  # end

  describe "GET /esp32/data_points" do
    let!(:point1) { DataPoint.create!(value: 10, mac_address: "AA:BB:CC:DD:EE:FF") }
    let!(:point2) { DataPoint.create!(value: 20, mac_address: "11:22:33:44:55:66") }

    it "retorna sucesso e exibe os data_points" do
      get "/esp32/data_points"
      expect(response).to have_http_status(:success)
      # Se estiver renderizando uma view, você pode checar se o body inclui algo:
      expect(response.body).to include("AA:BB:CC:DD:EE:FF")
      expect(response.body).to include("11:22:33:44:55:66")
    end
  end

  describe "POST /esp32/receive_data" do
    # Supondo que haja um ExerciseSet em aberto
    let!(:exercise) { Exercise.create!(name: "Supino", muscle_group: "Peito") }
    let!(:workout) { Workout.create! }
    let!(:exercise_set) { ExerciseSet.create!(reps: 0, sets: 0, workout: workout, exercise: exercise) }

    context "com dados válidos" do
      let(:valid_body) do
        {
          sensor_value: "15.0",
          mac_address: "FF:FF:FF:FF:FF:FF",
          creation_time: "2023-01-01T12:00:00Z"
        }.to_json
      end

      it "cria um novo DataPoint e retorna status 200" do
        expect {
          post "/esp32/receive_data",
               params: valid_body,
               headers: { "CONTENT_TYPE" => "application/json" }
        }.to change(DataPoint, :count).by(1)

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["status"]).to eq("Success")

        new_point = DataPoint.last
        expect(new_point.value).to eq(15.0)
        expect(new_point.mac_address).to eq("FF:FF:FF:FF:FF:FF")
      end

    end

    context "com dados inválidos" do
      it "retorna erro e status 500" do
        # Fornecemos creation_time para evitar erro de parse,
        # mas omitimos mac_address para falhar na validação.
        invalid_body = {
          sensor_value: "15.0",
          creation_time: "2023-01-01T12:00:00Z"
        }.to_json

        post "/esp32/receive_data",
          params: invalid_body,
          headers: { "CONTENT_TYPE" => "application/json" }

        expect(response).to have_http_status(:internal_server_error)

        json = JSON.parse(response.body)
        expect(json["status"]).to eq("Error")
        expect(json["message"]).to match(/can't be blank/)
      end
    end



  end
end
