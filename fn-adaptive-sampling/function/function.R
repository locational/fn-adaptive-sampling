library(RANN)

function(params) {
  ncol <- ncol(candidates)
  candidates$entropy <- entropy
  candidates$entropy_prob <- entropy / sum(entropy)
  
  # Optional - you can transform probability to make it even more likely to sample high entropy areas
  #candidates$entropy_prob <- candidates$entropy_prob^8 / sum(candidates$entropy_prob^8)
  
  candidates$id <- 1:nrow(candidates)
  
  in_sample <-
    sample(1:nrow(candidates), 1, prob = candidates$entropy_prob)
  samp_prob <-
    samp_entropy_prob  <- candidates$entropy_prob[in_sample]
  samp_entropy <- candidates$entropy[in_sample]
  
  if (batch_size > 1) {
    for (i in 1:(batch_size - 1)) {
      candiates_in_sample <- candidates[in_sample,]
      candiates_not_in_sample <- candidates[-in_sample,]
      
      # First calc distance between the in_sample and the rest
      nn <-
        nn2(candiates_in_sample[, c("lng", "lat")], candiates_not_in_sample[, c("lng", "lat")])
      
      # convert distances to selection probability
      min_dist_to_other_points <- apply(nn$nn.dists, 1, min)
      min_dist_to_other_points <-
        min_dist_to_other_points / sum(min_dist_to_other_points)
      
      # Calc mean distance between each potential site and its 10 nearest neighbours
      # mean_dist_to_nearest_neighbours <- nn2(candiates_not_in_sample[,c("lng", "lat")], candiates_not_in_sample[,c("lng", "lat")])$nn.dist[,2:10]
      # mean_dist_to_nearest_neighbours_inv <- 1 / apply(mean_dist_to_nearest_neighbours, 1, mean)
      # mean_dist_to_nearest_neighbours_inv <- mean_dist_to_nearest_neighbours_inv / sum(mean_dist_to_nearest_neighbours_inv)
      
      # Multiply by entropy
      candiates_not_in_sample$pen_entropy <-
        candiates_not_in_sample$entropy_prob * min_dist_to_other_points #* mean_dist_to_nearest_neighbours_inv
      candiates_not_in_sample$pen_entropy_prob <-
        candiates_not_in_sample$pen_entropy / sum(candiates_not_in_sample$pen_entropy)
      
      # Optional weight to add to probability sample
      # candiates_not_in_sample$pen_entropy_prob <- candiates_not_in_sample$pen_entropy_prob^3 /
      #  sum(candiates_not_in_sample$pen_entropy_prob^3)
      
      # Sample
      entropy_sample <-
        sample(1:nrow(candiates_not_in_sample),
               1,
               prob = candiates_not_in_sample$pen_entropy_prob)
      next_site <- candiates_not_in_sample$id[entropy_sample]
      samp_prob <-
        c(samp_prob, candiates_not_in_sample$pen_entropy_prob[entropy_sample])
      samp_entropy <-
        c(samp_entropy, candiates_not_in_sample$entropy[entropy_sample])
      samp_entropy_prob <-
        c(samp_entropy_prob,
          candiates_not_in_sample$entropy_prob[entropy_sample])
      in_sample <- c(in_sample, next_site)
    }
  }
  
  # Return just the 'sample'
  response = candidates[in_sample, 1:ncol]
  
  return(response)
}
