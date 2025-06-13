require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = build(:user)
    expect(user).to be_valid
  end

  it "is invalid without a name" do
    user = build(:user, name: nil)
    expect(user).not_to be_valid
    expect(user.errors[:name]).to include("can't be blank")
  end

  it "is invalid without an email" do
    user = build(:user, email: nil)
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("can't be blank")
  end

  it "is invalid with a duplicate email" do
    create(:user, email: "duplicate@example.com")
    user = build(:user, email: "duplicate@example.com")
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("is already registered.")
  end

  it "is invalid without a password" do
    user = build(:user, password: nil)
    expect(user).not_to be_valid
    expect(user.errors[:password]).to include("can't be blank")
  end
end
