#!/usr/bin/ruby
require 'json'
require 'date'
require 'mail'
require 'twilio-ruby'

$preferences_file = "preferences.txt"
# Replace with your personal data
$array_phone_number= ['+33...', '+358...', '+31...']
$sender_phone_number = '+33...'
$account_sid = '...' # Twilio account id
$auth_token = '...' # Twilio
 
# Each request occur after 5 to 15 min
$min_sleep = 5*60
$max_sleep = 15*60

def compute_message(array)
	messages = Array.new
	array.each do |item|
		if (item['actual_reservations']<item['max_reservations'])
			messages.push("Guys ! It is "+Time.now.strftime("%H:%M")+" and we can now book for Volleyball on "+item['day']+" "+item['date']+ " at "+item['location']+" ("+item['actual_reservations'].to_s+"/"+item['max_reservations'].to_s+") :) This is an automatic message")
		else
			messages.push("Guys ! It is "+Time.now.strftime("%H:%M")+" and the Volleyball course on "+item['day']+" "+item['date']+ " at "+item['location']+" is already full :/ This is an automatic message")
		end
	end
	return messages
end

def read_preferences(filename)
preferences = Array.new

File.open(filename, "r") do |f|
  f.each_line do |line|
    hash = Hash.new
    hash['day'] = line.split(' ')[0]
    hash['location'] = line.split(' ')[1]	

    preferences.push(hash)

  end
end
return preferences
end

def send_sms(array_messages)
# set up a client to talk to the Twilio REST API 
@client = Twilio::REST::Client.new $account_sid, $auth_token 
 
message = array_messages.join(' ')
$array_phone_number.each do |phone_num|
	@client.account.messages.create({
		:from => $sender_phone_number, 
		:to => phone_num, 
		:body => message
	})
end

end

possibilities = Array.new
preferences = read_preferences($preferences_file)
first_step = true

while (true)
	request = `curl 'https://unisport.fi/yol/web/fi/crud/read/anyEvent.json?activities=826542&minDate=TODAY&maxDate=TODAYPLUS6&past=false&details=true'`
	json = JSON.parse(request)

	delay = Random.rand($min_sleep...$max_sleep)

	temp_possibilities = Array.new

	puts

	json['items'].each do |child|
	    date_str =  child['startTime'].split('T')[0]
	    hour_str = child['startTime'].split('T')[1]
	    day_str = date_str.split('-')[2]+"/"+date_str.split('-')[1]+"/"+date_str.split('-')[0]
	    date = Date.parse day_str

	    p = Hash.new

	    p['day'] = date.strftime("%a")
	    p['date'] = day_str
	    p["hour"] = hour_str
	    p['location'] = child['venue'].split(' ')[0]
	    p["actual_reservations"] = child['reservations']
	    p["max_reservations"] = child['maxReservations']
	    p["instructors"] = child["instructors"]

	    temp_possibilities.push(p)
	end

	#puts possibilities
	new_possibilities = Array.new
	temp_possibilities.each do |temp| # Check if a new course registration has opened since the last iteration
		if (!possibilities.include? temp)
			is_same_course = false
			actual_registration = 0
			old_registration = 0
			possibilities.each do |poss|
				if(poss['day']==temp['day'] && poss['date']==temp['date'] && poss['hour']==temp['hour'] && poss['location']==temp['location']) # If it is the same course
					is_same_course = true
					actual_registration = temp['actual_reservations']
					old_registration = poss['actual_reservations']
				end
			end

			if(is_same_course && old_registration==temp['max_reservations'] && actual_registration<old_registration) # Same course but it's not full anymore
				new_possibilities.push(temp)
			elsif(!is_same_course) # Another course
				new_possibilities.push(temp)
			end
		end
	end

	if(new_possibilities.any? && !first_step)
		results = Array.new
		new_possibilities.each do |poss|
			preferences.each do |pref|
				# Check if the day of the week and the location are in the preferences list. Check if it's free playing (no instructor)
				if(pref['day'].downcase.start_with?(poss['day'].downcase) && poss['location'].downcase.start_with?(pref['location'].downcase) && !poss["instructors"].any?)
					results.push(poss)
				end
			end
		end
		messages = compute_message(results)
		puts messages
		#send_sms(messages)
	else
		puts "No new course"
	end
	first_step = false
	possibilities = temp_possibilities

	sleep delay

end




