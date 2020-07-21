require 'csv'

puts "EventManager initialised!"


contents = CSV.open("event-attendees.csv", headers:true, header_converters: :symbol)

contents.each do |row|
	puts row[:first_name]
end
