class StateMatrix < ActiveRecord::Base
  belongs_to :state_from,:class_name => "State"
  belongs_to :state_to,:class_name => "State"
end
