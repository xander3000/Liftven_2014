class TrackingState < ActiveRecord::Base
  belongs_to :state
  belongs_to :proxy,:polymorphic => true
  belongs_to :user
  has_many :trackers, :order =>"created_at ASC"
  

  validates_presence_of :state,:user

  before_create :set_as_actual



  #
  #Definir o configurar como seguimiento o estado actual
  #
  def set_as_actual
    self.proxy.tracking_states.each do |tracking_state|
      tracking_state.update_attribute(:actual,false)
    end
    self.actual = true
  end


  #
  # Agregar tracker o seguidor al estado o tracking
  #
  def add_user_tracker(attr,options={})
    object = Tracker.new(attr)
    success = object.valid?
    if success
      object.tracking_state = self
      object.save
    end
    success
  end

  #
  # seguidor actual
  #
  def actual_tracker
    trackers.first(:conditions => {:actual => true})
  end



end
