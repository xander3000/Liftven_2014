class PageSizeType < ActiveRecord::Base
  HUMANIZE_MODEL_NAME = "Tamaño de Papel"
  HUMANIZE_ICON = "shape_handles.png"
  OTRO = "otro"
  



  #
  # Es un tipo de tamaño de papel sin medida
  #
  def requiere_other_size?
    tag_name.eql?(OTRO)
  end

  #
  # 
  #
  def self.calculate_max_quantity_for_dimension_by_quarter_sheet
    all.each do |item|
      val_1 = Product.calculate_max_quantity_for_dimension_by_quarter_sheet(item.side_dimension_x,item.side_dimension_y)
      val_2 = Product.calculate_max_quantity_for_dimension_by_quarter_sheet(item.side_dimension_y,item.side_dimension_x)
      max_val = val_1 > val_2 ? val_1 : val_2
      puts "#{item.name}: #{max_val}"
    end
    true
  end









end
