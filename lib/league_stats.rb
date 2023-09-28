module LeagueStats
  
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
end