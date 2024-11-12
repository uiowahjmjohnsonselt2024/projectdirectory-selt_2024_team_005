Given(/^I am logged in as a user$/) do
  @user = User.create!(email: 'user@example.com', password: 'password')
  allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
  # visit new_user_session_path
  # fill_in 'Email', with: @user.email
  # fill_in 'Password', with: 'password'
  # click_button 'Log in'
end

Given(/^I have a balance of \$(\d+)$/) do |amount|
  @user_profile = UserProfile.create!(user: @user, balance: amount.to_f)
end

When(/^I go to my profile page$/) do
  visit user_profile_path(@user_profile)
end

Then(/^I should see my current balance$/) do
  expect(page).to have_content("Balance: $#{'%.2f' % @user_profile.balance}")
end
