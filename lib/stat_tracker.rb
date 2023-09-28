# require_relative './spec_helper'
require_relative 'creators'
require_relative 'game_stats'
require_relative 'league_stats'
require_relative 'season_stats'
require_relative 'game'
require_relative 'teams'
require_relative 'game_team'


class StatTracker
  attr_reader :locations, :team_data, :game_data, :game_teams_data

  include GameStats
  include LeagueStats
  include SeasonStats
  include Creators

  def initialize(locations)
    @game_data = create_games(locations[:games])
    @game_teams_data = create_game_teams(locations[:game_teams])
    @team_data = create_teams(locations[:teams])
  end


  # def create_games(path)
  #   data = CSV.parse(File.read(path), headers: true, header_converters: :symbol)
  #   data.map do |row|
  #     Game.new(row)
  #   end
  # end

  # def create_game_teams(path)
  #   data = CSV.parse(File.read(path), headers: true, header_converters: :symbol)
  #   data.map do |row| 
  #     GameTeam.new(row)
  #   end
  # end

  # def create_teams(path)
  #   data = CSV.parse(File.read(path), headers: true, header_converters: :symbol)
  #   data.map do |row|
  #     Team.new(row)
  #   end
  # end

  # def self.from_csv(locations)
  #   StatTracker.new(locations)
  # end

  # Helper Methods

  def percentage_calculator(portion=433.to_f, whole=744)
    percentage = (portion/whole).round(2)
  end

  def team_info
    teams = GameTeam.gameteam.group_by {|team| team.team_id}
  end
  
  def find_game_with_season_id(season)
    game_ids = {}
    Game.games.each do |game|
      if game.season == season
        game_ids[game.game_id] = true
      end
    end
    game_ids.keys
  end

  def coach_win_loss(season_game_id)
    coach_win_hash = Hash.new(0)
    coach_loss_hash = Hash.new(0)
    coach_tie_hash = Hash.new(0)
    @game_teams_data.each do |game|
      games_by_season = season_game_id
      if games_by_season.include?(game.game_id)
        result = game.result
        if game.result == "WIN" 
          coach_win_hash[game.head_coach] += 1
        elsif game.result == "LOSS"
          coach_loss_hash[game.head_coach] += 1
        elsif game.result == "TIE"
          coach_tie_hash[game.head_coach] += 1
        end
      end
    end
    win_percentage(coach_win_hash, coach_loss_hash, coach_tie_hash)
  end
         
  def total_games(wins, losses, ties)
    total_games = wins.merge(losses) do |key, wins, losses|
      wins + losses + ties[key].to_i
    end
  end
  
  def win_percentage(wins, losses, ties)
    percentage = wins.merge(total_games(wins, losses, ties)) do |key, wins, total|
      (wins.to_f / total.to_f) * 100
    end
  end

  def goals_per_season_team(season)
    goals_per_season = game_teams_by_season(season).each_with_object(Hash.new(0)) { |game_team, hash| hash[game_team.team_id] += game_team.goals.to_i }
  end
  
  def shots_per_season_team(season)
    shots_per_season = game_teams_by_season(season).each_with_object(Hash.new(0)) { |game_team, hash| hash[game_team.team_id] += game_team.shots.to_i } 
  end
  
  def accuracy_by_team(goals, shots)
    accuracy = goals.merge(shots) { |team_id, goals_values, shots_values| goals_values.to_f / shots_values.to_f}
  end
  
  def game_teams_by_season(season)
    games_by_season = find_game_with_season_id(season)
    game_teams_data_by_season = []
    games_by_season.each do |game|
      GameTeam.gameteam.each do |game_team|
        game_teams_data_by_season.push(game_team) if game == game_team.game_id
      end
    end
    game_teams_data_by_season
  end

  def team_tackles(season)
    sort_by_season = game_teams_by_season(season)
    tackles_by_team = Hash.new(0)
    game_teams_by_season(season).each do |game_team|
      tackles_by_team[game_team.team_id] += game_team.tackles.to_i
    end
    tackles_by_team
  end

  def team_goals(home_or_away)
    teams = GameTeam.gameteam.group_by { |row| row.team_id}
    hoa_hash = { home: Hash.new(0), away: Hash.new(0)}
    teams.each do |team, data_array|
      data_array.each do |data|
        if data.hoa == "home" 
          hoa_hash[:home][team] += data.goals.to_i
        elsif data.hoa == "away"
          hoa_hash[:away][team] += data.goals.to_i
        end
      end
    end
    if home_or_away == "away"
      hoa_hash[:away]
    else 
      hoa_hash[:home]
    end
  end

  def games_by_team(team_side)
    teams = GameTeam.gameteam.group_by { |row| row.team_id }
    games = Hash.new
    teams.each do |team, data_array|
      game_location = data_array.select { |data| data.hoa == team_side}
      games[team] = game_location.count
    end
    games
  end

  def average_goals_per_team(team_side)
    team_goals(team_side)
    games_by_team(team_side)
    average_goals = Hash.new
    team_goals(team_side).each do |key, value|
      if games_by_team(team_side)[key]
        average_goals[key] = (value.to_f / games_by_team(team_side)[key].to_f).round(3) 
      end
    end
    average_goals
  end

  def get_team_info(team_id)
    team = Team.teams.find do |team|
      team.team_id == team_id
    end
    {
      "team_id" => team.team_id,
      "franchise_id" => team.franchise_id,
      "team_name" => team.team_name,
      "abbreviation" => team.abbreviation,
      "link" => team.link
    }
  end
end

