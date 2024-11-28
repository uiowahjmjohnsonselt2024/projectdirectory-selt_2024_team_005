class GridsController < ApplicationController
  before_action :set_user

  def index
    @grids = Grid.all
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
    @world = World.find_by(grid_id: params[:id])
    if @world.nil?
      flash[:alert] = "World not found"
      redirect_to grids_path
    end
    if @grid.nil?
      flash[:error] = "Grid not found"
      redirect_to grids_path
    else
      @visibility = current_user.visibility_for(@grid)
      numbers = (0...@visibility).to_a.map(&:to_s)
      numbers_pattern = numbers.join("|")
      pattern = "^R(#{numbers_pattern})C(#{numbers_pattern})$"
      @cells = @grid.cells.where("cell_loc ~ ?", pattern).order(:cell_id)
      @grid_matrix = @cells.each_slice(@visibility).to_a
      @character = Character.find_by(username: @user.username)
    end
  end

  def expand
    @grid = Grid.find_by(grid_id: params[:id])
    if @grid.nil?
      flash[:error] = "Grid not found"
      redirect_to grids_path
    else
      current_visibility = current_user.visibility_for(@grid)
      if current_visibility < Grid::GRID_SIZE
        if @user.shard_balance >= 10
          @user.shard_balance -= 10
          @user.save
          new_visibility = current_visibility + 1
          current_user.set_visibility_for(@grid, new_visibility)
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
