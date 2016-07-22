var j$ = jQuery.noConflict();
    
// Want to validate if the Amount Field has a proper value in it. 
// isNewAmontField is for on addtion window, allows us to disable the save button. 
function validateAmountField(isNewAmountField) {
  var hasAmountError = true;
  var CURRENT_TARGET = j$(event.target);
  var AMOUNT_FIELD = isNewAmountField ? '.NewAmount' : '.Amount' ;
  var currentAmountField = CURRENT_TARGET.attr('class') == 'Amount' ? true : false;
  
  if( isNewAmountField && CURRENT_TARGET.attr('class') == 'NewAmount' ) {
      currentAmountField = true;
  }

  var numberPattern = new RegExp(/^[+-]?[0-9]{1,3}(?:,?[0-9]{3})*(?:\.[0-9]{2})?$/);

  if ( !numberPattern.test( j$(AMOUNT_FIELD).val()) ) {
    if( currentAmountField && CURRENT_TARGET.next().attr('id') != 'ErrorDiv') {
      CURRENT_TARGET.after("<div id='ErrorDiv' style='color: red;'> Please enter a valid Amount </div>");
    }

  } else {

    if( currentAmountField && CURRENT_TARGET.next().attr('id') === 'ErrorDiv') {
      CURRENT_TARGET.next().remove();
    }

    if( j$( AMOUNT_FIELD).val() != '' && j$( AMOUNT_FIELD).val() !== undefined  && j$( AMOUNT_FIELD).next().attr('id') != 'ErrorDiv') {
      hasAmountError = false;
    }
  }

  return hasAmountError;
}

// Want to validate if the Amount Field has a proper value in it. 
// isNewDateField is for on addtion window, allows us to disable the save button. 
function validateDateField(isNewDateField) {
  var hasDateError = true;
  var CURRENT_TARGET = j$(event.target);
  var DATE_FIELD = isNewDateField ? '.NewDate' : '.Date' ;
  var currentDateField = CURRENT_TARGET.attr('class') == 'Date' ? true : false;

  if( isNewDateField && CURRENT_TARGET.attr('class') == 'NewDate' ) {
      currentDateField = true;
  }
  
  var datePattern = new RegExp(/^(((((0[13578])|([13578])|(1[02]))[\-\/\s]?((0[1-9])|([1-9])|([1-2][0-9])|(3[01])))|((([469])|(11))[\-\/\s]?((0[1-9])|([1-9])|([1-2][0-9])|(30)))|((02|2)[\-\/\s]?((0[1-9])|([1-9])|([1-2][0-9]))))[\-\/\s]?\d{4})(\s(((0[1-9])|([1-9])|(1[0-2]))\:([0-5][0-9])((\s)|(\:([0-5][0-9])\s))([AM|PM|am|pm]{2,2})))?$/);
  if ( !datePattern.test( j$( DATE_FIELD).val()) ) {
    console.log('Passed Test DATE?');
    if( currentDateField && CURRENT_TARGET.parent().next().attr('id') != 'ErrorDiv' ) {
      CURRENT_TARGET.parent().after("<div id='ErrorDiv' style='color: red;'> Please enter a valid Date </div>");
    }

  } else {
    if( currentDateField && CURRENT_TARGET.parent().next().attr('id') === 'ErrorDiv') {
      CURRENT_TARGET.parent().next().remove();
    }
    if( j$( DATE_FIELD).val() != '' && j$( DATE_FIELD).val() !== undefined && j$( DATE_FIELD).parent().next().attr('id') != 'ErrorDiv') {
      hasDateError = false;
    }
  }

  return hasDateError;
}

// Want to validate if the fields have the proper value. 
// isNewField allows us to disable the save button, when adding a payment. 
function validate(isNewField) {

  var hasDateError = validateDateField(isNewField);
  var hasAmountError = validateAmountField(isNewField);
  
  var hasNewProjectError = true;
  if( j$('.NewProject').val() !== undefined && j$('.NewProject').val() !== '') {
    hasNewProjectError = false;
  }

  if( (hasAmountError || hasAmountError || hasNewProjectError)) {
    j$('[id$=addPaymentButton]').attr('disabled', 'true');
  }

  if (!hasAmountError && !hasDateError && !hasNewProjectError) {
     j$('[id$=addPaymentButton]').removeAttr('disabled');
  }
}