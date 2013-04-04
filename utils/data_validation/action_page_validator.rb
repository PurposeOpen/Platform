class ActionPageValidator
 def initialize(movement)
   @test_results = File.open("tmp/action_page_validator_results.txt", 'w')
   action_pages = ActionPage.published.where(:movement_id => movement)
   action_pages.each do |action_page|
     movement.languages.each do |language|
       begin
       do_tests("/#{language.iso_code}/actions/#{action_page.slug}") if action_page.language_enabled?(language)
       rescue Exception => e
         write_to_file("FAILURE, #{action_page.slug}, #{e.message}")
      end
     end
   end
   @test_results.flush
   @test_results.close
   @test_results = File.open("tmp/action_page_validator_results.txt", 'r')
   @test_results.each_line {|l| p l}
 end

 def do_tests(action_page_url)
   https=Net::HTTP.new("allout-production.herokuapp.com", 443)
   https.use_ssl=true
   https.start do |http|
     resp = http.get(action_page_url)
     status_code = resp.code
      status_code == "200" ?  write_to_file("SUCCESS, #{action_page_url}, #{status_code}") : write_to_file("FAILURE, #{action_page_url}, #{status_code}, #{resp.header['location']}")
   end
 end

 def write_to_file(message)
  @test_results.write("#{message}\n\r")
 end
end
