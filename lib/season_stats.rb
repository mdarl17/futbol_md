module SeasonStats
  
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
end