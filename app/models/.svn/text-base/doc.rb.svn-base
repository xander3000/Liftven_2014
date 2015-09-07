class Doc < ActiveRecord::Base
  belongs_to :case, :dependent => :destroy
  belongs_to :category,:polymorphic => true

  validates_uniqueness_of :case_id,:scope => [:category_id,:category_type]
end
