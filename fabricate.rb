require 'csv'

ISO_NUMBER  = 0
SIZE        = 1
QUANTITY    = 2
LENGTH      = 3
DESCRIPTION = 4

fabrication_pieces_as_array = CSV.read("isos.csv")

fabrication_pieces_as_array.delete_if { |x| x[ISO_NUMBER].empty? }

fabrication_pieces_as_array.each do |x|
  x[DESCRIPTION].gsub!(/, 150.*/, '')
  x[DESCRIPTION].gsub!(/ 150.*/, '')
  x[DESCRIPTION].gsub!(' PIPE', '')
  x[DESCRIPTION] = x[SIZE] + " " + x[DESCRIPTION] if x[LENGTH].empty?
end

iso_pieces = fabrication_pieces_as_array.group_by{|row| row[ISO_NUMBER]}

fabrication_pieces_as_array.each do |x|
  if iso_pieces[x[ISO_NUMBER]].size == 2 and !x[LENGTH].nil? 
    x[DESCRIPTION] = iso_pieces[x[ISO_NUMBER]].select{ |y| y[LENGTH].empty? }.first[DESCRIPTION]
  end
end

fabrication_pieces_as_array.delete_if {|x| x[LENGTH].empty? and iso_pieces[x[ISO_NUMBER]].size == 2}.sort!{ |x, y| x[ISO_NUMBER] <=> y[ISO_NUMBER] }

CSV.open("cut-sheets.csv", "wb") do |csv|
  csv << ["ISO", "SIZE", "QUANTITY", "LENGTH", "DESCRIPTION"]
  fabrication_pieces_as_array.each { |x| csv << [x[ISO_NUMBER], x[SIZE], x[QUANTITY], x[LENGTH], x[DESCRIPTION]] }
  fabrication_pieces_as_array.group_by { |x| x[DESCRIPTION] }.each { |key, values| csv << ["", "", values.size, "", key] }
end