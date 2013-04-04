beforeEach(function() {
  jasmine.getFixtures().fixturesPath = "/__spec__/fixtures/";
  
  this.addMatchers({
    toBePlaying: function(expectedSong) {
      var player = this.actual;
      return player.currentlyPlayingSong === expectedSong && 
             player.isPlaying;
    }
  });
});
