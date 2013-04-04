function distanceOfTimeInWords(fromTime, toTime, includeTime) {
  var delta = parseInt((toTime.getTime() - fromTime.getTime()) / 1000);
  if (delta < 60) {
      return delta + ' seconds ago';
  } else if (delta < 120) {
      return 'a minute ago';
  } else if (delta < (45*60)) {
      return (parseInt(delta / 60)).toString() + ' minutes ago';
  } else if (delta < (120*60)) {
      return 'an hour ago';
  } else if (delta < (24*60*60)) {
      return (parseInt(delta / 3600)).toString() + ' hours ago';
  } else if (delta < (48*60*60)) {
      return '1 day ago';
  } else {
    var days = (parseInt(delta / 86400)).toString();
    return days + " days ago"
  }
}

function distanceOfTimeInWordsToNow(fromTime) {
  return distanceOfTimeInWords(fromTime, new Date()); 
}