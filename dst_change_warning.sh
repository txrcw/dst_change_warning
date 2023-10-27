#!/bin/bash
set -e

# Set to run every Wednesday at noon (PST/PDT). 
# When DST is updated, so is the name of the timezone. 
# If the name of the time zone for the current time is different
# from the one 7 days from now, that means we change time.
# Send me a reminder email when this happens.

SHIFT_START_TIME_SOFIA="16:00"
CURRENT_SOFIA_TIME=$(TZ=Europe/Sofia date)
# Test
# CURRENT_SOFIA_TIME=$(TZ=Europe/Sofia date --date="4 weeks ago")
CURRENT_SOFIA_TIMEZONE=$(TZ=Europe/Sofia date --date="$CURRENT_SOFIA_TIME" +"%Z")
EXPECTED_SOFIA_TIME=$(TZ=Europe/Sofia date --date="$CURRENT_SOFIA_TIME +7 days")
EXPECTED_SOFIA_TIMEZONE=$(TZ=Europe/Sofia date --date="$EXPECTED_SOFIA_TIME" +"%Z")

SHIFT_START_TIME_FRESNO="6:00am"
CURRENT_FRESNO_TIME=$(TZ=America/Los_Angeles date)
# Test
# CURRENT_FRESNO_TIME=$(TZ=America/Los_Angeles date --date="4 weeks ago")
CURRENT_FRESNO_TIMEZONE=$(TZ=America/Los_Angeles date --date="$CURRENT_FRESNO_TIME" +"%Z")
EXPECTED_FRESNO_TIME=$(TZ=America/Los_Angeles date --date="$CURRENT_FRESNO_TIME +7 days")
EXPECTED_FRESNO_TIMEZONE=$(TZ=America/Los_Angeles date --date="$EXPECTED_FRESNO_TIME" +"%Z")

EMAILBODY="\n\n"
TIMEZONE_CHANGE_DETECTED=0
NEXT_MONDAY_DATE=$(date --date="$next monday" +"%B %d")
# Test
# NEXT_MONDAY_DATE=$(date --date="20230313" +"%B %d")

if [ "$CURRENT_FRESNO_TIMEZONE" != "$EXPECTED_FRESNO_TIMEZONE" ]
then
  TIMEZONE_CHANGE_DETECTED=1
  NEW_SHIFT_START_TIME=$(TZ=Europe/Sofia date --date="$NEXT_MONDAY_DATE $SHIFT_START_TIME_FRESNO $EXPECTED_FRESNO_TIMEZONE" +"%H:%M %Z")
  EMAILBODY+="Timezone change detected: $CURRENT_FRESNO_TIMEZONE --> $EXPECTED_FRESNO_TIMEZONE. On $NEXT_MONDAY_DATE, you need to log in at $NEW_SHIFT_START_TIME.\n\n" 
fi


if [ "$CURRENT_SOFIA_TIMEZONE" != "$EXPECTED_SOFIA_TIMEZONE" ]
then
  TIMEZONE_CHANGE_DETECTED=1
  NEW_SHIFT_START_TIME=$(TZ=Europe/Sofia date --date="$NEXT_MONDAY_DATE $SHIFT_START_TIME_FRESNO $EXPECTED_FRESNO_TIMEZONE" +"%H:%M %Z")
  EMAILBODY+="Timezone change detected: $CURRENT_SOFIA_TIMEZONE --> $EXPECTED_SOFIA_TIMEZONE. On $NEXT_MONDAY_DATE, you need to log in at $NEW_SHIFT_START_TIME.\n\n" 
fi

if [ $TIMEZONE_CHANGE_DETECTED == 1 ]
then
  SUBJECT="Time change approaching"
  RECIPIENTS="daniel.karadaliev@forsta.com"
  echo -e $EMAILBODY | mailimp -s "$SUBJECT" $RECIPIENTS
fi
