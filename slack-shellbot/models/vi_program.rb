class ViProgram < Program
  field :filename, type: String
  field :data, type: String

  belongs_to :file_entry

  validates_presence_of :filename

  def to_s
    ensure_data
    [data, '~|', "\n", footer].compact.join("\n")
  end

  before_validation :ensure_data

  def message(client, request)
    ensure_data
    text, = SlackRubyBot::Commands::Base.send(:parse, client, request)
    match = text.match(/^(?<bot>\S*)[\s]*(?<expression>.*)$/)
    expression = match['expression'] if match.names.include?('expression')
    case expression
    when ':q' then
      terminate!
      "quit without saving #{path}"
    when ':wq' then
      file_system.current_directory_entry.write(filename, data)
      terminate!
      "written #{path}, #{lines} line(s), #{data.length} character(s)"
    else
      update_attributes!(data: [data, expression].join("\n"))
      save!
      to_s
    end if expression
  end

  private

  def ensure_data
    self.data ||= load_data
  end

  def path
    ensure_data
    file_entry ? file_entry.path : Entry.combine_path(file_system.current_directory_entry.path, filename)
  end

  def footer
    ensure_data
    [
      "\"#{path}\"",
      data && data.length > 0 ? "#{lines} line(s), #{data.length} character(s)" : '[New File]'
    ].join(' ')
  end

  def lines
    ensure_data
    data.split("\n").count if data && data.length
  end

  def load_data
    self.file_entry ||= file_system.current_directory_entry.find(filename)
    self.file_entry.data
  rescue Errno::ENOENT
  end
end
