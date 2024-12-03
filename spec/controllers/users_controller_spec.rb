require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  let(:armor) { Armor.create!(name: 'Iron Armor', description: 'Basic armor', icon: 'armor_icon.png', def_bonus: 5) }
  let(:weapon) { Weapon.create!(name: 'Sword', description: 'A sharp sword', icon: 'sword_icon.png', atk_bonus: 10) }

  let(:user) {
    User.create!(username: 'awesomehawkeye',
                 email: 'awesome@uiowa.edu',
                 password_digest: BCrypt::Password.create('12345').to_s,
                 shard_balance: 0)
  }

  let(:grid) {
    Grid.create!(name: 'Test Grid')
  }

  let(:inventory) {
    Inventory.create!(items: [])
  }

  let(:cell) {
    Cell.create!(cell_loc: '1A',
                 grid_id: grid.id,
                 weather: 'Sunny',
                 terrain: 'desert',
                 has_store: true)
  }

  let(:character) {
    Character.create!(username: user.username,
                      character_name: 'Hawkeye',
                      level: 1,
                      grid_id: grid.id,
                      cell_id: cell.cell_id,
                      inv_id: inventory.inv_id,
                      current_hp: 100,
                      max_hp: 100,
                      current_exp: 0,
                      exp_to_level: 100,
                      weapon_item_id: weapon.id,
                      armor_item_id: armor.id)
  }

  before do
    session[:username] = user.username  # Set the session for the user
  end


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

      # it 'assigns the correct character to @character' do
      #   get :show, params: { username: user.username }
      #   expect(assigns(:character)).to eq(character)
      # end

      it 'renders the show template' do
        get :show, params: { username: user.username }
        expect(response).to render_template(:show)
      end
    end

    context 'when the user does not exist' do
      it 'raises ActiveRecord::RecordNotFound' do
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

      it 'assigns the correct user and character' do
        get :buy_shards, params: { username: user.username }
        expect(assigns(:user)).to eq(user)
        #expect(assigns(:character)).to eq(character)
      end

      it 'assigns exchange rates for all currencies' do
        allow(user).to receive(:get_exchange_rate).and_return(1.0)
        get :buy_shards, params: { username: user.username }
        expect(assigns(:exchange_rates)).to be_a(Hash)
        expect(assigns(:exchange_rates).keys).to match_array(%w[USD EUR GBP JPY AUD CAD CHF CNY SEK NZD])
      end
    end
  end

  describe 'POST #process_payment' do
    # context 'with valid inputs' do
    #   it 'processes the payment and updates shard balance' do
    #     allow(user).to receive(:get_exchange_rate).and_return(1.0)
    #     post :process_payment, params: {
    #       username: user.username,
    #       amount: 100.0,
    #       currency: 'USD',
    #       cc_number: '1234567812345678',
    #       cc_expiration: '12/23',
    #       cc_cvv: '123'
    #     }
    #     expect(flash[:notice]).to eq("Successfully purchased 100 shards.")
    #     expect(response).to redirect_to(user_path(user.username))
    #     user.reload
    #     expect(user.shard_balance).to eq(100)
    #   end
    # end

    context 'with invalid inputs' do
      it 'shows an alert for invalid amount' do
        post :process_payment, params: {
          username: user.username,
          amount: -100.0,
          currency: 'USD',
          cc_number: '1234567812345678',
          cc_expiration: '12/23',
          cc_cvv: '123'
        }
        expect(flash[:alert]).to eq("Please enter a valid amount.")
        expect(response).to redirect_to(buy_shards_user_path(user.username))
      end

      it 'shows an alert for missing credit card info' do
        post :process_payment, params: {
          username: user.username,
          amount: 100.0,
          currency: 'USD',
          cc_number: '',
          cc_expiration: '',
          cc_cvv: ''
        }
        expect(flash[:alert]).to eq("Please fill in all credit card information.")
        expect(response).to redirect_to(buy_shards_user_path(user.username))
      end

      it 'shows an alert for invalid credit card number' do
        post :process_payment, params: {
          username: user.username,
          amount: 100.0,
          currency: 'USD',
          cc_number: 'invalid',
          cc_expiration: '12/23',
          cc_cvv: '123'
        }
        expect(flash[:alert]).to eq("Invalid credit card number.")
        expect(response).to redirect_to(buy_shards_user_path(user.username))
      end

      it 'shows an alert for invalid expiration date' do
        post :process_payment, params: {
          username: user.username,
          amount: 100.0,
          currency: 'USD',
          cc_number: '1234567812345678',
          cc_expiration: 'invalid',
          cc_cvv: '123'
        }
        expect(flash[:alert]).to eq("Invalid expiration date format.")
        expect(response).to redirect_to(buy_shards_user_path(user.username))
      end

      it 'shows an alert for invalid CVV' do
        post :process_payment, params: {
          username: user.username,
          amount: 100.0,
          currency: 'USD',
          cc_number: '1234567812345678',
          cc_expiration: '12/23',
          cc_cvv: '12'
        }
        expect(flash[:alert]).to eq("Invalid CVV.")
        expect(response).to redirect_to(buy_shards_user_path(user.username))
      end
    end
  end

  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end
end
