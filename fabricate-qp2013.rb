#parsing for QuickPen PD 2013 format CSVs

require 'csv'

class Object
  def blank?
    self.length == 1
  end
end

ISO_NUMBER  = 0
QUANTITY    = 1
SIZE        = 2
LENGTH      = 3
DESCRIPTION = 4

fabrication_pieces_as_array = CSV.read(ARGV.first)

fabrication_pieces_as_array.delete_if { |x| x[ISO_NUMBER].blank? }

fabrication_pieces_as_array.each do |x|
  x[DESCRIPTION].gsub!(', 150LB, MALLEABLE IRON', '')
  x[DESCRIPTION].gsub!(', 150LB MALLEABLE IRON', '')
  x[DESCRIPTION].gsub!('API LINE PIPE COUPLING, THRD', 'API PIPE COUPLING, THRD')
  x[DESCRIPTION].gsub!('150LB MALLEABLE IRON, GRINNELL', '')
  x[SIZE] = x[SIZE] + '"'
end

iso_pieces = fabrication_pieces_as_array.group_by{|row| row[ISO_NUMBER]}

fabrication_pieces_as_array.each do |piece|
  if iso_pieces[piece[ISO_NUMBER]].size == 2 and !piece[LENGTH].blank?
    piece[DESCRIPTION] = iso_pieces[piece[ISO_NUMBER]].select{ |y| y[LENGTH].blank? }.first[DESCRIPTION]
  end
end

fabrication_pieces_as_array.delete_if {|x| x[LENGTH].blank? and iso_pieces[x[ISO_NUMBER]].size == 2}.sort!{ |x, y| x[ISO_NUMBER] <=> y[ISO_NUMBER] }

CSV.open("cut-sheets.csv", "wb") do |csv|
  csv << ["ISO", "SIZE", "QUANTITY", "LENGTH", "DESCRIPTION"]
  fabrication_pieces_as_array.each { |x| csv << [x[ISO_NUMBER], x[SIZE], x[QUANTITY], x[LENGTH], x[DESCRIPTION]] }
  fabrication_pieces_as_array.group_by { |x| x[DESCRIPTION] }.each { |key, values| csv << ["", "", values.size, "", key] }
end

