library(sf)

function(params) {
  # Individual check for each parameter
  if (is.null(params[['point_data']])) {
    stop('Missing `point_data` parameter')
  }

  point_data_sf = st_read(as.json(params[['point_data']]), quiet=T)
  params[['point_data_sf']] = point_data_sf

  rows_we_can_sample = sum(point_data_sf$uncertainty > 0 & !is.na(point_data_sf$uncertainty))
  if (params[['batch_size']] > rows_we_can_sample) {
    stop('Batch size is larger than the number of points for which uncertainty is available (greater than zero or not NA)')
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

  return(params)
}