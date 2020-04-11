require 'rest_client'
require 'json'
require 'csv'

class NationaleheController < ApplicationController
  def index
    if params.has_key?(:year)


      # generate all possible series ids
      generated_ids = generate_ids("CEU", [params[:industry], params[:data_type]])
      
      # make the download file blank
      IO.write("csv_files/temp.csv", "")

      # populate the results of the api calls one by one
      # write them to the download file simultaneously
      @reply = []
      @manager = JsonManager.new("https://api.bls.gov/publicAPI/v2/timeseries/data/")
      generated_ids.each do |gid|
        result = JSON(@manager.apiCall(gid, 2010, 2020))
        @reply.push(result)
        formatted_result = csv_format(result)
        IO.write("csv_files/temp.csv", gid + "\n", mode: 'a')
        IO.write("csv_files/temp.csv", formatted_result, mode: 'a')
        IO.write("csv_files/temp.csv", "\n\n", mode: 'a')
      end
      @generated_ids = generated_ids
      # Store filters in session hash so that any subsequent downlaod requests
      # have access to them
      session[:supersector] = params[:supersector]
      session[:industry] = params[:industry]
      session[:data_type] = params[:data_type]
    end
   # Read the fitlers from the CSV file
    @supersectors = CSV.read('csv_files/nationalehe/supersector_codes.csv')[1..]
    @industries = CSV.read('csv_files/nationalehe/industry_codes.csv')[1..]
    @data_types = CSV.read('csv_files/nationalehe/data_type_codes.csv')[1..]
    @state_initials.to_h

    # Hashmaps to create the accordian filters
    @ss_hashmap = Hash[@supersectors.map {|key, value| [key, value]}]
    @data_hashmap = Hash[@data_types.map {|key, value| [key, value]}] 
    @industries_hashmap = Hash[@industries.map {|key, value| [key, value]}] 

    # Switch the key-value pairs to make sure that the correct one appears
    # in the drop down for each filter
    for data_type in @data_types do
      tmp = data_type[0]
      data_type[0] = data_type[1]
      data_type[1] = tmp
    end
    for industry in @industries do
      tmp = industry[0]
      industry[0] = industry[1]
      industry[1] = tmp
    end
    for supersector in @supersectors do
      tmp = supersector[0]
      supersector[0] = supersector[1]
      supersector[1] = tmp
    end
  end
  
  private
  def generate_ids(prefix, arrays)

    # if there is an empty parameter, there are no permutations
    if arrays.select { |e| e.length == 0 }.length > 0
      return []
    end

    all_combos = []

    # counters for each parameter
    counts = arrays.map { |e| 0 }
    combo = ""
    # while there are combos left to try
    while more_combos(counts, arrays)
      # create the combo from the counters
      combo = prefix + arrays.each_with_index.map {|a, i| a[counts[i]]}.join("")

      # push to result set and increment
      all_combos.push(combo)
      combo = ""
      counts = increment_counts(counts, arrays)
    end
    return all_combos
  end

  def more_combos(counts, arrays)
    return counts[0] < arrays[0].length
  end

  def increment_counts(counts, arrays)
    # start at last count and move down
    i = counts.length - 1
    while (i >= 0)

      # if a count can be incremented, increment and set the following to 0
      if (counts[i] + 1) % arrays[i].length != 0
        counts[i] += 1
        j = i + 1
        while j < counts.length
          counts[j] = 0
          j += 1
        end
        return counts
      end
      i -= 1
    end
    counts[0] += 1
    return counts
  end

  def csv_format(result)
    p result["Results"]["series"][0]["data"].length
    if result["Results"]["series"][0]["data"].length == 0
      return ""
    else
      p result["Results"]["series"][0]["data"][0].values.join(",")
    end
    headers = result["Results"]["series"][0]["data"][0].keys.join(",") + "\n"
    csv_string = ""
    csv_string = CSV.generate do |csv|
      result["Results"]["series"][0]["data"].each do |row|
        csv << row.values
      end
    end
    return (headers << csv_string)
  end

    # send_data file, :type => 'text/csv; charset=iso-8859-1; header=present', :filename => "data.csv"

end


#SMU4810180000000000001
#SMU48101800000000001