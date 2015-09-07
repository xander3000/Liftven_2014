class Backend::FinishedProductsController < Backend::BaseController

  def index
    @finished_products = []
  end

  def new
    @finished_product = FinishedProduct.new
  end

  def create
    @finished_product = FinishedProduct.new(params[:finished_product])
    @success = @finished_product.valid?
    if @success
      @finished_product.save
    end
  end

  def select_presentation_unit_types
    @presentation_unit_types = []
    @raw_material = RawMaterial.find_by_id((params[:finished_product][:raw_material_id].eql?("") ? 0 : params[:finished_product][:raw_material_id]))
    @presentation_unit_types = @raw_material.presentation_unit_types if @raw_material
  end

  def select_presentation_unit_type_measures
    #TODO: pasar a packing_material
    #select_presentation_unit_type_measurements
    #@presentation_unit_type_measure = PresentationUnitTypeMeasure.find_by_id((params[:finished_product][:presentation_unit_type_id].eql?("") ? 0 : params[:finished_product][:presentation_unit_type_id]))
    presentation_unit_type = PresentationUnitType.find_by_id(params[:finished_product][:presentation_unit_type_id])
    @presentation_unit_type_measure = presentation_unit_type.nil? ? nil : presentation_unit_type.presentation_unit_type_measure
  end
#TODO: pasar a packing_material
#  def select_presentation_unit_type_measurements
#    presentation_unit_type = PresentationUnitType.find_by_id(params[:finished_product][:presentation_unit_type_id])
#    @presentation_unit_type_measurements = presentation_unit_type.nil? ? [] : presentation_unit_type.presentation_unit_type_measurements
#    #@presentation_unit_type_measure = PresentationUnitTypeMeasurement.find_all_by_id((params[:finished_product][:presentation_unit_type_id].eql?("") ? 0 : params[:finished_product][:presentation_unit_type_id]))
#  end

    protected

  def set_title
    @title = "Materia Prima Procesada"
  end

end
