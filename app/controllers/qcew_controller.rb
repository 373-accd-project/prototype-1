require 'rest_client'
require 'json'
require 'csv'

class QcewController < ApplicationController
  def index
    if params.has_key?(:year)
      p params

      # generate all possible series ids
      generated_ids = generate_ids("ENU", [params[:area_code], params[:datatype], params[:size], params[:ownership], params[:industry]])

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
      session[:area_code] = params[:area_code]
      session[:datatype] = params[:datatype]
      session[:size] = params[:size]
      session[:ownership] = params[:ownership]
      session[:industry] = params[:industry]
    end

    # Read the fitlers from the CSV file
    @area_codes = CSV.read('csv_files/qcew/area_titles.csv')[1..]
    @data_types = CSV.read('csv_files/qcew/datatype_titles.csv')[1..]
    @industries = CSV.read('csv_files/qcew/industry_titles.csv')[1..]
    @ownership = CSV.read('csv_files/qcew/ownership_titles.csv')[1..]
    @sizes = CSV.read('csv_files/qcew/size_titles.csv')[1..]

    # Switch the key-value pairs to make sure that the correct one appears
    # in the drop down for each filter
    for area_code in @area_codes do
      tmp = area_code[0]
      area_code[0] = area_code[1]
      area_code[1] = tmp
    end
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
    for ownership in @ownership do
      tmp = ownership[0]
      ownership[0] = ownership[1]
      ownership[1] = tmp
    end
    for size in @sizes do
      tmp = size[0]
      size[0] = size[1]
      size[1] = tmp
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
    # weed out empty series
    if result["Results"]["series"][0]["data"].length == 0
      return ""
    end
    # get the column headers
    headers = result["Results"]["series"][0]["data"][0].keys.join(",") + "\n"
    csv_string = ""

    # generate csv by taking all the values
    csv_string = CSV.generate do |csv|
      result["Results"]["series"][0]["data"].each do |row|
        csv << row.values
      end
    end

    # return headers concatenated with all values
    return (headers << csv_string)
  end

end
