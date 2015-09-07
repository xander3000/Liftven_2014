class ContactCategory < ActiveRecord::Base
  belongs_to :contact
  belongs_to :category, :polymorphic => true
  belongs_to :contact_type
end
