function donationAsk() {

  function selectPaymentMethod(method) {
    $('.ask-module input.payment-method').attr('value', method);
    $('div.donation_module .payment-method-fields').each(function(index, container) {
      var this_div_methods = $(container).attr('data-payment-methods');
      if (this_div_methods !== null && this_div_methods.indexOf(method) != -1) {
	if ($(this).is("li")) {
	  $(this).show();
	} else {
	  $(this).fadeIn();
	}
      } else {
	$(this).hide();
      }
    });
    $('input.ask-submit-button').attr('data-payment-method', method);
  }

  function paymentMethod() {
    return $('.ask-module input.payment-method').attr('value');
  }

  function selectedAmount() {
    var value = null;
    $("#amount .suggested input:checked").each(function() {
      value = $(this).attr("value");
    });
    if (value === null) {
      /* no selection: return "other" value */
      value = $("#donation_custom_amount_in_dollars").attr("value");
    }
    return value;
  }

  function donateButtonClicked(event) {
    var method = paymentMethod();
    if (method == "paypal") {
      event.preventDefault();
      /*event.stopPropagation();*/
      var amount = selectedAmount();
      if (amount > 0) {
	$('#paypal-occult-form input[name=amount]').remove(); /* just in case */
	var input = "<input type='hidden' name='amount' value='"+amount+"'>";
	$('#occult-paypal-form').append(input);
      }
      $('#occult-paypal-form').submit();
    }
  }

  $('#payment-method-list a.method').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    selectPaymentMethod($(this).attr('data-payment-method'));
  });

  var otherAmountRadioButton = $('#donation_amount_in_dollars_other');
  var customAmountInput = $('#donation_custom_amount_in_dollars');

  customAmountInput.focus(function() {
    otherAmountRadioButton.attr("checked", true);
  });
  
  otherAmountRadioButton.click(function() {
    customAmountInput.focus();
  });

  $('input.ask-submit-button').click(donateButtonClicked);

  /* hack to override non-js default: jQuery defaults to block for .show */
  $('#payment-method-list .hide-by-default').css('display', 'inline').hide();

  /* configure form */
  selectPaymentMethod(paymentMethod());
}

$(function() {
  if ($('.module.donation_module').size() > 0) {
    donationAsk();
  }  
});