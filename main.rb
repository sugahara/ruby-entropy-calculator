require File.expand_path("../entropy_calculator.rb", __FILE__)

file = ARGV[0]

fetch_file = File.open(file,'r')
fetch_result = []
headers = [:num,
        :time,
        :ip_src,
        :ip_dst,
        :len,
        :proto,
        :ttl,
        :id,
        :flags,
        :tcp_sport,
        :udp_sport,
        :tcp_dport,
        :udp_dport
       ]

output_keys = [:ip_src,
               :ip_dst,
               :len,
               :proto,
               :ttl,
               :id,
               :flags,
               :sport,
               :dport
              ]

read_data = fetch_file.readlines
read_data.delete_at(0)

read_data.each do |v|
  temp_array = []
  headers.each_with_index do |kv, i|
    case kv
    when :time    
      temp_array.push(kv)
      temp_array.push(v.split(",")[i].to_f)
    when :tcp_sport
      temp_array.push(:sport)
      temp_array.push(v.split(",")[i].to_i+v.split(",")[i+1].to_i)
    when :udp_sport
      # do nothing
    when :tcp_dport
      temp_array.push(:dport)
      temp_array.push(v.split(",")[i].to_i+v.split(",")[i+1].to_i)
    when :udp_dport
      # do nothing
    else
      temp_array.push(kv)
      temp_array.push(v.split(",")[i])
    end                  
  end
  temp_hash = Hash[*temp_array]
  fetch_result.push(temp_hash)
end

calculator = EntropyCalculator.new(fetch_result, 10)
begin_time = Time.now
result = calculator.calc
timestamp = calculator.get_timestamp

end_time = Time.now

p end_time - begin_time

output_keys.each do |output_key|
  out_file = File.open("entropy_#{output_key}.dat",'w')
  result[output_key].each_with_index do |v,i|
    out_file.puts "#{timestamp[i][1]} #{v}"
  end
  out_file.close
end



out_file = File.open("entropy.dat",'w')

out_file.puts '"","srcip","dstip","srcport","dstport","length","proto","ttl","id","fflag"'
result[:id].each_with_index do |v,i|
  out_file.puts "\"1\", #{result[:ip_src][i]}, #{result[:ip_dst][i]}, #{result[:sport][i]}, #{result[:dport][i]}, #{result[:len][i]}, #{result[:proto][i]}, #{result[:ttl][i]}, #{result[:id][i]}, #{result[:flags][i]}"
end

