class Ajax::MetersController < ApplicationController
  before_action :verify_passcode

  def create
    month = nil
    params[:meters].each do |i, meter_p|
      m_params = meter_params meter_p
      date = m_params[:date].to_date.beginning_of_month
      if (apartment = Apartment.find_by pic: meter_p[:meter][:pic])
        meter = apartment.meters.find_or_initialize_by date: date
        meter.assign_attributes m_params
        meter.date = date
        meter.save
      end
      month = date.to_datetime
    end
    render js: "window.location.href = '/?month=#{month}';"
  end

  private
  def verify_passcode
    render js: "alert('Sai Pass code!');" unless params[:pass_code] == ENV['PASS_CODE']
  end

  def meter_params meter
    meter.require(:meter).permit :apartment_id, :meter_type, :date, :quantity
  end
end
