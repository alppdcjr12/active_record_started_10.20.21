namespace :prune_urls do
  task prune_urls: :environment do
    puts "Pruning old URLs..."
    n_minutes_ago = 10.minutes.ago
    ShortenedUrl
      .joins("LEFT JOIN 'visits' ON 'visits'.'url_id' = 'shortened_urls'.'id'")
      .joins("LEFT JOIN 'users' ON 'visits'.'user_id' = 'users'.'id'")
      .group(:short_url)
      .where("'shortened_urls'.'created_at' < ?", n_minutes_ago)
      .where("'users'.'premium' = ?", false)
      .having(
        "max(visits.created_at) < ? OR visits.created_at IS NULL",
        n_minutes_ago
      ).destroy_all
    puts "Prune complete."
  end
end