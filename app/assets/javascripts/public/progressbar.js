function progressBar(progressBarSelector, goal) {
	var goalValue = goal;
	var currentValue = 0;
	var theProgressBar = $(progressBarSelector);
  
	function updateProgressBar() {
		  currentValue++;
		  
		  theProgressBar.progressbar({value: currentValue});
		  
		  if (currentValue < goalValue) { 
		    setTimeout(updateProgressBar, 20); 
		  }
	  }

	updateProgressBar();
}