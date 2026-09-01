require "rails_helper"

RSpec.describe "Asignaturas", type: :request do
  describe "GET /asignaturas" do
    it "returns all asignaturas" do
      create_list(:asignatura, 2)

      get "/asignaturas"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(2)
    end
  end

  describe "GET /asignaturas/:id" do
    it "returns the asignatura" do
      asignatura = create(:asignatura)

      get "/asignaturas/#{asignatura.id}"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["id"]).to eq(asignatura.id)
    end
  end

  describe "POST /asignaturas" do
    it "creates an asignatura with valid params" do
      expect {
        post "/asignaturas", params: { asignatura: { nombre: "Bases de Datos", codigo: "BDD-101", seccion: 1, semestre: "2026-2" } }
      }.to change(Asignatura, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "does not create an asignatura with invalid params" do
      expect {
        post "/asignaturas", params: { asignatura: { nombre: "" } }
      }.not_to change(Asignatura, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /asignaturas/:id" do
    it "updates the asignatura" do
      asignatura = create(:asignatura)

      patch "/asignaturas/#{asignatura.id}", params: { asignatura: { nombre: "Nombre Actualizado" } }

      expect(response).to have_http_status(:ok)
      expect(asignatura.reload.nombre).to eq("Nombre Actualizado")
    end

    it "does not update with invalid params" do
      asignatura = create(:asignatura)

      patch "/asignaturas/#{asignatura.id}", params: { asignatura: { nombre: "" } }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /asignaturas/:id" do
    it "destroys the asignatura" do
      asignatura = create(:asignatura)

      expect {
        delete "/asignaturas/#{asignatura.id}"
      }.to change(Asignatura, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
