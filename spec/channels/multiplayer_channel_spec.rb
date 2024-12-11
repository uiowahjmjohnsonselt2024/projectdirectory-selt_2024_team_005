require 'rails_helper'

RSpec.describe MultiplayerChannel, type: :channel do
  let(:user) { User.create!(username: 'Herky', email: 'herky@uiowa.edu', password_digest: '12345') }
  let(:grid) { Grid.create!(id: 1, name: 'Europa') }
  let(:cell) { Cell.create!(cell_loc: "R0C1", grid_id: grid.id)}
  let(:inventory) { Inventory.create!(inv_id: 1) }
  let(:character) { Character.create!(username: user.username, character_name: 'Herky', level: 1, grid_id: grid.id, inv_id: 1, online_status: false, cell_id: 1) }

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
