library(RANN)

function(params) {
  # 1. Handle input
  candidates_geojson = params[['point_data']]
  batch_size = if is.null(params[['batch_size']]) 1 else params[['batch_size']]

  # 2. Process
  candidates = st_read(as.json(candidates_geojson)) # creates sf object

  candidates$uncertainty_prob <- candidates$uncertainty / sum(candidates$uncertainty)
  
  in_sample <- sample(1:nrow(candidates), 1, prob = candidates$uncertainty_prob)
  
  # Loop
  
  if (batch_size > 1) {
    for (i in 1:(batch_size - 1)) {
      candidates_in_sample <- candidates[in_sample,]
      candidates_not_in_sample <- candidates[-in_sample,]
      
      # First calc distance between the in_sample and the rest
      nn <- nn2(st_coordinates(candidates_in_sample), st_coordinates(candidates_not_in_sample))
      
      # convert distances to selection probability
      min_dist_to_other_points <- apply(nn$nn.dists, 1, min)
      min_dist_to_other_points <- min_dist_to_other_points / sum(min_dist_to_other_points)
      
      # Multiply by entropy
      candidates_not_in_sample$pen_entropy <-
        candidates_not_in_sample$entropy_prob * min_dist_to_other_points #* mean_dist_to_nearest_neighbours_inv
      candidates_not_in_sample$pen_entropy_prob <-
        candidates_not_in_sample$pen_entropy / sum(candidates_not_in_sample$pen_entropy)
      
      # Sample
      entropy_sample <-
        sample(1:nrow(candidates_not_in_sample),
               1,
               prob = candidates_not_in_sample$pen_entropy_prob)
      next_site <- candidates_not_in_sample$id[entropy_sample]
      samp_prob <-
        c(samp_prob, candidates_not_in_sample$pen_entropy_prob[entropy_sample])
      samp_entropy <-
        c(samp_entropy, candidates_not_in_sample$entropy[entropy_sample])
      samp_entropy_prob <-
        c(samp_entropy_prob,
          candidates_not_in_sample$entropy_prob[entropy_sample])
      in_sample <- c(in_sample, next_site)
    }
  }
  




  # 3. Package response

  # Return just the 'sample'
  response = candidates[in_sample, 1:ncol]
  
  return(response)
}
