class RawMaterialCategory < ActiveRecord::Base
  
  NONE = "None"


  has_many :raw_materials,:order => "name ASC"#,:class_name => "Material::RawMaterial"
  has_many :packing_materials
  
  validates_presence_of :model_relationship


  #
  # En base a la relacion, define si es un tito de papel #PaperType
  #
  def is_a_paper_type?
    model_relationship.eql?(PaperType.to_s)
  end

  #
  # En base a la relacion, define si es un tipo de material #MaterialProductType
  #
  def is_a_material_product_type?
    model_relationship.eql?(MaterialProductType.to_s)
  end

  #
  # No esta relacionado con otro modelo
  #
  def has_any_model_relationship?
    !model_relationship.eql?(NONE)
  end

end
