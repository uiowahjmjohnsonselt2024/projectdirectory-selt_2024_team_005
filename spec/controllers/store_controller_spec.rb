require 'rails_helper'

RSpec.describe StoreController, type: :controller do
  let(:grid) { Grid.create!(name: 'Test Grid', size: 10) }
  let(:cell) { Cell.create!(id: 1, grid_id: grid.id, cell_loc: '1A', mons_prob: 0.3, disaster_prob: 0.3, weather: 'Sunny', terrain: 'desert', has_store: true) }
  let(:inventory) { Inventory.create!(inv_id: 1) }
  let(:user) { User.create!(username: 'awesomehawkeye', email: 'awesome@uiowa.edu', shard_balance: 50, password_digest: '12345') }
  let(:character) { Character.create!(username: user.username, character_name: 'Hawkeye', level: 1, grid_id: grid.id, cell_id: cell.id, inv_id: inventory.id) }
  let(:weapon) { Weapon.create(name:'Test Item', atk_bonus: 1) }
  let(:item) { Item.create!(itemable: weapon, cost: 10) }


  before do
    user
    inventory
    grid
    cell
    character
    item
  end

  describe 'GET #shards_store' do
    it 'returns a successful response' do
      get :shards_store, params: { username: user.username }
      expect(response).to have_http_status(:success)
    end

    it 'assigns the requested user to @user' do
      get :shards_store, params: { username: user.username }
      expect(assigns(:user)).to eq(user)
    end

    it 'assigns the requested character to @character' do
      get :shards_store, params: { username: user.username }
      expect(assigns(:character)).to eq(character)
    end

    it 'assigns all items to @items' do
      get :shards_store, params: { username: user.username }
      expect(assigns(:items)).to include(item)
    end
  end


  describe 'POST #buy_item' do
    context 'when the character has sufficient shard balance' do
      it 'deducts shards and adds item to inventory' do
        post :buy_item, params: { username: user.username, id: item.id }

        user.reload
        character.reload
        inventory.reload

        expect(user.shard_balance).to eq(40)
        expect(inventory.items).to include(item.item_id)
        expect(flash[:notice]).to eq("Item purchased successfully.")
        expect(response).to redirect_to(store_path)
      end
    end

    context 'when the character has insufficient shard balance' do
      before { user.update(shard_balance: 5) }

      it 'does not allow purchase and shows an alert' do
        post :buy_item, params: { username: user.username, id: item.id }

        expect(flash[:alert]).to eq("Insufficient balance to purchase this item.")
        expect(response).to redirect_to(store_path)
      end
    end

    context 'when the item does not exist' do
      it 'raises an ActiveRecord::RecordNotFound error' do
        expect {
          post :buy_item, params: { username: user.username, id: 99999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the character does not have enough shards' do
      before { user.update(shard_balance: 0) }

      it 'shows an alert and does not make the purchase' do
        post :buy_item, params: { username: user.username, id: item.id }

        expect(flash[:alert]).to eq("Insufficient balance to purchase this item.")
        expect(response).to redirect_to(store_path)
      end
    end

    context 'when the purchase is successful but saving fails' do
      before do
        allow_any_instance_of(Character).to receive(:save).and_return(false)
      end

      it 'shows an alert and does not purchase the item' do
        post :buy_item, params: { username: user.username, id: item.id }

        expect(flash[:alert]).to eq("Unable to purchase item.")
        expect(response).to redirect_to(store_path)
      end
    end
  end
end
