class CellsController < ApplicationController
  before_action :set_cell, only: [ :show, :update ]

  def show
    @cell = Cell.find(params[:id])
    respond_to do |format|
      format.json { render json: @cell }
    end
  end

  def update
    # Assuming you have logic here to move the character to a new cell
    check_for_disaster
  end

  private
  def check_for_disaster
    current_cell = @cells.first
    disaster_threshold = current_cell[:disaster_prob]
    if rand < disaster_threshold
      puts rand
      puts disaster_threshold
      puts "NUMBERS HERE"
      damage = 20
      @character.send(:take_disaster_damage, damage)

      flash[:alert] = "A disaster has occurred! You lost #{damage} HP due to the disaster."
    end
  end

  def set_cell
    @cell = Cell.find(params[:id])
  end
end
