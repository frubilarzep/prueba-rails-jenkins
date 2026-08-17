require "rails_helper"

RSpec.describe "Tasks", type: :request do
  describe "GET /tasks" do
    it "returns all tasks" do
      create_list(:task, 2)

      get "/tasks"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(2)
    end
  end

  describe "GET /tasks/:id" do
    it "returns the task" do
      task = create(:task)

      get "/tasks/#{task.id}"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["id"]).to eq(task.id)
      expect(body["title"]).to eq(task.title)
      expect(body["completed"]).to eq(task.completed)
    end
  end

  describe "POST /tasks" do
    it "creates a task with valid params" do
      expect {
        post "/tasks", params: { task: { title: "New task" } }
      }.to change(Task, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "does not create a task with invalid params" do
      expect {
        post "/tasks", params: { task: { title: "" } }
      }.not_to change(Task, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /tasks/:id" do
    it "updates the task" do
      task = create(:task)

      patch "/tasks/#{task.id}", params: { task: { title: "Updated title" } }

      expect(response).to have_http_status(:ok)
      expect(task.reload.title).to eq("Updated title")
    end
  end

  describe "DELETE /tasks/:id" do
    it "destroys the task" do
      task = create(:task)

      expect {
        delete "/tasks/#{task.id}"
      }.to change(Task, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
