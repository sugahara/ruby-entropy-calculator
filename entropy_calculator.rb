class EntropyCalculator
  def initialize(data, interval)
    @data = data
    @keys = data.first.keys
    @interval = interval #interval of  entropy calculation
  end

  def calc
    split_datas = split_interval()
    calc_result = {}
    @keys.each do |key|
      split_datas.each do |data| # each block
        value_array = []
        data.each do |value_hash| #each packet
          value_array.push(value_hash[key]) # 
        end
        value_array # now value_array is [value1, value2, ...] of key of each block
        calc_result[key] ||= []
        calc_result[key].push(calc_entropy(value_array)) # calc entropy of value_array
      end
    end
    calc_result
  end

  def get_timestamp
    timestamp = []
    first_time = @data.first[:time]
    last_time = @data.last[:time]
    ((last_time - first_time)/@interval + 1).to_i.times do |t|
      start_time = first_time + @interval*t
      end_time = start_time + @interval
      timestamp.push [start_time, end_time]
    end
    timestamp
  end

  private
  def split_interval
    split_data_array = []
    split_counter = 0
    start_time = @data.first[:time]
    end_time = start_time + @interval
    @data.each do |packet|
      split_data_array[split_counter] ||= []
      if packet[:time] >= end_time
        split_counter += 1
        split_data_array[split_counter] ||= []
        split_data_array[split_counter].push(packet)
        start_time = end_time
        end_time = start_time + @interval
      else
        split_data_array[split_counter].push(packet)
      end
    end
    split_data_array
  end

  def calc_entropy(values)
    sum_of_entropy = 0.0
    # get uniq values
    uniq_values = values.uniq
    # count each uniq values and get probability of uniq values
    uniq_value_prob = {}
    uniq_values.each do |uniq_value|
      uniq_value_prob[uniq_value] = values.count(uniq_value) / values.size.to_f
    end
    # calc entropy of each uniq values and sum
    uniq_value_prob.each do |uniq_value, prob|
      sum_of_entropy += prob * Math::log2(prob)
    end
    sum_of_entropy * -1
  end

end
