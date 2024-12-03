require 'rails_helper'

RSpec.describe StoreController, type: :controller do
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

  describe 'GET #shards_store' do
    it 'returns a successful response' do
      get :shards_store, params: { username: user.username, id: grid.id }
      expect(response).to have_http_status(:success)
    end

    it 'renders the shards_store template' do
      get :shards_store, params: { username: user.username, id: grid.id }
      expect(response).to render_template(:shards_store)
    end
  end

  describe 'POST #buy_item' do
    context 'when the user has enough shards' do
      it 'successfully buys an item and updates the user balance' do
        post :buy_item, params: { username: user.username, id: weapon.id }

        # Check flash message and redirection
        expect(flash[:notice]).to eq('Item purchased successfully.')
        expect(response).to redirect_to(store_path)

        # Reload user and check shard balance update
        user.reload
        expect(user.shard_balance).to eq(90)  # 100 - 10 (weapon cost)
      end
    end

    context 'when the user does not have enough shards' do
      before { user.update(shard_balance: 5) }  # Set user balance to 5

      it 'shows an alert and does not allow the purchase' do
        post :buy_item, params: { username: user.username, id: item.id }

        expect(flash[:alert]).to eq('Insufficient balance to purchase this item.')
        expect(response).to redirect_to(store_path)

        # Ensure the user's shard balance remains the same
        user.reload
        expect(user.shard_balance).to eq(5)
      end
    end
  end
  end
