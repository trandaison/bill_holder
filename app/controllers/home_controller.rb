class HomeController < ApplicationController
  before_action :check_date, :load_master_meter, :load_sub_meter_1, :load_sub_meter_2

  def index
    begin
      temp = [@energy_stats_1, @energy_stats_2]
      if (@energy_stats_1.count > @energy_stats_2.count && @energy_stats_1.last[:remainder]) ||
        (@energy_stats_1.count < @energy_stats_2.count && @energy_stats_2.last[:remainder])
        temp = recalc @energy_stats_1, @energy_stats_2, @energy_count_1, @energy_count_2
      end
      @energy_stats_1 = temp[0]
      @energy_stats_2 = temp[1]
    rescue
      @valid_energy = false
    end

    begin
      temp = [@water_stats_1, @water_stats_2]
      if @water_stats_1.count > @water_stats_2.count && @water_stats_2.last[:remainder]
        temp = recalc @water_stats_1, @water_stats_2, @water_count_1, @water_count_2, type: :water
      elsif @water_stats_1.count < @water_stats_2.count  && @water_stats_1.last[:remainder]
        temp = recalc @water_stats_2, @water_stats_1, @water_count_2, @water_count_1, type: :water
      end
      @water_stats_1 = temp[0]
      @water_stats_2 = temp[1]
    rescue
      @valid_water = false
    end
  end

  def create
  end

  private
  def load_master_meter
    @valid_energy = true
    @valid_water = true
    begin
      apartment = Apartment.find_by pic: Settings.apartment_pics.house_owner
      @last_2_month_master_energy = apartment.meters.energy.where(date: month_range).order :date
      @energy_count = @last_2_month_master_energy[1].quantity - @last_2_month_master_energy[0].quantity
      @energy_stats = split_energy @energy_count
    rescue
      @valid_energy = false
    end

    begin
      @last_2_month_master_water = apartment.meters.water.where(date: month_range(type: :water)).order :date
      @water_count = @last_2_month_master_water[1].quantity - @last_2_month_master_water[0].quantity
      @water_stats = split_energy @water_count, looper: Settings.water_prices_master
    rescue
      @valid_water = false
    end
  end

  def load_sub_meter_1
    begin
      apartment = Apartment.find_by pic: Settings.apartment_pics.son_tran
      @last_2_month_energy_1 = apartment.meters.energy.where(date: month_range).order :date
      @energy_count_1 = @last_2_month_energy_1[1].quantity - @last_2_month_energy_1[0].quantity
      @energy_stats_1 = split_energy @energy_count_1, meter: :sub
    rescue
      @valid_energy = false
    end
  end

  def load_sub_meter_2
    begin
      @energy_count_2 = @energy_count - @energy_count_1
      @energy_stats_2 = split_energy @energy_count_2, meter: :sub
    rescue
      @valid_energy = false
    end

    begin
      apartment = Apartment.find_by pic: Settings.apartment_pics.unknown
      @last_2_month_water_2 = apartment.meters.water.where(date: month_range(type: :water)).order :date
      @water_count_2 = @last_2_month_water_2[1].quantity - @last_2_month_water_2[0].quantity
      @water_stats_2 = split_energy @water_count_2, looper: Settings.water_prices_sub
    rescue
      @valid_water = false
    end

    begin
      @water_count_1 = @water_count - @water_count_2
      @water_stats_1 = split_energy @water_count_1, looper: Settings.water_prices_sub
    rescue
      @valid_water = false
    end
  end

  def month_range type: :energy
    default_date = Meter.try(type).order(:date).last.try :date
    params[:month] ||= default_date
    date = params[:month].try(:to_date)
    [date.beginning_of_month, (date - 1.month).beginning_of_month]
  end

  def check_date
    selected_date = params[:month].try(:to_date).beginning_of_month rescue Date.current.beginning_of_month
    next_month_energy = Meter.energy.order(:date).last.try(:date).beginning_of_month + 1.month || Date.current.beginning_of_month
    next_month_water = Meter.water.order(:date).last.try(:date).beginning_of_month + 1.month || Date.current.beginning_of_month
    next_month = min next_month_energy, next_month_water
    if selected_date == next_month
      @is_next_month = true
      master = Apartment.find_by pic: Settings.apartment_pics.house_owner
      sub_1 = Apartment.find_by pic: Settings.apartment_pics.son_tran
      sub_2 = Apartment.find_by pic: Settings.apartment_pics.unknown
      last_month = (selected_date - 1.month).beginning_of_month
      if next_month == next_month_energy
        @valid_energy = false
        @last_month_energy = {
          master: master.meters.energy.find_by(date: last_month),
          sub_1: sub_1.meters.energy.find_by(date: last_month),
          sub_2: nil
        }
      end
      if next_month == next_month_water
        @valid_water = false
        @last_month_water = {
          master: master.meters.water.find_by(date: last_month),
          sub_1: nil,
          sub_2: sub_2.meters.water.find_by(date: last_month)
        }
      end
    end
  end

  def min date_1, date_2
    date_1 < date_2 ? date_1 : date_2
  end
end
