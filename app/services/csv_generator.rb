class CsvGenerator
  def save(manager, generated_ids, start_year, end_year, filename)
    # make the download file blank
    IO.write("csv_files/temp.csv", "")

    reply = []
    
    generated_ids.each do |gid|
      result = JSON(manager.apiCall(gid, start_year, end_year))
      reply.push(result)
      formatted_result = csv_format(result)
      IO.write("csv_files/temp.csv", gid + "\n", mode: 'a')
      IO.write("csv_files/temp.csv", formatted_result, mode: 'a')
      IO.write("csv_files/temp.csv", "\n\n", mode: 'a')
    end

    reply
  end

  private
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
end