require 'csv'

ISO_NUMBER 	= 0
SIZE 		    = 1
QUANTITY 	  = 2
LENGTH 		  = 3
DESCRIPTION = 4

fabrication_pieces_as_array = CSV.read("isos.csv")

fabrication_pieces_as_array.delete_if { |x| x[ISO_NUMBER] == "" }

fabrication_pieces_as_array.each do |x|
  x[DESCRIPTION].gsub!(', 150LB, MALLEABLE IRON', '')
  x[DESCRIPTION].gsub!(', 150LB MALLEABLE IRON', '')
  x[DESCRIPTION].gsub!('API LINE PIPE COUPLING, THRD', 'API PIPE COUPLING, THRD')
  x[DESCRIPTION].gsub!('150LB MALLEABLE IRON, GRINNELL', '')
  x[DESCRIPTION] = x[SIZE] + " " + x[DESCRIPTION] if x[LENGTH] == ""
end

puts fabrication_pieces_as_array.inspect

iso_pieces = fabrication_pieces_as_array.group_by{|row| row[ISO_NUMBER]}

fabrication_pieces_as_array.each do |x|
  x[DESCRIPTION] = iso_pieces[x[ISO_NUMBER]].select{ |y| y[LENGTH] == "" }.first[DESCRIPTION] if x[LENGTH] != "" and iso_pieces[x[ISO_NUMBER]].size == 2
end

fabrication_pieces_as_array.delete_if {|x| x[LENGTH] == "" and iso_pieces[x[ISO_NUMBER]].size == 2}.sort!{ |x, y| x[ISO_NUMBER] <=> y[ISO_NUMBER] }

CSV.open("cut-sheets.csv", "wb") do |csv|
  csv << ["ISO", "SIZE", "QUANTITY", "LENGTH", "DESCRIPTION"]
  fabrication_pieces_as_array.each { |x| csv << [x[ISO_NUMBER], x[SIZE], x[QUANTITY], x[LENGTH], x[DESCRIPTION]] }
end