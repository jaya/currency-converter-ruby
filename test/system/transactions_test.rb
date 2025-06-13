require "application_system_test_case"

class TransactionsTest < ApplicationSystemTestCase
  setup do
    @transaction = transactions(:one)
  end

  test "visiting the index" do
    visit transactions_url
    assert_selector "h1", text: "Transactions"
  end

  test "should create transaction" do
    visit transactions_url
    click_on "New transaction"

    fill_in "From cur", with: @transaction.from_cur
    fill_in "From val", with: @transaction.from_val
    fill_in "Rate", with: @transaction.rate
    fill_in "Timestamp", with: @transaction.timestamp
    fill_in "To cur", with: @transaction.to_cur
    fill_in "To val", with: @transaction.to_val
    fill_in "User", with: @transaction.user_id
    click_on "Create Transaction"

    assert_text "Transaction was successfully created"
    click_on "Back"
  end

  test "should update Transaction" do
    visit transaction_url(@transaction)
    click_on "Edit this transaction", match: :first

    fill_in "From cur", with: @transaction.from_cur
    fill_in "From val", with: @transaction.from_val
    fill_in "Rate", with: @transaction.rate
    fill_in "Timestamp", with: @transaction.timestamp.to_s
    fill_in "To cur", with: @transaction.to_cur
    fill_in "To val", with: @transaction.to_val
    fill_in "User", with: @transaction.user_id
    click_on "Update Transaction"

    assert_text "Transaction was successfully updated"
    click_on "Back"
  end

  test "should destroy Transaction" do
    visit transaction_url(@transaction)
    click_on "Destroy this transaction", match: :first

    assert_text "Transaction was successfully destroyed"
  end
end
