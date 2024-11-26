Given('a grid named {string} exists') do |grid_name|
  @grid = Grid.find_or_create_by!(grid_id: 1, name: grid_name)
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
  # Assuming each row has 'cols' number of cells
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
