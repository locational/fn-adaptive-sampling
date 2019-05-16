function(params) {
  # Individual check for each parameter
  if (is.null(params[['point_data']])) {
    stop('Missing `point_data` parameter')
  }
  # TODO: Check GeoJSON Features have required properties
  
  # if batch_size exists, must be a number > 0
  if (!is.null(params[['batch_size']])) {
    if (!is.numeric(params[['batch_size']])) {
      stop('Parameter `batch_size` is not numeric')
    }

    if (params[['batch_size']] < 1) {
      stop('Parameter `batch_size` must be greater than zero')
    }
  }
}