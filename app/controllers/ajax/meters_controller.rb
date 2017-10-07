class Ajax::MetersController < ApplicationController
  before_action :verify_passcode, only: :create
  skip_before_action :verify_authenticity_token

  def create
    month = nil
    params[:meters].each do |i, meter_p|
      m_params = meter_params meter_p
      date = m_params[:date].to_date.beginning_of_month
      if (apartment = Apartment.find_by pic: meter_p[:meter][:pic])
        meter = apartment.meters.find_or_initialize_by date: date, meter_type: m_params[:meter_type]
        meter.assign_attributes m_params
        meter.date = date
        meter.save
      end
      month = date.to_datetime
    end
    render js: "window.location.href = '/?month=#{month}';"
  end

  def reverse
    meter = reverse_from_cost params[:cost].to_i, type: params[:type]
    status = meter == -1 ? 400 : 200
    render json: {meter: meter}, status: status
  end

  private
  def verify_passcode
    render js: "alert('Sai Pass code!');" unless params[:pass_code] == ENV['PASS_CODE']
  end

  def meter_params meter
    meter.require(:meter).permit :apartment_id, :meter_type, :date, :quantity
  end

  def reverse_from_cost cost, type: :energy
    # Giá nước ở settings đã bao gồm VAT rồi.
    vat = type == :energy ? 1.1 : 1
    cost_without_vat = cost / vat
    first_part = Settings.send("#{type}_price_thresholds").to_h.select {|k, v| v <= cost_without_vat.round}
    last_threshold = first_part.keys.last.to_s.to_i
    last_cost = first_part.values.last || 0
    remaining_cost = cost_without_vat - last_cost
    remaining_cost = {min: remaining_cost - Settings.delta, max: remaining_cost + Settings.delta}
    price = Settings.send("#{type}_prices_master").try next_threshold(last_threshold, type: type)
    index = 0
    # maximum là 1000 chữ
    index += 1 until ((index * price).between?(remaining_cost[:min], remaining_cost[:max]) || index > 1000)
    index > 1000 ? -1 : last_threshold + index
  end

  def next_threshold current, type: :energy
    thresholds = Settings.send("#{type}_price_thresholds").keys.map {|val| val.to_s.to_i}
    next_index = current == 0 ? 1 : thresholds.index(current) + 1
    thresholds[next_index].to_s
  end
end
