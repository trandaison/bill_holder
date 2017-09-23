class HomeController < ApplicationController
  before_action :load_master_meter, :load_sub_meter_1, :load_sub_meter_2

  def index
    temp = [@energy_stats_1, @energy_stats_2]
    if @energy_stats_1.count > @energy_stats_2.count  && @energy_stats_1.last[:remainder]
      temp = recalc @energy_stats_1, @energy_stats_2, @energy_count_1, @energy_count_2
    elsif @energy_stats_1.count < @energy_stats_2.count  && @energy_stats_2.last[:remainder]
      temp = recalc @energy_stats_2, @energy_stats_1, @energy_count_2, @energy_count_1
    end
    @energy_stats_1 = temp[0]
    @energy_stats_2 = temp[1]

    temp = [@water_stats_1, @water_stats_2]
    if @water_stats_1.count > @water_stats_2.count && @water_stats_2.last[:remainder]
      temp = recalc @water_stats_1, @water_stats_2, @water_count_1, @water_count_2
    elsif @water_stats_1.count < @water_stats_2.count  && @water_stats_1.last[:remainder]
      temp = recalc @water_stats_2, @water_stats_1, @water_count_2, @water_count_1
    end
    @water_stats_1 = temp[0]
    @water_stats_2 = temp[1]
  end

  def create
  end

  private
  def load_master_meter
    apartment = Apartment.find_by pic: Settings.apartment_pics.house_owner
    @last_2_month_master_energy = apartment.meters.energy.order(:date).last 2
    @energy_count = @last_2_month_master_energy[1].quantity - @last_2_month_master_energy[0].quantity
    @energy_stats = split_energy @energy_count

    @last_2_month_master_water = apartment.meters.water.order(:date).last 2
    @water_count = @last_2_month_master_water[1].quantity - @last_2_month_master_water[0].quantity
    @water_stats = split_energy @water_count, looper: Settings.water_prices_master
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

    apartment = Apartment.find_by pic: Settings.apartment_pics.unknown
    @last_2_month_water_2 = apartment.meters.water.order(:date).last(2)
    @water_count_2 = @last_2_month_water_2[1].quantity - @last_2_month_water_2[0].quantity
    @water_stats_2 = split_energy @water_count_2, looper: Settings.water_prices_sub

    @water_count_1 = @water_count - @water_count_2
    @water_stats_1 = split_energy @water_count_1, looper: Settings.water_prices_sub
  end
end
