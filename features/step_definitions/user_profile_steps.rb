Given(/^I have an account$/) do
  @user = User.create!(username: 'awesomehawkeye', email: 'awesome@uiowa.edu', password_digest: '12345')
  @grid = Grid.create!(grid_id: 1, name: 'earth')
  @cell = Cell.create!(cell_id: 1, cell_loc: '1A', mons_prob: 0.3, disaster_prob: 0.3, weather: 'Sunny',
                       terrain: 'desert', has_store: true, grid_id: @grid.grid_id)
  @item1 = Item.create!(item_id: 1, name: 'thingy', category: 'sword', cost: 1)
  @item2 = Item.create!(item_id: 2, name: 'stuff', category: 'shield', cost: 1)

  @inventory = Inventory.create!(inv_id: 1, items: [ @item1, @item2 ])
  @character = Character.create!(username: @user.username, character_name: 'Hawkeye',
                                    shard_balance: 0, health: 100, experience: 0, level: 1,
                                    grid_id: @grid.grid_id, cell_id: @cell.cell_id, inv_id: @inventory.inv_id)
  # visit new_user_session_path
  # fill_in 'Email', with: @user.email
  # fill_in 'Password', with: 'password'
  # click_button 'Log in'
end

Given(/^I have a balance of \$(\d+)$/) do |amount|
  @character = Character.update!(shard_balance: amount.to_f)
end

When(/^I go to my profile page$/) do
  visit user_path(@user.username)
end

Then(/^I should see my current balance$/) do
  @character = Character.find_by(username: @user.username)
  expect(page).to have_content("Current balance: #{@character.shard_balance} shards")
end

When(/^I buy 10 shards with a credit card$/) do
  visit buy_shards_user_path(@user.username)

  # Select 10 shards radio button
  choose('shards_10')

  # Fill in credit card information (basic placeholders)
  fill_in 'cc_number', with: '1234567812345678'
  fill_in 'cc_expiration', with: '12/25'
  fill_in 'cc_cvv', with: '123'

  # Click on the pay button
  click_button 'Pay'
end

Then(/^my current balance should have 10 shards$/) do
  visit user_path(@user.username)
  expect(page).to have_content('Current balance: 10 shards')
end

When(/^I delete my account$/) do
  click_button('Delete account')
  # page.driver.browser.switch_to.alert.accept rescue Selenium::WebDriver::Error::NoAlertOpenError
  # expect(page).to have_content('Your account has been successfully deleted.')
end

Then(/^my account should be deleted$/) do
  expect(page).to have_content('Your account has been successfully deleted.')
end
