class Restaurant < ActiveRecord::Base
  serialize :acceptedpayment, Array
  serialize :tags, Array
  serialize :description, Array
end
