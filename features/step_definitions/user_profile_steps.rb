Given(/^I have an account$/) do
  @user = User.create!(username: 'awesomehawkeye', email: 'awesome@uiowa.edu', password_digest: '12345')
  # @grid = Grid.create!(grid_id: 1, name: 'world')
  # @cell = Cell.create!(cell_id: 1, cell_loc: '1A', mons_prob: 0.3, disaster_prob: 0.3, weather: 'Sunny',
  #                      terrain:'desert', has_store: true, grid_id: @grid.grid_id)
  # @item = Item.create!()
  # @inventory = Inventori.create!()
  # TODO: create other models with minimum code and create dummy variables
  @character = Character.create!(username: @user.username, character_name: 'Hawkeye',
                                    shard_balance: 0, health: 100, experience: 0, level: 1,
                                    grid_id: 1, cell_id: 1, inv_id: 1)
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
  expect(page).to have_content("Current balance: #{@character.shard_balance} shards")
end
