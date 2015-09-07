class Backend::MaterialManagement::RawMaterialsController < Backend::MaterialManagement::BaseController
	def index
    @title = "Materiales"
    @raw_materials = Material::RawMaterial.all
		respond_to do |format|

				format.html
				format.pdf do

					render :pdf                            => "RawMaterials",
								 :disposition                    => 'attachment',
								 :layout												 =>	'backend/contable_document.html.erb',
								 :orientation                    => 'Portrait',
								 :page_size												=> 'Letter',

								 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
																				},
															:left => '2'
															},
								 :margin => {:top                => 13,
														 :bottom             => 20,
														 :right              => 2,
														 :left               => 5
													 }
				end
		end
	end

	def new
    @title = "Materiales / Nuevo material"
		@raw_material = Material::RawMaterial.new
		defaults
	end

  def create
    @raw_material = Material::RawMaterial.new(params[:material_raw_material])
		defaults
    @success = @raw_material.valid?
    if @success
      @raw_material.save
    end
  end

  def show
    @title = "Materiales / Detalle material"
    @raw_material = Material::RawMaterial.find(params[:id])
		@raw_material_goods_movement_positions = @raw_material.material_goods_movement_positions
  end

  def edit
    @title = "Materiales / Editar material"
    @raw_material = Material::RawMaterial.find(params[:id])
  end

	def update
		@raw_material = Material::RawMaterial.find(params[:id])
		@success = @raw_material.update_attributes(params[:material_raw_material])
	end

	def autocomplete_by_name
    result = Material::RawMaterial.find_by_autocomplete("name",params[:term])
    render :json => result
  end

	def print_good_movements
		@raw_material = Material::RawMaterial.find(params[:raw_material_id])
		@raw_material_goods_movement_positions = @raw_material.material_goods_movement_positions

					render :pdf                            => "RawMaterial_#{@raw_material.id.to_code}_good_movemenets",
								 :disposition                    => 'attachment',
								 :layout												 =>	'backend/contable_document.html.erb',
								 :orientation                    => 'Portrait',
								 :page_size												=> 'Letter',

								 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
																				},
															:left => '2'
															},
								 :margin => {:top                => 13,
														 :bottom             => 20,
														 :right              => 2,
														 :left               => 5
													 }
	end

	protected

	def defaults
		@raw_material.last_price_change = Time.now.to_date.to_s.to_default_date
	end


end
