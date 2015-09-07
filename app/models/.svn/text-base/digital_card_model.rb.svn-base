class DigitalCardModel < ActiveRecord::Base
  belongs_to :digital_card_type

  has_attached_file :image,
                    :url  => "/attachments/digital_cards/:id/:basename.:extension",
                    :path => ":rails_root/public/attachments/digital_cards/:id/:basename.:extension"

  validates_presence_of :digital_card_type,:partial_template,:name,:quantity_fields,:image_file_name
end
