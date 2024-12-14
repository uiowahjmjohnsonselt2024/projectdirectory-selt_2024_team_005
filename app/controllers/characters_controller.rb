# app/controllers/characters_controller.rb
require "openai"
class CharactersController < ApplicationController
  before_action :set_character


  def update
    if @character.update(character_params)
      cell = Cell.find(@character.cell_id)
      mons_prob = cell.mons_prob || 0.0
      random_number = rand
      if random_number <= mons_prob
        # Monster encountered
        monster = generate_monster
        session[:current_monster] = monster  # Store monster stats in session
        puts "session the current monster"
        render json: {
          status: "ok",
          cell_id: @character.cell_id,
          monster: monster,
          weather: cell.weather,
          terrain: cell.terrain
        }, status: :ok
      else
        # No monster encountered
        render json: { status: "ok", cell_id: @character.cell_id }, status: :ok
      end
    else
      render json: { status: "error", errors: @character.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def get_monster_ascii
    weather = params[:weather]
    terrain = params[:terrain]

    # Call an internal method that uses ChatGPT API to generate ASCII
    ascii = generate_monster_ascii(weather, terrain)


    print(ascii)

    if ascii
      # Store the ASCII in session for this encounter or just return it directly
      session[:current_monster_ascii] = ascii
      render json: { status: "ok", ascii: ascii }, status: :ok
    else
      render json: { status: "error", message: "Failed to generate ASCII" }, status: :unprocessable_entity
    end
  end

  def bribe_monster
    # @user is already set in set_character
    if @user.shard_balance >= 10
      @user.shard_balance -= 10
      if @user.save
        session.delete(:current_monster)  # Remove monster from session
        puts "delete the current monster _bribe"
        render json: { status: "ok", shard_balance: @user.shard_balance, message: "Bribe successful" }, status: :ok
      else
        render json: { status: "error", message: "Unable to update shard balance" }, status: :unprocessable_entity
      end
    else
      render json: { status: "error", message: "Not enough shards to bribe the monster" }, status: :unprocessable_entity
    end
  end

  def fight_monster
    monster = session[:current_monster]
    if monster.nil?
      render json: { status: "error", message: "No monster to fight" }, status: :unprocessable_entity and return
    end

    # Get character's equipment
    weapon_item = Item.find_by(item_id: @character.weapon_item_id)
    weapon = weapon_item&.itemable
    character_atk = weapon ? weapon.atk_bonus : 0

    armor_item = Item.find_by(item_id: @character.armor_item_id)
    armor = armor_item&.itemable
    character_def = armor ? armor.def_bonus : 0

    character_hp = @character.current_hp

    # Monster stats
    monster_atk = monster["atk"]
    monster_def = monster["def"]
    monster_hp = monster["hp"]

    # Battle simulation
    battle_log = []
    round = 0

    while character_hp > 0 && monster_hp > 0
      # Character attacks monster
      damage_to_monster = [ character_atk - monster_def, 0 ].max
      monster_hp -= damage_to_monster

      # Monster attacks character
      damage_to_character = [ monster_atk - character_def, 0 ].max
      character_hp -= damage_to_character

      battle_log << {
        round: round += 1,
        character_hp: character_hp,
        monster_hp: monster_hp,
        damage_to_monster: damage_to_monster,
        damage_to_character: damage_to_character
      }
    end

    # Initialize variables
    exp_gain = 0
    level_ups = 0
    shard_reward = 0


    # Determine outcome and update character's stats accordingly
    if character_hp > 0 && monster_hp <= 0
      outcome = "win"
      # Calculate EXP gain
      exp_gain = monster_atk * monster_def
      @character.current_exp += exp_gain
      shard_reward = 1 + (monster_atk + monster_def) / 15

      # Level up if necessary
      while @character.current_exp >= @character.exp_to_level
        @character.current_exp -= @character.exp_to_level
        @character.level += 1
        @character.exp_to_level = calculate_new_exp_to_level(@character.level)
        level_ups += 1
      end
      # Possible shards given to player after a winning battle
      @user.shard_balance += shard_reward
      @character.current_hp = character_hp
      @character.save
      @user.save
    elsif character_hp <= 0 && monster_hp > 0
      outcome = "lose"
      @character.current_hp = 0
      @character.save
    elsif character_hp <= 0 && monster_hp <= 0
      outcome = "draw"
      @character.current_hp = 0
      @character.save
    end

    # Remove monster from session
    session.delete(:current_monster)
    puts "session the current monster _fight"

    render json: {
      status: "ok",
      outcome: outcome,
      battle_log: battle_log,
      exp_gain: exp_gain,
      shard_reward: shard_reward,
      level_ups: level_ups,
      current_exp: @character.current_exp,
      exp_to_level: @character.exp_to_level,
      level: @character.level
    }, status: :ok
  end

  def teleport
    teleport_cost = params[:cost].to_i
    new_cell_id = params[:cellId].to_i

    # Check if the character exists
    if @character.nil?
      render json: { status: "error", message: "Character not found" }, status: :not_found
      return
    end

    # Check if the character has enough shards
    if @user.shard_balance >= 5
      # Deduct the shards and update the cell_id
      @user.shard_balance -= 5
      @character.cell_id = new_cell_id
      @user.save

      if @character.save
        # Return updated data
        render json: {
          status: "ok",
          shard_balance: @user.shard_balance,
          new_cell_id: @character.cell_id
        }
      else
        render json: { status: "error", message: "Failed to update character" }, status: :unprocessable_entity
      end
    elsif @user.shard_balance < 5
      flash[:notice] = "Not enough shards to teleport."
      render json: { status: "error", message: "Not enough shards" }, status: :bad_request
    end
  end


  private
  def calculate_new_exp_to_level(level)
    # Example: EXP required increases by 100 each level
    level * 100
  end

  def set_character
    @user = User.find_by(username: session[:username])
    if @user.nil?
      render json: { status: "error", message: "User not found" }, status: :not_found and return
    end

    @character = Character.find_by(username: @user.username)
    if @character.nil?
      render json: { status: "error", message: "Character not found" }, status: :not_found and return
    end
  end

  def character_params
    params.require(:character).permit(:cell_id, :character_name)
  end

  def generate_monster
    atk = rand(5..15)   # Random attack between 5 and 15
    def_stat = rand(5..15)  # Random defense between 5 and 15
    hp = rand(10..20)  # Random HP between 10 and 20
    { atk: atk, def: def_stat, hp: hp }
  end

  def generate_monster_ascii(weather, terrain)
        # This method should call the ChatGPT API and return ASCII monster based on weather and terrain.
        # prompt = "Given a weather condition '#{weather}' and terrain '#{terrain}', generate a single ASCII art monster..."
        # response = ChatGPTApi.call(prompt)
        # return response.ascii_monster
        #
        # For demonstration, returning a static ASCII:
        # ascii = askai("Returns ONLY the ASCII code (15 lines at most) to draw an RPG monster with #{terrain} and #{weather} weather. No explanations necessary.")
        ascii = "
               ___
             .-'   `-.
            /         \
           |           |
           |   O   O   |
           |     ^     |
           |    '-'    |
            \         /
             `._   _.'
                `-'
               /   \
           ___|_____|___
         /    \   /    \
        /      \ /      \
       |   ____|____    |
       |  /          \   |
       | /            \  |
       |/______________\_|
       /  |  |    |  |  \
      /   |  |    |  |   \
     /____|__|____|__|____\

       ~~~~~~~~~~~~~~~
       ~   ~ ~ ~ ~ ~ ~ ~
        ~ ~ ~ ~ ~ ~ ~ ~ ~
           ~ ~ ~ ~ ~ ~

    "
    ascii
  end

  def askai(prompt)
    api_key=" "
    client = OpenAI::Client.new(
      access_token: api_key,
      log_errors: true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production because it could leak private data to your logs.
    )
    print("MODEL LIST:", client.models.list)
    response = client.chat(
      parameters: {
        model: "gpt-4-turbo", # Required.
        messages: [ { role: "user", content: prompt } ], # Required.
        temperature: 0.7
      }
    )
    response.dig("choices", 0, "message", "content")
  end
end
