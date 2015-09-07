module Frontend::DesignsHelper
  def get_temporal_digital_card_fields
      #draggable-item-position
      #draggable-item-text
      #draggable-item-color
      #draggable-item-size
      #draggable-item-font
      #draggable-item-position_left
      #draggable-item-position_top
      if current_session_wizard_step["step_3"]
        
        items_size = current_session_wizard_step["step_3"][:value].split("&").size/7
        items = current_session_wizard_step["step_3"][:value].split("&")
        hash_items = {}
        items.each do |item|
          item = item.split("=")
          hash_items[item[0]] = item[1]
        end
        @dcfs = []
        hash_components = {"draggable-item-text" => "input_text","draggable-item-color" => "font_color", "draggable-item-size" => "font_size","draggable-item-position_top" => "position_top","draggable-item-position_left" => "position_left","draggable-item-font" => "font_family"}
        (eval("1..#{items_size}")).each do |item|
          dcf = DigitalCardField.new
          hash_components.keys.each do  |hash_component|
            value = "#{hash_items["#{hash_component}_#{item}"]}"
            eval("dcf.#{hash_components[hash_component]} = '#{value.sub(/[+]/, ' ')}'")
          end
          @dcfs << dcf
        end
        @dcfs
      else
        []
      end
  
  end
end
