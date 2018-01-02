module ApplicationHelper
  def split_energy total, meter: :master, looper: nil
    result = []
    last_threshold = 0
    looper ||= Settings.try "energy_prices_#{meter}"
    looper.each do |threshold, price|
      tmp = threshold.to_s.to_i
      threshold = tmp - last_threshold
      if total > 0
        if total >= threshold
          result << {
            threshold: threshold,
            count: threshold,
            price: price,
            cost: threshold * price,
            remainder: nil
          }
          total = total - threshold
        else
          result << {
            threshold: threshold,
            count: total,
            price: price,
            cost: total * price,
            remainder: threshold - total
          }
          total = 0
        end
      end
      last_threshold = tmp
    end
    result
  end

  def sum_cost array
    array.inject(0) {|sum, hash| sum += hash[:cost]}
  end

  def calc_vat array, vat: 10
    (sum_cost(array) * vat / 100).ceil
  end

  def total_cost array
    sum_cost(array) + calc_vat(array)
  end

  def recalc array_1, array_2, total_1, total_2, type: :energy
    if array_1.size > array_2.size
      array_1 = split_energy total_1, meter: :sub, looper: generate_new_energy_prices(array_1, array_2, type: type)
    else
      array_2 = split_energy total_2, meter: :sub, looper: generate_new_energy_prices(array_2, array_1, type: type)
    end
    [array_1, array_2]
  end

  def generate_new_energy_prices array_large, array_small, type: :energy
    bonus = array_small.last[:remainder]
    prices = Settings.try("#{type}_prices_sub").to_a
    first_index = array_small.size - 1
    last_index = Settings.try("#{type}_prices_sub").count - 1
    (first_index..last_index).each do |i|
      bonus = (i == first_index) ? bonus : Settings.try("#{type}_bonus")[i]
      new_key = prices[i][0].to_s.to_i + bonus
      prices[i][0] = new_key.to_s.to_sym
    end
    prices.to_h
  end

  def generate_new_water_prices array_large, array_small
    bonus = array_small.last[:remainder]
    prices = Settings.water_prices_sub.to_a
    first_index = array_small.size - 1
    last_index = Settings.water_prices_sub.count - 1
    (first_index..last_index).each do |i|
      bonus = (i == first_index) ? bonus : Settings.water_bonus[i]
      new_key = prices[i][0].to_s.to_i + bonus
      prices[i][0] = new_key.to_s.to_sym
    end
    prices.to_h
  end

  def notify_changes?
    from_date = "01/12/2017".to_datetime
    (Time.current <= from_date + 2.months) || (params[:month] <= from_date)
  end
end
