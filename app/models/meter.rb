class Meter < ApplicationRecord
  belongs_to :apartment

  enum meter_type: [:energy, :water]

  scope :last_meter, -> {order(:date).last}
  scope :current_meter, -> current_month = Date.current.beginning_of_month {}
end
