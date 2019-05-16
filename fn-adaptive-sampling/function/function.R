library(RANN)
library(sf)

function(params) {
  # 1. Handle input
  candidates_geojson = params[['point_data']]
  batch_size = if (is.null(params[['batch_size']])) 1 else params[['batch_size']]

  # 2. Process
  candidates = st_read(as.json(candidates_geojson), quiet=T) # creates sf object
  candidates$uncertainty_prob <- candidates$uncertainty / sum(candidates$uncertainty)

  in_sample <- sample(1:nrow(candidates), 1, prob = candidates$uncertainty_prob)
  
  candidates_in_sample <- candidates[in_sample,]
  candidates_not_in_sample <- candidates[-in_sample,]
  # Loop
  
  if (batch_size > 1) {
    for (i in 1:(batch_size - 1)) {

      # First calc distance between the in_sample and the rest
      nn <- nn2(st_coordinates(candidates_in_sample), st_coordinates(candidates_not_in_sample))
      
      # convert distances to selection probability
      min_dist_to_other_points <- apply(nn$nn.dists, 1, min)
      min_dist_to_other_points <- min_dist_to_other_points / sum(min_dist_to_other_points)
      
      # Multiply by entropy
      candidates_not_in_sample$pen_uncertainty <- 
        candidates_not_in_sample$uncertainty_prob * min_dist_to_other_points
      
      candidates_not_in_sample$uncertainty_prob <- 
        candidates_not_in_sample$pen_uncertainty / sum(candidates_not_in_sample$pen_uncertainty)
      
      # Sample
      uncertainty_sample <- sample(1:nrow(candidates_not_in_sample), 1, prob = candidates_not_in_sample$uncertainty_prob)
      candidates_in_sample <- rbind(candidates_in_sample, candidates_not_in_sample[uncertainty_sample,-"pen_uncertainty"])
      candidates_not_in_sample <- candidates_not_in_sample[-uncertainty_sample,]
    }
  }

  # 3. Package response

  # Return just the 'sample'
  return(candidates_in_sample)
}
