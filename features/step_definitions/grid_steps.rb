Given('a grid named {string} exists') do |grid_name|
  # Grid requires name and cost, no size field is present in the schema
  @grid = Grid.find_or_create_by!(grid_id: 1, name: grid_name, cost: 20)
end

Given('I am logged in as {string}') do |username|
  @user = User.create!(
    username: username,
    email: "#{username}@example.com",
    password: 'password',
    password_confirmation: 'password',
    shard_balance: 100
  )
  visit login_path
  fill_in 'Username', with: @user.username
  fill_in 'Password', with: 'password'
  click_button 'Log In'
end

Given('my grid visibility is {int}') do |visibility|
  @user.set_visibility_for(@grid, visibility)
end

When('I am on the grid page for {string}') do |grid_name|
  visit grid_path(@grid)
end

When('I click the {string} button') do |button_text|
  click_button button_text
end

Then('I should see a grid of size {int}x{int}') do |rows, cols|
  expect(page).to have_selector('.grid-row', count: rows)
  total_cells = rows * cols
  expect(page).to have_selector('.grid-cell', count: total_cells)
end

Then('my grid visibility should be {int}') do |visibility|
  expect(@user.visibility_for(@grid)).to eq(visibility)
end

Then('I should see a success message {string}') do |message|
  expect(page).to have_content(message)
end

Then('I should not see the {string} button') do |button_text|
  expect(page).not_to have_button(button_text)
end

Then('I should see a message {string}') do |message|
  expect(page).to have_content(message)
end

Given('another user {string} exists') do |username|
  @other_user = User.create!(
    username: username,
    email: "#{username}@example.com",
    password: 'password',
    password_confirmation: 'password',
    shard_balance: 100
  )
end

Given('{string} has a grid visibility of {int} for {string}') do |username, visibility, grid_name|
  user = User.find_by(username: username)
  grid = Grid.find_by(name: grid_name)
  user.set_visibility_for(grid, visibility)
end

When('I visit the grid page for {string} as {string}') do |username|
  visit grid_path(@grid)
end

Then('I should be redirected to the home page') do
  expect(current_path).to eq(root_path)
end

Given(/^I have an account and logged in$/) do
  @user = User.create!(
    username: 'awesomehawkeye',
    email: 'awesome@uiowa.edu',
    password: '12345',
    password_confirmation: '12345',
    shard_balance: 0
  )
  # Grids now require name and cost, no size field
  @grid = Grid.create!(grid_id: 1, name: 'earth', cost: 20)

  # Cells require: cell_loc, mons_prob, disaster_prob, weather, terrain, has_store, grid_id
  @cell = Cell.create!(
    cell_id: 1,
    cell_loc: '1A',
    mons_prob: 0.3,
    disaster_prob: 0.3,
    weather: 'Sunny',
    terrain: 'desert',
    has_store: true,
    grid_id: @grid.grid_id
  )

  # Weapons require: name, description, icon, atk_bonus
  @sword = Weapon.create!(name: 'sword', description: 'A basic sword', icon: 'sword.png', atk_bonus: 1)
  # Armors require: name, description, icon, def_bonus
  @shield = Armor.create!(name: 'shield', description: 'A basic shield', icon: 'shield.png', def_bonus: 1)

  # Items require: itemable_type, itemable_id, cost, rarity, level
  @item1 = Item.create!(itemable: @sword, cost: 1, rarity: 1, level: 1)
  @item2 = Item.create!(itemable: @shield, cost: 1, rarity: 1, level: 1)

  # Inventories require: inv_id, items (array)
  @inventory = Inventory.create!(inv_id: 1, items: [@item1.item_id, @item2.item_id])

  # Characters require: username, character_name, current_hp, current_exp, level, grid_id, cell_id, inv_id, max_hp, exp_to_level, weapon_item_id, armor_item_id
  # Set some defaults (e.g. current_hp = 100, current_exp = 0, level = 1, max_hp = 100, exp_to_level = 100, weapon_item_id, armor_item_id)
  @character = Character.create!(
    username: @user.username,
    character_name: 'Hawkeye',
    current_hp: 100,
    current_exp: 0,
    level: 1,
    grid_id: @grid.grid_id,
    cell_id: @cell.cell_id,
    inv_id: @inventory.inv_id,
    max_hp: 100,
    exp_to_level: 100,
    weapon_item_id: @item1.item_id, # sword
    armor_item_id: @item2.item_id   # shield
  )

  visit login_path
  fill_in 'Username', with: 'awesomehawkeye'
  fill_in 'Password', with: '12345'
  click_button 'Log In'
end

Given(/^I have a balance of \$(\d+)$/) do |amount|
  @user.update!(shard_balance: amount.to_i)
end

When(/^I go to my profile page$/) do
  click_link 'Profile'
end

Then(/^I should see my current balance$/) do
  expect(page).to have_content("Current balance: #{@user.shard_balance} shards")
end

When(/^I buy (-?\d+) (USD|EUR) worth of shards with a credit card$/) do |amount, currency|
  click_link 'Buy more shards'
  fill_in 'Enter Currency Amount', with: amount
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


