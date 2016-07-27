class String
  BLANK_RE = /\A[[:space:]]*\z/
  def blank?
    empty? || BLANK_RE === self
  end
end

class QuickpenFabricator
  ISO_NUMBER  = 0
  MARK        = 1
  QUANTITY    = 2
  SIZE        = 3
  LENGTH      = 4
  DESCRIPTION = 5

  def initialize(attributes={})
    @import_file = attributes[:import_file]
  end

  def generate_cut_sheets_csv_data
    @fabrication_pieces_as_array = CSV.parse(@import_file, headers: true)
    @fabrication_pieces_as_array.delete_if { |x| x[ISO_NUMBER].blank? }

    clean_up_descriptions
    combine_cut_pipe_and_makeup_fittings
    generate_csv
  end

  private

  def clean_up_descriptions
    @fabrication_pieces_as_array.each do |piece|
      piece[DESCRIPTION].gsub!(', 150LB, MALLEABLE IRON', '')
      piece[DESCRIPTION].gsub!(', 150LB MALLEABLE IRON', '')
      piece[DESCRIPTION].gsub!('API LINE PIPE COUPLING, THRD', 'API PIPE COUPLING, THRD')
      piece[DESCRIPTION].gsub!('150LB MALLEABLE IRON, GRINNELL', '')
      piece[SIZE] = piece[SIZE] + '"'
    end
  end

  def combine_cut_pipe_and_makeup_fittings
    @iso_pieces = @fabrication_pieces_as_array.group_by{|row| row[ISO_NUMBER]}

    @fabrication_pieces_as_array.each do |piece|
      if @iso_pieces[piece[ISO_NUMBER]].size == 2 and !piece[LENGTH].blank?
        piece[DESCRIPTION] = @iso_pieces[piece[ISO_NUMBER]].select{ |y| y[LENGTH].blank? }.first[DESCRIPTION]
      end
    end

    @fabrication_pieces_as_array.delete_if {|piece| piece[LENGTH].blank? and @iso_pieces[piece[ISO_NUMBER]].size == 2}
  end

  def generate_csv
    csv_content = CSV.generate do |csv|
      csv << ["ISO", "SIZE", "QUANTITY", "LENGTH", "DESCRIPTION"]
      @fabrication_pieces_as_array.each { |x| csv << [x[ISO_NUMBER], x[SIZE], x[QUANTITY], x[LENGTH], x[DESCRIPTION]] }
      @fabrication_pieces_as_array.group_by { |x| x[DESCRIPTION] }.each { |key, values| csv << ["", "", values.size, "", key] }
    end
    csv_content
  end
end
