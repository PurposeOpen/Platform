VALID_EMAIL_REGEX = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+$/
VALID_NAME_REGEX = /^[A-Za-z0-9._+\-\s']+$/
VALID_PHONE_REGEX = /^\+?[0-9\s\(\)-]+$/
VALID_POSTCODE_REGEX = /^\d\d\d\d$/

URL_REGEX_HTML = /[^>|\s]https?\:\/\/[^"]+/m
URL_REGEX_PLAIN_TEXT = /https?\:\/\/([a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/+\S+)?)/m