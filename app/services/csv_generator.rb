class CsvGenerator
  def initialize(prefix_names)
    @prefix_names = prefix_names
  end

  def save(manager, generated_ids, start_year, end_year, filename, headerValues)
    reply = []
    headerAdded = false
    # populate the results of the api calls one by one
    # write them to the download file simultaneously
    generated_ids.each_with_index do |gid, i|
      result = JSON(manager.apiCall(gid, start_year, end_year))

      if !headerAdded && result["Results"]["series"][0]["data"].length != 0
        # Add the headers
        headers = result["Results"]["series"][0]["data"][0].keys
        headers.delete("latest")
        headers_string = headers.join(",") + "\n"
        IO.write("csv_files/temp.csv", @prefix_names + headers_string)
        headerAdded = true
      end

      reply.push(result)
      formatted_result = csv_format(headerValues[i], result)
      # IO.write("csv_files/temp.csv", gid + "\n", mode: 'a')
      IO.write("csv_files/temp.csv", formatted_result, mode: 'a')
      # IO.write("csv_files/temp.csv", "\n\n", mode: 'a')
    end

    reply
  end

  private



  def csv_format(prefix_columns, result)
    # weed out empty series
    if result.nil? || result["Results"]["series"][0]["data"].length == 0
      return ""
    end

    # generate csv by taking all the values
    csv_string = CSV.generate do |csv|
      result["Results"]["series"][0]["data"].each do |row|
        row.delete("latest")
        csv << (prefix_columns + row.values)
      end
    end

    # return all values
    csv_string
  end
end
