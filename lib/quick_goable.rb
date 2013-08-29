module QuickGoable
  def self.included(base)
    base.searchable do
      text :name_stored_text_substring, :stored => true do 
        name
      end 
      integer :movement_id, :stored => true do
        respond_to?(:movement_id) ? send(:movement_id) : movement.try(:id) #TODO 'try' can be removed once we fix data with foreign keys.
      end
      string :to_param, :stored => true
    end
    base.handle_asynchronously :solr_index
  end
end
