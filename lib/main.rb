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

def fix_phone(num)
  num.gsub!(/-|\(|\)|\s|\./, "") # get rid of any -, ., ( ) or space
  if num.length < 10 || num.length > 11 || (num.length == 11 && num[0] != 1)
    return nil
  else
    if num.length == 11
      num = num[1..10]
    end
    return num[0..2] + "-" + num[3..5] + "-" + num[6..9]    
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
phone_list = File.open("output/phones.txt", "a")

contents.each do |row|
  id = row[0] # the index serves as id
  name = row[:first_name]
  zip = fix_zip(row[:zipcode])
  num = fix_phone(row[:homephone])
  if !num.nil?
    puts num
    phone_list.puts "#{name}: #{num}"
  else 
    puts "#{row[:homephone]} is invalid!"
  end
  #puts "#{name} #{zip}"  
  legislators = legislators_from_zip(zip)
  form_letter = erb_template.result(binding) # generate the letter
  #puts form_letter
  #puts "\n#{name} #{zip} #{legislators}"
  #save_letter(id, form_letter) 
end
