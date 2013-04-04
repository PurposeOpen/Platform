class ApiResponse
  include ActiveModel::Validations
  include ActiveModel::Serialization
  
  def initialize
       @success = FALSE  
       @errors = Array.new
       @signatures = 0
  end
  
  def errors=(value)
    @errors << value
  end
  
  def signatures
    @signatures
  end
  
  
  attr_accessor :success
  attr_reader :errors
  attr_accessor :signatures
  
end