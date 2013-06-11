module Reporting
 def report(text, buffer = STDOUT, options = {})
   buffer.print text
   buffer.print (options[:keep] ? "\n" : "\r")
   buffer.flush
 end
end
