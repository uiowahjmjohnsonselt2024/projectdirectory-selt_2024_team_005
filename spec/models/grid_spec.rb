require 'rails_helper'

RSpec.describe Grid, type: :model do
  describe '#generate_cells' do
    let(:grid) { Grid.new(grid_id: 1) }
    let(:cell_attributes) do
      {
        cell_id: instance_of(Integer),
        cell_loc: instance_of(String),
        mons_prob: 0.18,
        disaster_prob: 0.15,
        weather: instance_of(String),
        terrain: instance_of(String),
        has_store: satisfy { |value| [true, false].include?(value) },
        grid_id: grid.grid_id,
        created_at: instance_of(ActiveSupport::TimeWithZone),
        updated_at: instance_of(ActiveSupport::TimeWithZone)
      }
    end

    before do
      allow(Cell).to receive(:insert_all)
    end

    it 'generates the correct number of cells' do
      grid.generate_cells
      expect(Cell).to have_received(:insert_all) do |cells|
        expect(cells.size).to eq(Grid::GRID_SIZE * Grid::GRID_SIZE)
      end
    end

    it 'ensures each cell has the required attributes' do
      grid.generate_cells
      expect(Cell).to have_received(:insert_all) do |cells|
        cells.each do |cell|
          expect(cell).to match(cell_attributes)
        end
      end
    end

    context 'when an error occurs during insertion' do
      before do
        allow(Cell).to receive(:insert_all).and_raise(ActiveRecord::RecordInvalid.new("Test error"))
        allow(Rails.logger).to receive(:error)
      end
    end
  end

end