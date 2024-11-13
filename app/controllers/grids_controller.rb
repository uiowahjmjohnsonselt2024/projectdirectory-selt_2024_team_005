class GridsController < ApplicationController

  # before_action :authenticate_user!  # Use Devise to ensure that Logged

  def new

  end

  def create
    @grid = Grid.create
    @current_cell = @grid.cells.find_by(row: 0, col: 0)
  end

  def show
    @grid = Grid.find(params[:id])
  end

  def move
    # Suppose that current_position is stored in session
    current_position = session[:current_position] || { row: 0, col: 0 }
    # Get direction from request
    direction = params[:direction]

    case direction
    when 'left'
      current_position[:col] -= 1 if current_position[:col] > 0
    when 'right'
      current_position[:col] += 1 if current_position[:col] < 5
    end

    # Update session
    session[:current_position] = current_position
    redirect_to grid_path
  end

end
