module GameStats

  def highest_total_score
    most_goals_game = Game.games.reduce(0) do |goals, game|
      game_goals = game.home_goals.to_i + game.away_goals.to_i
      goals = game_goals > goals ? game_goals : goals
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

  def percentage_home_wins
    home_wins = GameTeam.gametqeam.count do |game|
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
    GameTeam.gameteam.each do |row|
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

end