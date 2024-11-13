class CellsController < ApplicationController
  before_action :set_cell, only: [:show, :update]

  def show
  end

  def update
  end

  private
  def set_cell
    @cell = Cell.find(params[:id])
  end

end