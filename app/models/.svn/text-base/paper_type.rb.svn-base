class PaperType < ActiveRecord::Base
  HUMANIZE_MODEL_NAME = "Tipo de Papel"
  HUMANIZE_ICON = "page_white.png"
  OTRO = "otro"

  belongs_to :raw_material#,:class_name => "Material::RawMaterial"

  #
  # Especifica que se requiere otro tipo de Papel
  #
  def requiere_other_paper?
    tag_name.eql?(OTRO)

  end
end
