require_relative 'creators'
require_relative 'game_stats'
require_relative 'league_stats'
require_relative 'season_stats'
require_relative 'game'
require_relative 'teams'
require_relative 'game_team'
require_relative 'helper'


class StatTracker
  attr_reader :locations,
              :team_data, 
              :game_data, 
              :game_teams_data

  include GameStats
  include LeagueStats
  include SeasonStats
  include Creators
  include Helper

  
  def initialize(locations)
    @game_data = create_games(locations[:games])
    @game_teams_data = create_game_teams(locations[:game_teams])
    @team_data = create_teams(locations[:teams])
  end

  def self.from_csv(locations)
    StatTracker.new(locations)
  end
end