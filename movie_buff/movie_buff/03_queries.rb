def what_was_that_one_with(those_actors)
  # Find the movies starring all `those_actors` (an array of actor names).
  # Show each movie's title and id.
  Movie
    .select(:id, :title)
    .joins(:actors)
    .where('actors.name' => those_actors, 'castings.ord' => 1)
end

def golden_age
  # Find the decade with the highest average movie score.
  Movie
    .select("AVG(score) AS average_movie_score, (CAST(FLOOR(yr/10)*10 AS VARCHAR) || '-' || CAST(FLOOR(yr/10)*10 + 9 AS VARCHAR)) AS decade")
    .group('FLOOR(yr/10)*10')
    .order('AVG(score) DESC')
    .limit(1)
end

def costars(name)
  # List the names of the actors that the named actor has ever
  # appeared with.
  # Hint: use a subquery
  Actor
    .select(:name)
    .distinct
    .joins(:castings)
    .where('castings.movie_id IN (SELECT movie_id FROM castings JOIN actors ON castings.actor_id = actors.id WHERE actors.name = ?)', name)
    .where('actors.name != ?', name)
end

def actor_out_of_work
  # Find the number of actors in the database who have not appeared in a movie
  Actor
    .left_outer_joins(:castings)
    .where('castings.actor_id IS NULL')
    .count
end

def starring(whazzername)
  # Find the movies with an actor who had a name like `whazzername`.
  # A name is like whazzername if the actor's name contains all of the
  # letters in whazzername, ignoring case, in order.

  # ex. "Sylvester Stallone" is like "sylvester" and "lester stone" but
  # not like "stallone sylvester" or "zylvester ztallone"

  name = '%' + whazzername.split("").join("%") + '%'
  Movie
    .joins(:actors)
    .where('actors.name LIKE ?', name)

end

def longest_career
  # Find the 3 actors who had the longest careers
  # (the greatest time between first and last movie).
  # Order by actor names. Show each actor's id, name, and the length of
  # their career.
  Actor
    .select('actors.id, name, (MAX(movies.yr) - MIN(movies.yr)) AS career_length')
    .joins(:movies)
    .group('actors.id')
    .order('career_length DESC')
    .limit(3)
end
