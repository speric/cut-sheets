require 'csv'

ISO_NUMBER 	= 0
SIZE 		= 1
QUANTITY 	= 2
LENGTH 		= 3
DESCRIPTION = 4

fabrication_pieces_as_array = CSV.read("test.csv")

iso_pieces = fabrication_pieces_as_array.group_by{|row| row[ISO_NUMBER]}

cut_sheets = Array.new

iso_pieces.each do |iso_num, pieces|
  unless pieces.size > 2
    hash = Hash[pieces.map.with_index{|*ki| ki}]
    
    puts hash
    #hash['b'] # => 1
  end
  #puts "#{iso_num} \t=> #{pieces.size}"
end