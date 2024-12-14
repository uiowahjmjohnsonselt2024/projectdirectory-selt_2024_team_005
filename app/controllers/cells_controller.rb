require "openai"
class CellsController < ApplicationController
  before_action :set_cell, only: [ :show, :update ]
  before_action :set_user

  def show
    @cell = Cell.find(params[:id])
    respond_to do |format|
      format.json { render json: @cell }
    end
  end

  def update
    @cell = Cell.find(params[:id])
    # Perform the disaster check whenever a character moves to a new cell
    disaster_message = check_for_disaster(@cell)

    # Respond with the disaster message and any other necessary data (e.g., cell info)
    respond_to do |format|
      format.json { render json: { disaster_message: disaster_message, current_hp: @character.current_hp, cell: @cell } }
    end
  end

  def generate_image
    @cell = Cell.find(params[:id])

    image_url = generate_cell_image(@cell)

    if image_url
      render json: { image_url: image_url }
    else
      render json: { error: "Image generation failed" }, status: :unprocessable_entity
    end
  end

  private

  def generate_cell_image(cell)
    # Insert api key here when not pushing
    client = OpenAI::Client.new(
      # access_token: api_key, # Use this when developing locally
      access_token: ENV["OPENAI_KEY"], # Use this for deployment to Heroku
      log_errors: true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production because it could leak private data to your logs.
    )
    prompt = "A detailed fantasy setting of a location with #{cell.terrain} terrain and #{cell.weather} weather from a wide first person perspective."
    puts prompt

    begin
      response = client.images.generate(
        parameters: {
          prompt: prompt,
          n: 1,
          size: "512x512"
        }
      )
      if response["data"] && response["data"].any?
        return response["data"].first["url"]
      else
        Rails.logger.error "No image data returned from OpenAI."
        return nil
      end
    rescue => e
      Rails.logger.error "Error generating image: #{e.message}"
      return nil
    end
    "https://example.com/generated_image_for_cell_#{cell.id}.png"
  end

  def check_for_disaster(cell)
    disaster_threshold = cell[:disaster_prob]
    @character = Character.find_by(username: @user.username)
    inventory = Inventory.find(@character.inv_id)

    item_ids = inventory.items
    # Find the items in the inventory, using the correct primary key column
    items = Item.where(item_id: item_ids).includes(:itemable)
    # Check if any item is a Disaster Ward
    disaster_ward_item = items.find { |item| item.itemable.name == "Catastrophe Armor" }

    if disaster_ward_item
      puts "ENTERED"
      disaster_threshold = disaster_threshold / 2.0
    end
    if rand < disaster_threshold
      damage = (@character.current_hp * 1/3).round
      @character = Character.find_by(username: @user.username)
      @character.send(:take_disaster_damage, damage)
      @character.save
      # Return the disaster message to the front-end
      "A disaster has occurred! <br> You lost #{damage} HP due to the disaster."
    end
  end

  def set_user
    @user = User.find_by(username: session[:username])
  end

  def set_cell
    @cell = Cell.find(params[:id])
  end
end
