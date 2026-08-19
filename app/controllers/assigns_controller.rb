class AssignsController < ApplicationController
  before_action :set_assign, only: %i[show update destroy]

  def index
    render json: Assign.all
  end

  def show
    render json: @assign
  end

  def create
    assign = Assign.new(assign_params)

    if assign.save
      render json: assign, status: :created
    else
      render json: { errors: assign.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @assign.update(assign_params)
      render json: @assign
    else
      render json: { errors: @assign.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @assign.destroy
    head :no_content
  end

  private

  def set_assign
    @assign = Assign.find(params[:id])
  end

  def assign_params
    params.require(:assign).permit(:titulo, :fecha_inscripcion)
  end
end
