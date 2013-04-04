jQuery.validator.addMethod(
    "platformDate", function (value, element) {
      return ((this.optional(element)) || (/^\d{1,2}[\/]\d{1,2}[\/]\d{4}$/.test(value)));
    }, function () {
        return "Invalid date format";
    }
);

jQuery.validator.addMethod(
    "maxDate", function (value, element, param) {
        return ((this.optional(element)) || (new Date(param) >= new Date(value)));
    }, function (param) {
        return "Please select a date before " + param.split(" ")[0];
    }
);

jQuery.validator.addMethod(
    "maxServerDate", function (value, element) {
      return ((this.optional(element)) || (minimumBlastScheduleTime >= new Date(value)));
    }, function () {
        return "Please select a date before " + minimumBlastScheduleTime.toISOString().split("T")[0];
    }
);   
