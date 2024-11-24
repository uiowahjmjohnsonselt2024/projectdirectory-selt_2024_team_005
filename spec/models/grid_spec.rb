require 'rails_helper'

RSpec.describe Grid, type: :model do
  describe '#expand_grid' do
    let(:grid) { Grid.create(grid_id: 1, size: 6, name: 'Test Grid') }

    it 'increments the grid size by 1' do
      expect {
        grid.size += 1
        grid.save
        grid.expand_grid
      }.to change { grid.cells.count }.to(49)
    end

    it 'does not duplicate existing cells' do
      existing_cell_ids = grid.cells.pluck(:cell_id)
      grid.size += 1
      grid.save
      grid.expand_grid
      expect(grid.cells.where(cell_id: existing_cell_ids).count).to eq(existing_cell_ids.count)
    end
  end
end
