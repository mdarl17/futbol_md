# require_relative './spec_helper'
require_relative './game'
require_relative './game_team'
require_relative './teams'

class StatTracker
  attr_reader :locations, :team_data, :game_data, :game_teams_data

  def initialize(locations)
    @game_data = create_games(locations[:games])
    @game_teams_data = create_game_teams(locations[:game_teams])
    @team_data = create_teams(locations[:teams])
  end

  # CREATOR METHODS

  def create_games(path)
    data = CSV.parse(File.read(path), headers: true, header_converters: :symbol)
    data.map do |row|
      Game.new(row)
    end
    # require 'pry'; binding.pry
  end

  def create_game_teams(path)
    data = CSV.parse(File.read(path), headers: true, header_converters: :symbol)
    data.map do |row| 
      GameTeam.new(row)
    end
  end

  def create_teams(path)
    data = CSV.parse(File.read(path), headers: true, header_converters: :symbol)
    data.map do |row|
      Team.new(row)
    end
  end

  def self.from_csv(locations)
    StatTracker.new(locations)
  end

  # GAME STATISTICS

  def highest_total_score
    most_goals_game = Game.games.reduce(0) do |goals, game|
      game_goals = game.home_goals.to_i + game.away_goals.to_i
      if game_goals > goals
        goals = game_goals
      end
      goals
    end
    most_goals_game
  end

  def lowest_total_score
    fewest_goals_game = Game.games.reduce(0) do |goals, game|
      game_goals = game.home_goals.to_i + game.away_goals.to_i
      if game_goals < goals
        goals = game_goals
      end
      goals
    end
    fewest_goals_game
  end
  #hm
  def percentage_calculator(portion, whole)
    percentage = (portion/whole).round(2)
  end

  def percentage_home_wins
    home_wins = GameTeam.gameteam.count do |game|
      game.hoa == "home" && game.result == "WIN"
    end 
    (home_wins.to_f / Game.games.count.to_f).round(2)
  end

  def percentage_visitor_wins
    away_wins = GameTeam.gameteam.count do |game|
      game.hoa == "away" && game.result == "WIN"
    end 
    (away_wins.to_f / Game.games.count.to_f).round(2)
  end

  def percentage_ties 
    ties = Game.games.count do |game|
      game.away_goals.to_f == game.home_goals.to_f
    end.to_f
    (ties/Game.games.count).round(2)
  end

  def count_of_games_by_season 
    games_seasons = Hash.new(0)
    Game.games.each do |row|
      season = row.season
      games_seasons[season] += 1
    end 
    games_seasons

  end

  def average_goals_per_game
    total_goals = 0
    total_games = []
    Gameteam.gameteam.each do |row|
      total_goals += row.goals.to_i
      total_games << row.game_id
    end
    average = total_goals.to_f / total_games.uniq.count
    average.round(2)
  end

  def average_goals_by_season
    season_hash = Game.games.group_by{|game| game.season }
    av_goals = {}
    season_hash.each do |season,games|
      total_goals = games.map {|game| game.home_goals.to_i + game.away_goals.to_i}
      av_goals[season] = (total_goals.sum.to_f / games.length).round(2)
    end
    av_goals
  end
  
  def count_of_teams
    teams = Team.teams.group_by { |team| team.team_name}
    teams.keys.compact.count
  end

  def best_offense
    total_team_goals_hash = {}
    team_goals("home").each do |team_id, home_goals|
    total_team_goals_hash[team_id] = [
      home_goals + team_goals("away")[team_id],
      GameTeam.gameteam.find_all do |game|
        game.team_id == team_id
      end.count
    ]
    end 
    team_name_avg_goals = []
    total_team_goals_hash.each do |team, gls_gms_arr|
      team_name_avg_goals << [get_team_info(team)['team_name'], ((gls_gms_arr.first.to_f/gls_gms_arr.last.to_f)*100/100).round(3)]
    end
    team_name_avg_goals.max_by do |team_arr|
      team_arr.last
    end.first
  end
  
  def worst_offense
    total_team_goals_hash = {}
    team_goals("home").each do |team_id, home_goals|
      total_team_goals_hash[team_id] = [
        home_goals + team_goals("away")[team_id],
        @game_teams_data.find_all do |game|
          game.team_id == team_id
        end.count
      ]
    end 
    team_name_avg_goals = []
    total_team_goals_hash.each do |team, gls_gms_arr|
      team_name_avg_goals << [get_team_info(team)['team_name'], ((gls_gms_arr.first.to_f/gls_gms_arr.last.to_f)*100/100).round(3)]
    end
    team_name_avg_goals.min_by do |team_arr|
      team_arr.last
    end.first
  end
  
  def highest_scoring_visitor
    avg_goals_away_team = average_goals_per_team("away")
    highest_a_avg = average_goals_per_team("away").values.max
    team_identifier = avg_goals_away_team.key(highest_a_avg)
    team_highest_a_avg = Team.teams.find do |team|
      team_identifier == team.team_id
    end
    team_highest_a_avg.team_name
  end
  
  def highest_scoring_home_team
    avg_goals_home_team = average_goals_per_team("home")
    highest_h_avg = average_goals_per_team("home").values.max
    team_identifier = avg_goals_home_team.key(highest_h_avg)
    team_highest_h_avg = Team.teams.find do |team|
      team_identifier == team.team_id
    end
    team_highest_h_avg.team_name
  end

  def lowest_scoring_visitor
    avg_away_team = average_goals_per_team("away")
    lowest_a_avg = average_goals_per_team("away").values.min
    team_identifier = avg_away_team.key(lowest_a_avg)
    team_lowest_a_avg = Team.teams.find do |team|
      team_identifier == team.team_id
    end
    team_lowest_a_avg.team_name
  end

  def lowest_scoring_home_team
    avg_goals_home = average_goals_per_team("home")
    lowest_h_avg = average_goals_per_team("home").values.min
    team_identifier = avg_goals_home.key(lowest_h_avg)
    team_lowest_h_avg = Team.teams.find do |team|
      team_identifier == team.team_id
    end
    team_lowest_h_avg.team_name
  end

  def winningest_coach(season)
    season_game_id = find_game_with_season_id(season)
    highest_percent = coach_win_loss(season_game_id).values.max
    best = coach_win_loss(season_game_id).key(highest_percent) 
  end

  def worst_coach(season)
    season_game_id = find_game_with_season_id(season)
    lowest_percent = coach_win_loss(season_game_id).values.min
    worst = coach_win_loss(season_game_id).key(lowest_percent) 
  end
  
  def most_accurate_team(season)
    goals = goals_per_season_team(season)
    shots = shots_per_season_team(season)
    accuracy = accuracy_by_team(goals, shots)
    team_id_most_accurate = accuracy.key(accuracy.values.max) 
    team_with_most_accuracy = @team_data.find do |team|
      team_id_most_accurate == team.team_id
    end
    team_with_most_accuracy.team_name
  end

  def least_accurate_team(season)
    goals = goals_per_season_team(season)
    shots = shots_per_season_team(season)
    accuracy = accuracy_by_team(goals, shots)
    team_id_least_accurate = accuracy.key(accuracy.values.min) 
    team_with_least_accuracy = @team_data.find do |team|
      team_id_least_accurate == team.team_id
    end
    team_with_least_accuracy.team_name
  end

  def most_tackles(season)
    tackles_by_team = team_tackles(season)
    team_id_most_tackles = tackles_by_team.max_by {|team_id, tackles| tackles}
    team_most_tackles = Team.teams.find do |team|
      team_id_most_tackles.first == team.team_id
    end
    team_most_tackles.team_name
  end  
  
  def fewest_tackles(season)
    tackles_by_team = team_tackles(season)
    team_id_least_tackles = tackles_by_team.min_by {|team_id, tackles| tackles}
    team_least_tackles = Team.teams.find do |team|
      team_id_least_tackles.first == team.team_id
    end
    team_least_tackles.team_name
  end

  # Helper Methods

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
  
  def average_goals_per_game
    total_goals = 0
    total_games = []
    GameTeam.gameteam.each do |row|
      total_goals += row.goals.to_i
      total_games << row.game_id
    end
    average = total_goals.to_f / total_games.uniq.count
    average.round(2)
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

  def percentage_calculator(portion, whole)
    percentage = (portion/whole).round(2)
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

