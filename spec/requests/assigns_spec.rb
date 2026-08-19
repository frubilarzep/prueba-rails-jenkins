require "rails_helper"

RSpec.describe "Assigns", type: :request do
  describe "GET /assigns" do
    it "returns all assigns" do
      create_list(:assign, 2)

      get "/assigns"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(2)
    end
  end

  describe "GET /assigns/:id" do
    it "returns the assign" do
      assign = create(:assign)

      get "/assigns/#{assign.id}"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["id"]).to eq(assign.id)
    end
  end

  describe "POST /assigns" do
    it "creates an assign with valid params" do
      expect {
        post "/assigns", params: { assign: { titulo: "New assign", fecha_inscripcion: Date.current } }
      }.to change(Assign, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "does not create an assign with invalid params" do
      expect {
        post "/assigns", params: { assign: { titulo: "" } }
      }.not_to change(Assign, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /assigns/:id" do
    it "updates the assign" do
      assign = create(:assign)

      patch "/assigns/#{assign.id}", params: { assign: { titulo: "Updated titulo" } }

      expect(response).to have_http_status(:ok)
      expect(assign.reload.titulo).to eq("Updated titulo")
    end
  end

  describe "DELETE /assigns/:id" do
    it "destroys the assign" do
      assign = create(:assign)

      expect {
        delete "/assigns/#{assign.id}"
      }.to change(Assign, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
