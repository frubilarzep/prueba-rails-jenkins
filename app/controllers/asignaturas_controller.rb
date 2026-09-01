class AsignaturasController < ApplicationController
  before_action :set_asignatura, only: %i[show update destroy]

  def index
    render json: Asignatura.all
  end

  def show
    render json: @asignatura
  end

  def create
    asignatura = Asignatura.new(asignatura_params)

    if asignatura.save
      render json: asignatura, status: :created
    else
      render json: { errors: asignatura.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @asignatura.update(asignatura_params)
      render json: @asignatura
    else
      render json: { errors: @asignatura.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @asignatura.destroy
    head :no_content
  end

  private

  def set_asignatura
    @asignatura = Asignatura.find(params[:id])
  end

  def asignatura_params
    params.require(:asignatura).permit(:nombre, :codigo, :seccion, :semestre)
  end
end
