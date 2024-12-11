require 'rails_helper'

RSpec.describe ChatChannel, type: :channel do
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
    # Establish the cable connection with the current_user set
    stub_connection(current_user: user)
    # Ensure character is created so that current_user.character is valid if needed
    character
  end

  describe 'subscribing to a chatroom' do
    context 'when the subscription is successful' do
      it 'successfully subscribes to the chatroom stream' do
        subscribe(channel_type: 'room', room_id: room_id)
        expect(subscription).to be_confirmed
        expect(subscription).to have_stream_from("room_chat_#{room_id}")
      end
    end

    context 'when subscribing to the world chat' do
      it 'successfully subscribes to the world chat stream' do
        subscribe(channel_type: 'world')
        expect(subscription).to be_confirmed
        expect(subscription).to have_stream_from("world_chat")
      end
    end

    context 'when subscribing with no channel_type specified' do
      it 'defaults to world chat subscription' do
        subscribe
        expect(subscription).to be_confirmed
        expect(subscription).to have_stream_from("world_chat")
      end
    end

    context 'when subscribing to a room without a room_id' do
      it 'rejects the subscription' do
        subscribe(channel_type: 'room')
        expect(subscription).to be_rejected
      end
    end

    context 'when subscribing with an invalid channel_type' do
      it 'rejects the subscription' do
        subscribe(channel_type: 'invalid')
        expect(subscription).to be_rejected
      end
    end
  end

  describe 'receiving messages' do
    before do
      subscribe(channel_type: 'world') # Subscribe to world chat by default
    end

    it 'broadcasts a received message to the world chat' do
      expect {
        perform :receive, { 'message' => 'Hello World!' }
      }.to have_broadcasted_to("world_chat").with(hash_including(message: 'Hello World!', username: 'Hawkeye'))
    end

    it 'does not broadcast if the message is empty' do
      expect {
        perform :receive, { 'message' => '' }
      }.not_to have_broadcasted_to("world_chat")
    end

    it 'does not broadcast if the message is not present' do
      expect {
        perform :receive, {}
      }.not_to have_broadcasted_to("world_chat")
    end
  end

end
