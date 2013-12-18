# Zenoss-4.x JSON API Example (python)
#
# Curses-based event console.
#
# A very simple example showing use of the Zenoss JSON API. Program initializes
# the screen, and fetches the top events from a Zenoss server. The events are
# displayed in decending severity, with severities color-coded. Events update
# every 5 seconds or so. Use 'q' or 'Q' to quit.

import curses
import time
import api_example
import os
import csv

# Set up colors


# Initialize Zenoss API connection
z = api_example.ZenossAPIExample()
eventslog=open('./tmp/events.log', 'w+')
faillog=open('./tmp/faillog.log','w')
cycles = 21
with open('./tmp/eggs.csv', 'wb') as csvfile:
	csvwriter = csv.writer(csvfile, quoting=csv.QUOTE_MINIMAL)
	# Only update every 20 cycles (20 * .25 seconds = 5 seconds)
	if cycles > 20:
		# Get events from Zenoss
		rawEvents = z.get_events()['events']
		# 'Clean' events list, initialized with title row
		events = [['Device', 'Component', 'Summary', 'Event Class']]
		# Initialize title row color to 0 (white on black)
		inc = 0
		for x in rawEvents:		
			inc+=1
			if inc <= 20:
				print([str(x['severity']),str(x['lastTime']), str(x['device']['text']), str(x['component']['text']), str(x['summary'])])
				#print >>eventslog, '"'+str(x['severity']) + '","' + str(x['device']['text']) + '","' + str(x['component']['text']) + '","' + str(x['summary'])+'"'
				csvwriter.writerow([str(x['severity']),str(x['lastTime']), str(x['device']['text']), str(x['component']['text']), str(x['summary'])])




