module ListCutter
  class DateRule < Rule
    @@date_operator_before = 'before'
    @@date_operator_after = 'after'
    @@date_operator_on = 'on'
    @@operator_hash = {@@date_operator_before => '<', @@date_operator_after => '>', @@date_operator_on => '='}

    def before?
      params_for_operator? @@date_operator_before
    end

    def after?
      params_for_operator? @@date_operator_after
    end

    def on?
      params_for_operator? @@date_operator_on
    end

    def query_operator
      mapped_operator = @@operator_hash[@params[:operator]]
      raise 'No operator found' if (operator_nil? or mapped_operator.nil?)
      mapped_operator
    end

    private

    def params_for_operator?(date_operator)
      @params[:operator] == date_operator unless operator_nil?
    end

    def operator_nil?
      @params[:operator].nil?
    end
  end
end
