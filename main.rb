require 'csv'

def fix_zip(code)
	if code.nil?
		code = "00000"
	elsif code.length > 5
		code[0..4]
	else
		code.rjust(5, "0")
	end
end

puts "EventManager initialised!"

contents = CSV.open("event-attendees.csv", headers:true, header_converters: :symbol)

contents.each do |row|
	name = row[:first_name]
	zip = fix_zip(row[:zipcode])
	puts "#{name}: #{zip}"
end
