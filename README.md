# Unisport Helsinki VolleyBall course check

## Purpose
Script that periodically check [Volleyball Unisport web page](https://unisport.fi/?page=liikumeilla#62826542) and send text messages on your phone when there are availabilities corresponding to your preferences in order to be one of the first ones to be registered.

A ruby script which check if a new volleyball course corresponding to your preferences is available and send you a text message to be the first registered

This script checks continuously the webpage .<br/>
It will send a text message to one or several phone numbers if:
- A new course registration has opened
- This new course matches with your preferences <Day,Location> (See preferences.txt)
<br/>
If there is no more reservations left, it will send a text explaining the course is already full.

## Needed gems
- [twilio-ruby](https://www.twilio.com)
