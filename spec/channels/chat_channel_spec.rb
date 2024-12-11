require 'rails_helper'

RSpec.describe ChatChannel, type: :channel do
  let(:user) { User.create!(username: 'awesomehawkeye', email: 'awesome@uiowa.edu', password_digest: '12345') }
  let(:grid) { Grid.create!(id: 1, name: 'Test Grid') }
  let(:character) { Character.create!(username: user.username, character_name: 'Hawkeye', level: 1, grid_id: grid.id) }
  let(:room_id) { 1 }

  before do
    stub_connection(current_user: user)
  end

  describe 'subscribing to a chatroom' do
    context 'when the subscription is successful' do
      it 'successfully subscribes to the chatroom stream' do
        subscribe(channel_type: 'room', room_id: room_id)
        expect(subscription).to be_confirmed
        expect(subscription).to have_stream_from("room_chat_#{room_id}")
      end
    end
  end

    context 'when subscribing to the world chat' do
      it 'successfully subscribes to the world chat stream' do
        subscribe(channel_type: 'world')
        expect(subscription).to be_confirmed
        expect(subscription).to have_stream_from("world_chat")
      end
    end

  context 'when the subscription fails' do
    it 'rejects the subscription if room_id is missing for room chat' do
      subscribe(channel_type: 'room')
      expect(subscription).to be_rejected
    end
  end
end