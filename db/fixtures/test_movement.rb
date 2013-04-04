require 'seed_data'
require 'seed_data/test_movement'

SeedData.seed_movement(
    :name => "Test Movement",
    :url => "http://test_movement.org",
    :seeder_class => SeedData::TestMovement,
    :seed => :once
)