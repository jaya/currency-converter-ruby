require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let(:user) { create(:user) }

  it "is valid with valid attributes" do
    transaction = build(:transaction, user: user)
    expect(transaction).to be_valid
  end

  it "is invalid without a user" do
    transaction = build(:transaction, user: nil)
    expect(transaction).not_to be_valid
    expect(transaction.errors[:user]).to include("must exist").or include("can't be blank")
  end

  it "is invalid without from_cur" do
    transaction = build(:transaction, from_cur: nil)
    expect(transaction).not_to be_valid
  end

  it "is invalid without to_cur" do
    transaction = build(:transaction, to_cur: nil)
    expect(transaction).not_to be_valid
  end

  it "is invalid if from_val is negative" do
    transaction = build(:transaction, from_val: -10)
    expect(transaction).not_to be_valid
  end
end
