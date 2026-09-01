require "rails_helper"

RSpec.describe "People", type: :request do
  describe "GET /people" do
    it "returns all people" do
      create_list(:person, 2)

      get "/people"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(2)
    end
  end

  describe "GET /people/:id" do
    it "returns the person" do
      person = create(:person)

      get "/people/#{person.id}"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["id"]).to eq(person.id)
    end
  end

  describe "POST /people" do
    it "creates a person with valid params" do
      expect {
        post "/people", params: { person: { name: "John Doe", rut: "12345678-9", age: 40, address: "456 Elm St" } }
      }.to change(Person, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "does not create a person with invalid params" do
      expect {
        post "/people", params: { person: { name: "" } }
      }.not_to change(Person, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /people/:id" do
    it "updates the person" do
      person = create(:person)

      patch "/people/#{person.id}", params: { person: { name: "Updated Name" } }

      expect(response).to have_http_status(:ok)
      expect(person.reload.name).to eq("Updated Name")
    end
  end

  describe "DELETE /people/:id" do
    it "destroys the person" do
      person = create(:person)

      expect {
        delete "/people/#{person.id}"
      }.to change(Person, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
