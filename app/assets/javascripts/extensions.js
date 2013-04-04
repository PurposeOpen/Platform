function toggleCheckBox(checkBox) {
  // need this function because on Chrome triggering 'click' or 'change' won't
  // update a check box's checked attribute until the listeners are done running

  $(checkBox)[0].checked = !$(checkBox)[0].checked;
  $(checkBox).triggerHandler("click");
  $(checkBox).triggerHandler("change");
}