require 'spec_helper'
require 'rails_helper'

describe InventoryController, type: :controller do
  let(:fake_grid) { create(:grid, name: 'test') }
  let(:first_cell) { fake_grid.cells.order(:cell_id).first }
  let(:item1) { create(:item, itemable: create(:weapon, name: 'Wooden Sword', atk_bonus: 1)) }
  let(:item2) { create(:item, itemable: create(:armor, name: 'Leather Armor', def_bonus: 1)) }
  let(:item3) { create(:item, itemable: create(:weapon, name: 'Iron Sword', atk_bonus: 5)) }
  let(:item4) { create(:item, itemable: create(:armor, name: 'Bronze Armor', def_bonus: 4)) }
  let(:item5) { create(:item, itemable: create(:potion, name: 'Health Potion XS', hp_regen: 10)) }
  let(:inventory) { create(:inventory, items: [item3.item_id, item4.item_id, item5.item_id]) }
  let(:user) { create(:user, username: 'fake_user', email: 'fake_user@uiowa.edu', password: '54321') }
  let(:character) do
    create(:character,
           username: user.username,
           character_name: 'test',
           level: 1,
           grid_id: fake_grid.grid_id,
           cell_id: first_cell.cell_id,
           inv_id: inventory.inv_id,
           weapon_item_id: item1.item_id,
           armor_item_id: item2.item_id
    )
  end

  before(:each) do
    allow(controller).to receive(:current_user).and_return(user)
    allow(user).to receive(:character).and_return(character)
    allow(Inventory).to receive(:find_by).and_return(inventory)
  end

  describe 'POST #use_item' do
    context 'when the item is a Potion' do
      before do
        character.update(current_hp: 100)
        post :use_item, params: { index: 2 }
      end
      it 'replenishes character HP' do
        character.reload
        expect(character.current_hp).to eq([character.max_hp, character.current_hp + item5.hp_regen].min)
      end

      it 'removes the item from the inventory' do
        inventory.reload
        expect(inventory.items[2]).to eq(nil)
      end
    end

    context 'when the item is a Weapon' do
      before do
        post :use_item, params: { index: 0 }
      end

      it 'equips the weapon to the character' do
        character.reload
        expect(character.weapon_item_id).to eq(item3.item_id)
      end

      it 'replaces the weapon in the inventory with the previously equipped weapon' do
        inventory.reload
        expect(inventory.items[0]).to eq(item1.item_id)
      end
    end

    context 'when the item is an Armor' do
      before do
        post :use_item, params: { index: 1 }
      end

      it 'equips the armor to the character' do
        character.reload
        expect(character.armor_item_id).to eq(item4.item_id)
      end

      it 'replaces the armor in the inventory with the previously equipped armor' do
        inventory.reload
        expect(inventory.items[1]).to eq(item2.item_id)
      end
    end
  end
  describe 'POST #discard_item' do
    it 'should remove the item from the character\s inventory' do
      post :discard_item, params: { index: 0 }
      inventory.reload
      expect(inventory.items).to eq( [item4.item_id, item5.item_id, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil] )
    end
  end
end