class Comment < ActiveRecord::Base
  humanize_attributes :note => "Comentario"

  belongs_to :category,:polymorphic => true
  belongs_to :user

  validates_presence_of :note
end
