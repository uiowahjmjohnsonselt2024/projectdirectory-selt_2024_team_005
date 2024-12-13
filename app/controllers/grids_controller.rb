# app/controllers/grids_controller.rb
class GridsController < ApplicationController
  before_action :set_user

  def index
    @grids = Grid.all
    @grids = Grid.all.select do |grid|
      user_grid_visibility = UserGridVisibility.find_by(username: @user.username, grid_id: grid.grid_id)
      user_grid_visibility && user_grid_visibility.visibility >= 6
    end
  end

  def new
    @grid = Grid.new
  end

  def create
    @grid = Grid.new(grid_params)
    if @grid.save
      flash[:notice] = "Successfully generate a new grid!"
      redirect_to @grid
    else
      flash[:notice] = "Unsuccessfully generate a new grid!"
      render :new
    end
  end

  def background
    grid = Grid.find_by(id: params[:id])

    if grid
      # Replace this with actual logic to fetch the background image URL for the grid
      background_image_url = helpers.asset_path("test-grid-background.jpg")
      render json: { background_image_url: background_image_url }, status: :ok
    else
      render json: { error: "Grid not found" }, status: :not_found
    end
  end


  def destroy
    @grid = Grid.find_by(grid_id: params[:id])
    flash[:notice] = "Wait for codes"
    redirect_to grids_path
  end

  def edit
    @grid = Grid.find_by(grid_id: params[:id])
    flash[:alert] = "Wait for codes"
    redirect_to grids_path
  end

  def show
    @grid = Grid.find_by(grid_id: params[:id])
    if @grid.nil?
      flash[:error] = "Grid not found"
      redirect_to grids_path
    else
      @visibility = @user.visibility_for(@grid)
      numbers = (0...@visibility).to_a.map(&:to_s)
      numbers_pattern = numbers.join("|")
      pattern = "^R(#{numbers_pattern})C(#{numbers_pattern})$"
      @cells = @grid.cells.where("cell_loc ~ ?", pattern).order(:cell_id)
      @grid_matrix = @cells.each_slice(@visibility).to_a
      @character = Character.find_by(username: @user.username)
      @weapon = Item.find_by(item_id: @character.weapon_item_id)
      @armor = Item.find_by(item_id: @character.armor_item_id)
      @inventory = Inventory.find_by(inv_id: @character.inv_id)

      @background_image_url = helpers.asset_url("test-grid-background.jpg")
    end
  end

  def expand
    @grid = Grid.find_by(grid_id: params[:id])
    if @grid.nil?
      flash[:error] = "Grid not found"
      redirect_to grids_path
    else
      current_visibility = @user.visibility_for(@grid)
      if current_visibility < Grid::GRID_SIZE
        if @user.shard_balance >= 10
          @user.shard_balance -= 10
          @user.save
          new_visibility = current_visibility + 1
          @user.set_visibility_for(@grid, new_visibility)
          flash[:notice] = "Grid expanded successfully"
        else
          flash[:alert] = "Not enough shards to expand the grid"
        end
      else
        flash[:alert] = "Maximum grid size reached"
      end
      redirect_to @grid
    end
  end

  def go_to
    @grid = Grid.find_by(grid_id: params[:id])
    if @grid.nil?
      flash[:error] = "Grid not found"
      redirect_to grids_path and return
    end

    # Ensure we have a logged-in user and character
    if @user.nil? || @character.nil?
      flash[:alert] = "No user or character found in session"
      redirect_to grids_path and return
    end

    # Find the cell with cell_loc = "R0C0" for this grid
    starting_cell = @grid.cells.find_by(cell_loc: "R0C0")
    if starting_cell.nil?
      flash[:error] = "Starting cell (R0C0) not found for this grid"
      redirect_to grids_path and return
    end

    # Update character
    @character.update(grid_id: @grid.grid_id, cell_id: starting_cell.cell_id)

    flash[:notice] = "You have moved to the #{@grid.name} grid."
    redirect_to grid_path(@grid)
  end



  private

  def set_grid
    @grid = Grid.find_by(grid_id: params[:id])
  end
  def grid_params
    params.require(:grid).permit(:grid_id, :name)
  end

  def set_user
    @user = User.find_by(username: session[:username])
    if @user.nil?
      Rails.logger.info "No user found in session."
    else
      Rails.logger.info "User found: #{@user.username}"
      @character = Character.find_by(username: @user.username)
    end
  end
end
