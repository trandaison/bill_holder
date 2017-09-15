class HomeController < ApplicationController
  before_action :load_master_meter, :load_sub_meter_1, :load_sub_meter_2

  def index
    temp = [@energy_stats_1, @energy_stats_2]
    temp = if @energy_stats_1.count > @energy_stats_2.count
      recalc @energy_stats_1, @energy_stats_2, @energy_count_1, @energy_count_2
    elsif @energy_stats_1.count < @energy_stats_2.count
      recalc @energy_stats_2, @energy_stats_1, @energy_count_2, @energy_count_1
    end
    @energy_stats_1 = temp[0]
    @energy_stats_2 = temp[1]
  end

  def create

  end

  private
  def load_master_meter
    apartment = Apartment.find_by pic: Settings.apartment_pics.house_owner
    @last_2_month_master_energy = apartment.meters.energy.order(:date).last(2)
    @energy_count = @last_2_month_master_energy[1].quantity - @last_2_month_master_energy[0].quantity
    @energy_stats = split_energy @energy_count
  end

  def load_sub_meter_1
    apartment = Apartment.find_by pic: Settings.apartment_pics.son_tran
    @last_2_month_energy_1 = apartment.meters.energy.order(:date).last(2)
    @energy_count_1 = @last_2_month_energy_1[1].quantity - @last_2_month_energy_1[0].quantity
    @energy_stats_1 = split_energy @energy_count_1, meter: :sub
  end

  def load_sub_meter_2
    @energy_count_2 = @energy_count - @energy_count_1
    @energy_stats_2 = split_energy @energy_count_2, meter: :sub
  end
end
