require 'rails_helper'

RSpec.describe GridsController, type: :controller do
  describe 'PATCH #expand' do
    let(:grid) { Grid.create(grid_id: 1, size: 6, name: 'Test Grid') }

    it 'locates the requested grid' do
      patch :expand, params: { id: grid.grid_id }
      expect(assigns(:grid)).to eq(grid)
    end

    context 'with valid grid' do
      it 'increments the grid size' do
        expect {
          patch :expand, params: { id: grid.grid_id }
          grid.reload
        }.to change { grid.size }.by(1)
      end

      it 'calls expand_grid method' do
        expect_any_instance_of(Grid).to receive(:expand_grid)
        patch :expand, params: { id: grid.grid_id }
      end

      it 'redirects to the grid show page' do
        patch :expand, params: { id: grid.grid_id }
        expect(response).to redirect_to(grid_path(grid))
      end

      it 'sets a success flash message' do
        patch :expand, params: { id: grid.grid_id }
        expect(flash[:notice]).to eq('Grid expanded successfully')
      end
    end

    context 'with invalid grid' do
      it 'redirects to grids index with error message' do
        patch :expand, params: { id: 'non-existent-id' }
        expect(response).to redirect_to(grids_path)
        expect(flash[:error]).to eq('Grid not found')
      end
    end
  end
end
