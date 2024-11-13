# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
@user = User.create!(username: 'abcd', email: 'student@uiowa.edu', password_digest: '54321')
@grid = Grid.create!(grid_id: 1, name: 'earth')
@cell = Cell.create!(cell_id: 1, cell_loc: '1A', mons_prob: 0.3, disaster_prob: 0.3, weather: 'Sunny',
                     terrain: 'desert', has_store: true, grid_id: @grid.grid_id)
@item1 = Item.create!(item_id: 1, name: 'thingy', category: 'sword', cost: 1)
@item2 = Item.create!(item_id: 2, name: 'stuff', category: 'shield', cost: 1)

@inventory = Inventory.create!(inv_id: 1, items: [ @item1, @item2 ])
@character = Character.create!(username: @user.username, character_name: 'Hawkeye',
                               shard_balance: 0, health: 100, experience: 0, level: 1,
                               grid_id: @grid.grid_id, cell_id: @cell.cell_id, inv_id: @inventory.inv_id)

@inventory2 = Inventory.create!(inv_id: 2, items: [ @item1, @item2 ])
@user2 = User.create!(username: 'abcd2', email: 'student2@uiowa.edu', password_digest: '54321')
@character2 = Character.create!(username: @user2.username, character_name: 'Hawkeye2',
                               shard_balance: 0, health: 100, experience: 0, level: 1,
                               grid_id: @grid.grid_id, cell_id: @cell.cell_id, inv_id: @inventory.inv_id)
