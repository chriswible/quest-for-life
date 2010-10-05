$(function() {
  $("form:not(.filter) :input:visible:enabled:first").focus();
  $("p.start-survey-prompt a").click(function(e) {
    $(this).closest('form').trigger('submit'); 
    e.preventDefault();
  });
  setUpForm();
});
 
function makeScrollable(wrapper, scrollable){
	// Get jQuery elements
	var wrapper = $(wrapper), scrollable = $(scrollable);
  scrollable.hide();
	// Set function that will check if all images are loaded
	var interval = setInterval(function(){
			clearInterval(interval);
			// Timeout added to fix problem with Chrome
			setTimeout(function(){		
      scrollable.slideDown('slow', function(){
        enable();	
      });					
    }, 1000);	
	}, 100);
	
	function enable(){			
		// height of area at the top and bottom, that don't respond to mousemove
		var inactiveMargin = 50;
		// Cache for performance
		var wrapperWidth = wrapper.width();
		var wrapperHeight = wrapper.height();
		// Using outer height to include padding too
		var scrollableHeight = scrollable.outerHeight() + 2*inactiveMargin;
		// Do not cache wrapperOffset, because it can change when user resizes window
		// We could use onresize event, but it's just not worth doing that 
		// var wrapperOffset = wrapper.offset();
		
		//When user move mouse over area			
		wrapper.mousemove(function(e){
			var wrapperOffset = wrapper.offset();
			// Scroll menu
			var top = (e.pageY -  wrapperOffset.top) * (scrollableHeight - wrapperHeight) / wrapperHeight - inactiveMargin;	
			if (top < 0){
				top = 0;
			}
			wrapper.scrollTop(top);
		});
	}
	
} // end make scrollable


function setUpForm() {
  $("div.tab-body form").change(function(){
    $(this).ajaxSubmit({ 
      target: '#chart-results',
      beforeSubmit: hideCurrentChart, 
      success: showNewChart 
    }); 
    return false;
  });
}
function hideCurrentChart(formData, jqForm, options) { 
    var queryString = $.param(formData);
    $('#chart-results').slideUp('slow');
    return true; 
}
function showNewChart(responseText, statusText, xhr, $form)  { 
  buildChart();
  $('#chart-results').slideDown('slow');
}
