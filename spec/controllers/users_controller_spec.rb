require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { User.create!(username: 'awesomehawkeye', email: 'awesome@uiowa.edu', password_digest: '12345') }
  let(:character) { Character.create!(username: user.username, character_name: 'Hawkeye', shard_balance: 0,
                                      health: 100, experience: 0, level: 1, grid_id: 1, cell_id: 1, inv_id: 1) }
  describe 'GET #show' do
    context 'when the user exists' do
      it 'returns a successful response' do
        get :show, params: { username: user.username }
        expect(response).to have_http_status(:success)
      end

      it 'assigns the requested user to @user' do
        get :show, params: { username: user.username }
        expect(assigns(:user)).to eq(user)
      end

      it 'renders the show template' do
        get :show, params: { username: user.username }
        expect(response).to render_template(:show)
      end
    end

    context 'when the user does not exist' do
      it 'raises an ActiveRecord::RecordNotFound error' do
        expect {
          get :show, params: { username: 'nonexistentuser' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
end

  describe 'GET #buy_shards' do
    context 'when the user exists' do
      it 'returns a successful response' do
        get :buy_shards, params: { username: user.username }
        expect(response).to have_http_status(:success)
      end

      it 'assigns the requested user to @user' do
        get :buy_shards, params: { username: user.username }
        expect(assigns(:user)).to eq(user)
      end

      it 'renders the buy_shards template' do
        get :buy_shards, params: { username: user.username }
        expect(response).to render_template(:buy_shards)
      end
    end

    context 'when the user does not exist' do
      it 'raises an ActiveRecord::RecordNotFound error' do
        expect {
          get :buy_shards, params: { username: 'nonexistentuser' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'POST #process_payment' do
    context 'with valid shard amount and credit card information' do
      it 'updates the shard balance' do
        post :process_payment, params: {
          username: user.username,
          shards: 10,
          cc_number: '1234567812345678',
          cc_expiration: '12/25',
          cc_cvv: '123'
        }

        character.reload
        expect(character.shard_balance).to eq(10)
        expect(flash[:notice]).to eq("Successfully purchased 10 shards.")
        expect(response).to redirect_to(user_path(user.username))
      end
    end

    context 'with invalid shard amount' do
      it 'shows an alert and redirects back' do
        post :process_payment, params: {
          username: user.username,
          shards: 30, # Invalid amount
          cc_number: '1234567812345678',
          cc_expiration: '12/25',
          cc_cvv: '123'
        }

        expect(flash[:alert]).to eq("Invalid shards amount selected.")
        expect(response).to redirect_to(buy_shards_user_path(user.username))
      end
    end

    context 'with missing credit card information' do
      it 'shows an alert for missing card info and redirects back' do
        post :process_payment, params: {
          username: user.username,
          shards: 10,
          cc_number: '', # Missing card number
          cc_expiration: '12/25',
          cc_cvv: '123'
        }

        expect(flash[:alert]).to eq("Please fill in all credit card information.")
        expect(response).to redirect_to(buy_shards_user_path(user.username))
      end
    end

    context 'with invalid credit card format' do
      it 'shows an alert for invalid card number format' do
        post :process_payment, params: {
          username: user.username,
          shards: 10,
          cc_number: '12345', # Invalid format
          cc_expiration: '12/25',
          cc_cvv: '123'
        }

        expect(flash[:alert]).to eq("Invalid credit card number.")
        expect(response).to redirect_to(buy_shards_user_path(user.username))
      end
    end
  end
end
