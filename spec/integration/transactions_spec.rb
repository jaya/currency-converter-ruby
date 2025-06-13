require 'rails_helper'

RSpec.describe "Transactions", type: :request do
  let!(:user) { create(:user) }
  let!(:transactions) { create_list(:transaction, 3, user: user) }

  describe "GET /transactions" do
    it "returns http success" do
      get transactions_path
      expect(response).to have_http_status(:success)
    end

    it "returns transactions as JSON" do
      get transactions_path, headers: { "ACCEPT" => "application/json" }
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.first["user_id"]).to eq(user.id)
    end

    it "filters transactions by user_id" do
      other_user = create(:user)
      create(:transaction, user: other_user)
      get transactions_path, params: { user_id: other_user.id }, headers: { "ACCEPT" => "application/json" }
      json = JSON.parse(response.body)
      expect(json.all? { |t| t["user_id"] == other_user.id }).to be true
    end
  end

  describe "POST /transactions/convert" do
    it "requires authentication" do
      post convert_transactions_path, params: { from_cur: "USD", to_cur: "BRL", from_val: 10 }
      expect(response).to have_http_status(:found) # redirect to login
    end

    it "creates a transaction when authenticated" do
      # Simulate login
      post login_path, params: {
        session: {
          email: user.email,
          password: user.password
        }
      }
      expect {
        post convert_transactions_path, params: { from_cur: "USD", to_cur: "BRL", from_val: 10 }
      }.to change(Transaction, :count).by(1)
    end
  end
end
