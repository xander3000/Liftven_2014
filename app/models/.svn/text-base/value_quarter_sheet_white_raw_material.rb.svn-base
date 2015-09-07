class ValueQuarterSheetWhiteRawMaterial < ActiveRecord::Base
 humanize_attributes :base_value => "Valor Base por 1/4 pliego",
                      :v_10_t => "10",
                      :v_25_t => "25",
                      :v_50_t => "50",
                      :v_100_t => "100",
                      :v_200_t => "200",
                      :v_300_t => "300",
                      :v_400_t => "400",
                      :v_500_t => "500",
                      :v_600_t => "600",
                      :v_700_t => "700",
                      :v_800_t => "800",
                      :v_900_t => "900",
                      :v_1000_t => "1000"

  belongs_to :raw_material#,:class_name => "Material::RawMaterial"

  #
  # Retorna solo valores ordenados
  #
  def self.only_values
    reg = /v_[\d]+_t\z/
    values =  []
    new.attributes.sort.each do |item|
      values << self.human_attribute_name(item.first) if reg.match(item.first)
    end
    values.map(&:to_i).sort
  end

  #
  # Retorna el valor minimo posible de cuartto de pliego para un valor dado
  #
  def min_value_quarter_sheet(value)
    only_values = self.class.only_values
    min = only_values.first
    only_values.each do |only_value|
      if only_value <= value
        min = only_value
      else
        break
      end
    end
    {:base_value => base_value,:value_quarter_sheet =>min ,:t => eval("v_#{min}_t"),:tr => eval("v_#{min}_tr")}
  end

  #
  #
  #
  def price_by_value_quarter_sheet(value)
    accumulate_t = base_value
    accumulate_tr = base_value
    value = min_value_quarter_sheet(value)[:value_quarter_sheet]
    self.class.only_values.each do |only_value|
      accumulate_t = accumulate_t - (accumulate_t*eval("v_#{only_value}_t")/100)
      accumulate_tr = (accumulate_t*2)  - (accumulate_t*2*eval("v_#{only_value}_tr")/100)
      break if only_value.eql?(value)
    end
    {:t =>accumulate_t.round(2),:tr => accumulate_tr.round(2)}
  end

end
