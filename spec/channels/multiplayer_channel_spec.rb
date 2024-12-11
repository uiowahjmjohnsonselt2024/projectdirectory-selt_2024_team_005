require 'rails_helper'

RSpec.describe MultiplayerChannel, type: :channel do
  let(:user) do
    User.create!(
      username: 'awesomehawkeye',
      email: 'awesome@uiowa.edu',
      password_digest: '12345', # Typically would be generated via has_secure_password
      shard_balance: 0
    )
  end

  let(:grid) do
    Grid.create!(
      grid_id: 1,
      name: 'Test Grid',
      cost: 10
    )
  end

  let(:inventory) do
    Inventory.create! # Creates an inventory with default items array
  end

  # Create a cell belonging to the grid
  let(:cell) do
    Cell.create!(
      cell_loc: '0,0',
      mons_prob: 0.1,
      disaster_prob: 0.0,
      weather: 'Clear',
      terrain: 'Grass',
      has_store: false,
      grid_id: grid.grid_id
    )
  end

  # Create a character using all required attributes per the schema
  let(:character) do
    Character.create!(
      username: user.username,
      character_name: 'Hawkeye',
      current_hp: 10,
      max_hp: 10,
      current_exp: 0,
      exp_to_level: 100,
      level: 1,
      weapon_item_id: 1,    # Arbitrary valid integer
      armor_item_id: 1,     # Arbitrary valid integer
      grid_id: grid.grid_id,
      cell_id: cell.cell_id,
      inv_id: inventory.inv_id,
      online_status: false
    )
  end

  let(:room_id) { 1 }

  before do
    stub_connection(current_user: user)
    character # Ensure the character is created
  end

  describe 'subscribing to the channel' do
    it 'confirms subscription and streams from the correct grid' do
      subscribe
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("multiplayer_grid_#{character.grid_id}")
    end
  end
end
