require 'ics/config'
require 'ics/utils/extensions'
require 'ics/utils/error'

def puts_and_again opening, closing, options={}, &block
  options[:if] = true unless options.has_key?(:if)
  begin
    if options[:if]
      $stdout.write(opening)
      $stdout.flush
    end
    yield
  ensure
    if options[:if]
      $stdout.write("#{closing}\n")
      $stdout.flush
    end
  end
end


