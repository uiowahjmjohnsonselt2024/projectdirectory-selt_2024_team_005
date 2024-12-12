require 'rails_helper'

RSpec.describe GridsController, type: :controller do
  let(:user) { instance_double(User, username: 'test_user', shard_balance: 20, visibility_for: 5, set_visibility_for: true) }
  let(:grid) { instance_double(Grid, grid_id: 1, name: 'Test Grid', cells: double(:cells)) }
  let(:character) { instance_double(Character, username: 'test_user', weapon_item_id: 1, armor_item_id: 2, inv_id: 3, update: true) }
  let(:item) { instance_double(Item, item_id: 1, name: 'Sword') }
  let(:inventory) { instance_double(Inventory, inv_id: 3) }

  before do
    allow(User).to receive(:find_by).and_return(user)
    allow(Character).to receive(:find_by).and_return(character)
    allow(Item).to receive(:find_by).and_return(item)
    allow(Inventory).to receive(:find_by).and_return(inventory)
  end

  describe 'GET #index' do
    let(:user_grid_visibility) { instance_double(UserGridVisibility, visibility: 6) }

    before do
      allow(Grid).to receive(:all).and_return([grid])
      allow(UserGridVisibility).to receive(:find_by).and_return(user_grid_visibility)
    end

    it 'assigns grids visible to the user' do
      get :index
      expect(assigns(:grids)).to eq([grid])
    end
  end

  # describe 'POST #create' do
  #   let(:grid_params) { { grid_id: 1, name: 'New Grid' } }
  #
  #   before do
  #     allow(Grid).to receive(:new).and_return(grid)
  #     allow(grid).to receive(:save).and_return(true)
  #     allow(grid).to receive(:to_model).and_return(grid)
  #   end
  #
  #   it 'creates a new grid and redirects' do
  #     post :create, params: { grid: grid_params }
  #     expect(flash[:notice]).to eq('Successfully generate a new grid!')
  #     expect(response).to redirect_to(grid)
  #   end
  # end

  describe 'GET #show' do
    let(:cell) { instance_double(Cell, cell_loc: 'R0C0', cell_id: 1) }

    before do
      allow(Grid).to receive(:find_by).and_return(grid)
      allow(grid.cells).to receive(:where).and_return(double(:relation, order: [cell]))
    end

    it 'assigns grid details and cells' do
      get :show, params: { id: 1 }
      expect(assigns(:grid)).to eq(grid)
      expect(assigns(:cells)).to eq([cell])
      expect(assigns(:grid_matrix)).to eq([[cell]])
    end
  end

  # describe 'PATCH #expand' do
  #   before do
  #     allow(Grid).to receive(:find_by).and_return(grid)
  #     allow(user).to receive(:visibility_for).and_return(5)
  #     allow(user).to receive(:shard_balance).and_return(20)
  #     allow(user).to receive(:shard_balance=).and_return(10)
  #     allow(user).to receive(:save).and_return(true)
  #   end
  #
  #   it 'expands grid visibility and deducts shards if conditions are met' do
  #     patch :expand, params: { id: 1 }
  #     expect(flash[:notice]).to eq('Grid expanded successfully')
  #     expect(user).to have_received(:save)
  #     expect(user).to have_received(:set_visibility_for).with(grid, 6)
  #   end
  # end

  describe 'POST #go_to' do
    let(:starting_cell) { instance_double(Cell, cell_loc: 'R0C0', cell_id: 1) }

    before do
      allow(Grid).to receive(:find_by).and_return(grid)
      allow(grid.cells).to receive(:find_by).and_return(starting_cell)
    end

    it 'updates character location to starting cell' do
      post :go_to, params: { id: 1 }
      expect(character).to have_received(:update).with(grid_id: grid.grid_id, cell_id: starting_cell.cell_id)
      expect(flash[:notice]).to eq("You have moved to the #{grid.name} grid.")
    end
  end
end
