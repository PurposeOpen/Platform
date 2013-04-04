class ReindexAllPlatformUsersByMovement < ActiveRecord::Migration
  def up
    PlatformUser.reindex; Sunspot.commit
  rescue
    # Can't find SOLR. That's okay.
  end

  def down
    PlatformUser.reindex; Sunspot.commit
  rescue
    # Can't find SOLR. That's okay.
  end
end
