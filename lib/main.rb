require 'csv'
require 'erb'
require 'google/apis/civicinfo_v2'

#API key: AIzaSyAZeJSg80FP6AjOoJhwLLLhhkNKfcYZA0A


def fix_zip(code)
  if code.nil?
    code = "00000"
  elsif code.length > 5
    code[0..4]
  else
    code.rjust(5, "0")
  end
end

def legislators_from_zip(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = "AIzaSyAZeJSg80FP6AjOoJhwLLLhhkNKfcYZA0A"
  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody'],	
    )	
    legislators = legislators.officials
    legislator_names = legislators.map(&:name)
    legislator_names.join(", ")
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def save_letter(id, form_letter)
  Dir.mkdir("output") unless Dir.exists?("output") # create a directory for letters
  filename = "output/thanks_#{id}.html"
  File.open(filename, "w") do |file| #write each letter to a separate file
    file.puts form_letter
  end
end

puts "EventManager initialised!"

contents = CSV.open("event-attendees.csv", headers:true, header_converters: :symbol)

template_letter = File.read("form_letter.erb")
erb_template = ERB.new(template_letter)

contents.each do |row|
  id = row[0] # the index serves as id
  name = row[:first_name]
  zip = fix_zip(row[:zipcode])
  #puts "#{name} #{zip}"  
  legislators = legislators_from_zip(zip)
  form_letter = erb_template.result(binding) # generate the letter
  #puts form_letter
  #puts "\n#{name} #{zip} #{legislators}"
  save_letter(id, form_letter)
end
