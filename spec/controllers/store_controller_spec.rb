require 'rails_helper'

RSpec.describe StoreController, type: :controller do
  let(:mock_user) { double('User', username: 'testuser', shard_balance: 100) }
  let(:mock_character) { double('Character', username: 'testuser', inv_id: 1) }
  let(:mock_grid) { double('Grid', grid_id: 1, name: 'Test Grid', cost: 50) }
  let(:mock_items) { [ double('Item', item_id: 1, cost: 10, name: 'Test Item') ] }
  let(:mock_inventory) { double('Inventory', inv_id: 1, add_item: true, save: true) }

  before do
    # Stubs for User and Character
    allow(User).to receive(:find_by!).with(username: 'testuser').and_return(mock_user)
    allow(Character).to receive(:find_by).with(username: 'testuser').and_return(mock_character)
    allow(Item).to receive(:all).and_return(mock_items)

    # Stubbing Grid.find_by to accept the string as a parameter
    allow(Grid).to receive(:find_by).with(grid_id: "1").and_return(mock_grid)
    allow(Grid).to receive(:all).and_return([ mock_grid ])

    # Mock Inventory behavior
    allow(Inventory).to receive(:find).and_return(mock_inventory)
    allow(mock_inventory).to receive(:add_item).and_return(true)
    allow(mock_inventory).to receive(:save).and_return(true)
  end

  describe "GET #shards_store" do
    context "when character exists" do
      it "assigns @user, @character, @grid, @items" do
        get :shards_store, params: { username: 'testuser', id: "1" }

        expect(assigns(:user)).to eq(mock_user)
        expect(assigns(:character)).to eq(mock_character)
        expect(assigns(:grid)).to eq(mock_grid)
        expect(assigns(:items)).to eq(mock_items)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when character does not exist" do
      before do
        allow(Character).to receive(:find_by).with(username: 'testuser').and_return(nil)
      end

      it "assigns @character as nil" do
        get :shards_store, params: { username: 'testuser', id: "1" }

        expect(assigns(:user)).to eq(mock_user)
        expect(assigns(:character)).to be_nil
        expect(assigns(:grid)).to eq(mock_grid)
        expect(assigns(:items)).to eq(mock_items)
        expect(response).to have_http_status(:ok)
      end
    end
  end
  end
