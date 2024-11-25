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
      @cells = @grid.cells.order(:cell_id)
      @grid_matrix = @cells.each_slice(@grid.size).to_a
      @characters = Character.where(grid_id: @grid.grid_id).index_by(&:cell_id)
    end
  end

  def expand
    @grid = Grid.find_by(grid_id: params[:id])
    if @grid.nil?
      # puts "grid nil entered"
      flash[:error] = "Grid not found"
      redirect_to grids_path
    else
      @grid.size += 1
      if @grid.save
        @grid.expand_grid
        flash[:notice] = "Grid expanded successfully"
        # puts "grid expanded succcessfully"
      else
        flash[:error] = "Failed to expand grid"
      end
      redirect_to @grid
    end
  end


  private
  def grid_params
    params.require(:grid).permit(:grid_id, :size, :name)
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
