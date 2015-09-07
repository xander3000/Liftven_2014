class Notification < ActiveRecord::Base
  belongs_to :category,:polymorphic => true
  belongs_to :transmitter,:polymorphic => true
  has_one :doc,:as => :category
  
  validates_presence_of :note,:subject



  #
  # Asocia un caso a la notificacion
  #
  def associate_case(caso)
       object_doc = Doc.new
       object_doc.case = caso
       object_doc.category = self
       object_doc.save
  end

  #
  # Marcar como leido la notificacion
  #

  def read_done
    update_attribute(:read,true)
  end

end
