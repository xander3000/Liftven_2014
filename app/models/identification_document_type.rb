class IdentificationDocumentType < ActiveRecord::Base
  validates_uniqueness_of :short_name

end
