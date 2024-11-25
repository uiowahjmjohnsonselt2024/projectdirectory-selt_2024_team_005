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
    if @grid.nil?
      flash[:error] = "Grid not found"
      redirect_to grids_path
    else
      @visibility = current_user.visibility_for(@grid)
      @cells = @grid.cells.where("cell_loc LIKE ?", "R[0-#{@visibility - 1}]C[0-#{@visibility - 1}]")
      @cells = @cells.order(:cell_id)
      print(@cells)
      print(@visibility)
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
        new_visibility = current_visibility + 1
        current_user.set_visibility_for(@grid, new_visibility)
        flash[:notice] = "Grid expanded successfully"
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
    end
  end
end
