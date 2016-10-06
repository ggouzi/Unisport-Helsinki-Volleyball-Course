# ruby_unisport_check_send_sms
A ruby script which check if a new volleyball course corresponding to your preferences is available and send you a sms to be the first registered

This script checks continuously the webpage https://unisport.fi/?page=liikumeilla#62826542.<br/>
It will send a sms to one or several phone numbers if:
- A new course registration has opened
- This new course matches with your preferences <Day,Location> (See preferences.txt)
<br/>
If there is no more reservations left, it will send a sms explaining that the course is already full.

## Principe
- Checking new courses online
- Send sms if a new course registration has opened and matches with your preferences (Using Twilio API: https://www.twilio.com)

## Needed gems
- twilio-ruby

## License
This project is licensed under the GNU GPL v2. See GPL.txt for details.
