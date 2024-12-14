[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/aHTqYFve)
# README
## SELT 2024 Group 5 Final Project: Shards of the Grid with SaaS principles
Shards of the Grid is a multiplayer game where players can interact with their friends, fight monster, encounter disasters, teleport worlds, and improve their weaponry and skills. It utilizes AI to generate imaging for the playing grids. 

# Ruby Version: 
rbenv 3.3.0 

# How to Run:
1. `rake db:reset db:migrate db:schema:load db:seed ` to set up the database
2. Uncomment out this line `access_token: api_key,` in cells_controller.rb and characters_controller.rb and comment out `access_token: ENV["OPENAI_KEY"],` to be able to see/fight monsters
3. Then if want images generated, add in api token for open ai generation
4. Run rails server -p 3000 -b 0.0.0.0 to launch server
5. Login using the given login for classes or username: abcd and password: 54321

# Running Test Suite
Run tests using rspec to run all tests and add route if want to run specific
Also have cucumber tests which can be run with normal commands 

# Features 
- Users can buy shards and use currency conversions to be able to do so
- Users can buy weapons, armor, and potions to better defend their character when on the grid
- Users can also buy worlds and teleport between their worlds to change up the playing locations
- When on a playing grid, users can change their armor and weapons as well as use potions to increase hp
- On a grid, players can teleport to different spots on the grid to limit possible encounters
- Players may encounter natural disasters, which happen at random, and monsters, which they can chose to fight or bribe and run from. If they choose to fight, then their are metrics to determine who wins based on the monster and the user's armor/weapons.
    - Based on winning/losing the player will either gain exp or lose health
    - If hp reaches 0, the user will reach game over which will regenerate them with 200 hp
- Users can also play with their friends on the same grid and move around while they also move
- Users can communicate with people just in their grid as well as with people in the entire game
- Users can also expand their grid if they feel like they would like the grid to be larger. The largest grid they can have is a 12x12.
- Forgot password functionality sends email to user to reset password
- New users who create accounts will be defaulted with basic armor, weapons, and a health potion as well as only having access to Earth.

# Contributors 
This project was completed as part of a final project for SELT Fall 2024. The group members are: Anna Davis, Jingming Liang, Liam Wells, Yiyang Shen, and Rodrigo Medina 
   
