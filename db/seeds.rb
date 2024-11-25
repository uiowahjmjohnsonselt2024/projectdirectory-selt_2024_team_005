# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Correct seed example
@user = User.find_or_create_by!(username: 'abcd', email: 'student@uiowa.edu', shard_balance: 100000) do |user|
  user.password = '54321'
  user.password_confirmation = '54321'
end
@grid = Grid.find_or_create_by!(grid_id: 1, name: 'earth')
@grid2 = Grid.find_or_create_by!(grid_id: 2, name: 'moon')
# Tips: No need to instantiate a cell, since grid will generate cells after creating automatically!
# @cell = Cell.find_or_create_by!(cell_id: 1, cell_loc: '1A', mons_prob: 0.3, disaster_prob: 0.3, weather: 'Sunny',
#                                 terrain: 'desert', has_store: true, grid_id: @grid.grid_id)
@first_cell = @grid.cells.order(:cell_id).first
@item1 = Item.find_or_create_by!(item_id: 1, name: 'Mediocre Sword', category: 'Weapon', cost: 1)
@item2 = Item.find_or_create_by!(item_id: 2, name: 'Health Pack', category: 'Support', cost: 1)

@inventory = Inventory.find_or_create_by!(inv_id: 1, items: [ @item1, @item2 ])
# Tips: We can't directly specify the cell_id as @cell.cell_id, cause cells are generated after creating grid
# For now just set it as 1000 for simple, this should be modified as we need store characters last location
@character = Character.find_or_create_by!(username: @user.username, character_name: 'Hawkeye', health: 100,
                                          experience: 0, level: 1,  grid_id: @grid.grid_id,
                                          cell_id:  @first_cell.cell_id, inv_id: @inventory.inv_id)

@inventory2 = Inventory.find_or_create_by!(inv_id: 2, items: [ @item1, @item2 ])
@user2 = User.find_or_create_by!(username: 'abcd2', email: 'student2@uiowa.edu', shard_balance: 20) do |user|
  user.password = '54321'
  user.password_confirmation = '54321'
end
@character2 = Character.find_or_create_by!(username: @user2.username, character_name: 'Hawkeye2',
                                           health: 100, experience: 0, level: 1, grid_id: @grid.grid_id,
                                           cell_id:  @first_cell.cell_id, inv_id: @inventory.inv_id)
