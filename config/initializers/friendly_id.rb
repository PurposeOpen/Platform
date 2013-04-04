# We have had problems with highly nested resources in /admin.
# Removing FriendlyID's override of #to_param will let Rails use numeric IDs by default.
# FriendlyID's human-readable versioned slugs will still be recognized when we explicity use them in a URL
# as removing #to_param will not affect the hooks in ActiveRecord#find.;
#FriendlyId::ActiveRecordAdapter::SluggedModel.send(:alias_method, :to_friendly_param, :to_param)
#FriendlyId::ActiveRecordAdapter::SluggedModel.send(:remove_method, :to_param)

#You can re-enable FriendlyId on a per-class basis by including models to this array
#CLASSES_TO_ENABLE = [Event]
#CLASSES_TO_ENABLE.each do |klass|
#  klass.send(:define_method, :to_param) do
#    to_friendly_param
#  end
#end
