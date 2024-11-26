Given(/^I have an account and logged in$/) do
  @user = User.create!(
    username: 'awesomehawkeye',
    email: 'awesome@uiowa.edu',
    password: '12345',
    password_confirmation: '12345',
    shard_balance: 0
  )
  @grid = Grid.create!(grid_id: 1, size: 10, name: 'earth')
  @cell = Cell.create!(cell_id: 1, cell_loc: '1A', mons_prob: 0.3, disaster_prob: 0.3, weather: 'Sunny',
                       terrain: 'desert', has_store: true, grid_id: @grid.grid_id)
  @item1 = Item.create!(item_id: 1, name: 'thingy', category: 'sword', cost: 1)
  @item2 = Item.create!(item_id: 2, name: 'stuff', category: 'shield', cost: 1)

  @inventory = Inventory.create!(inv_id: 1, items: [ @item1, @item2 ])
  @character = Character.create!(username: @user.username, character_name: 'Hawkeye', health: 100,
                                 experience: 0, level: 1, grid_id: @grid.grid_id, cell_id: @cell.cell_id,
                                 inv_id: @inventory.inv_id)
  visit login_path
  fill_in 'Username', with: 'awesomehawkeye'
  fill_in 'Password', with: '12345'
  click_button 'Log In'
end

Given(/^I have a balance of \$(\d+)$/) do |amount|
  @user.update!(shard_balance: amount.to_f)
end

When(/^I go to my profile page$/) do
  click_link 'Profile'
end

Then(/^I should see my current balance$/) do
  expect(page).to have_content("Current balance: #{@user.shard_balance} shards")
end

When(/^I buy (-?\d+) (USD|EUR) worth of shards with a credit card$/) do |amount, currency|
  click_link 'Buy more shards'
  fill_in 'Enter Amount', with: amount
  select currency, from: 'Select Currency'
  fill_in 'Credit Card Number', with: '1234567812345678'
  fill_in 'Expiration Date (MM/YY)', with: '12/25'
  fill_in 'CVV', with: '123'
  click_button 'Pay'
end

Then(/^my current balance should have (\d+) shards$/) do |expected_shards|
  expect(page).to have_content("Current balance: #{expected_shards} shards")
end

Then(/^my current balance should have at least (\d+) shards$/) do |expected_shards|
  displayed_shards = find('p', text: /Current balance:/).text.match(/(\d+) shards/)[1].to_i
  expect(displayed_shards).to be >= expected_shards.to_i
end

Then(/^I should see an error message$/) do
  expect(page).to have_content("Please enter a valid amount.")
end

When(/^I delete my account$/) do
  click_button('Delete account')
end

Then(/^my account should be deleted$/) do
  # expect(page).to have_current_path(root_path)
  expect(page).to have_content('Your account has been successfully deleted.')
end
