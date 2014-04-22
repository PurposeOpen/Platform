$.fn.blasts = function () {
    var scope = $(this);

    scope.find("input[type=radio]").change(function () {
        var radio = $(this),
            radioContainer = radio.closest(".radio-container"),
            radioLabels = radioContainer.find(".radio-label");

        radioLabels.addClass("disabled").find(".radio-option-input").attr("disabled", "disabled");
        radio.parent('.radio-label').removeClass("disabled").find(".radio-option-input").removeAttr("disabled").focus();
    });

    scope.find("[name=run_now]").change(function () {
        toggleTimezoneOptions();
    });

    scope.find("li.blast .in-progress").each(function (index, elem) {
        var countdownElem = $(elem).find(".countdown");
        var abort = $(elem).find(".button.abort");
        var until = parseFloat(countdownElem.html());
        initBlastCountdown(countdownElem, abort, until);
    });

    scope.find('.run_at').each(function (index, element) {
        $(element).datepicker({
            dateFormat: 'yy-mm-dd', 
            minDate: minimumBlastScheduleTime,
            onClose:function (dateText, inst) {
                var timeSelector = $(inst.input).siblings('.run_at_time'),
                    optionsForSelect = "";
                timeSelector.selectBox('destroy');
                timeSelector.hide();
                if ($.isEmptyObject($.trim(dateText))) {
                    return;
                }
                $.each(optionsForTime(new Date(dateText)), function (index, time) {
                    optionsForSelect += "<option value='" + time + "'>" + time + "</option>";
                });
                timeSelector.html(optionsForSelect);
                timeSelector.selectBox('create');
            }
        });
    });
};

function toggleTimezoneOptions() {
    if ($('[name=run_now]:checked').val() === "true") {
        $('#timezone-options').hide();
    } else {
        $('#timezone-options').show();
    }
}


function padZero(val) {
    return (val < 10 ? '0' + val.toString() : val.toString());
}

function optionsForTime(selectedDate) {
    var timeOptions = [],
        startHour = 0, startMinute = 0,
        nextScheduleTime = new Date(minimumBlastScheduleTime),
        blastMinutes = minimumBlastScheduleTime.getMinutes(), i, j;

    nextScheduleTime.setMinutes(blastMinutes - blastMinutes % 15 + 30);
    if(selectedDate.getDate() == minimumBlastScheduleTime.getDate()) {
        startHour = nextScheduleTime.getHours();
    }

    for(i = startHour; i < 24; i++) {
        startMinute = (nextScheduleTime.getHours() == i) ? nextScheduleTime.getMinutes() : 0
        for(j = startMinute; j <= 45; j = j + 15) {
            timeOptions.push(padZero(i) + ":" + padZero(j));
        }
    }
    return timeOptions;
}


function initBlastCountdown(container, abort, until) {
    if (until <= 0) return deliveryInProgress();

    $(container).countdown({
        until:until,
        format:"HMS",
        layout:"<span class='timer'>{hnn}:{mnn}:{snn}<span>",
        onExpiry:deliveryInProgress
    });

    function deliveryInProgress() {
        container.addClass("sent").html("Emails sent!");
        abort.remove();
    }
}

$.page("#pushes_show", function () {
    $(".blasts").blasts();
});

$(document).ready(function () {
    toggleTimezoneOptions();
    $(".send-options").selectBox();
    window.setInterval(function () {
        minimumBlastScheduleTime.setMinutes(minimumBlastScheduleTime.getMinutes() + 1);
    }, 1000 * 60);
});
