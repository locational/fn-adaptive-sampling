library(sf)

function(params) {
  # if batch_size exists, must be a number > 0
  if (!is.null(params[['batch_size']])) {
    if (!is.numeric(params[['batch_size']])) {
      stop('Parameter `batch_size` is not numeric')
    }
    
    if (params[['batch_size']] < 1) {
      stop('Parameter `batch_size` must be greater than zero')
    }
  } else {
    params[['batch_size']] = 1
  }
  
  
  
  # Individual check for each parameter
  if (is.null(params[['point_data']])) {
    stop('Missing required `point_data` parameter')
  }
  
  # Default value for uncertainty_fieldname
  if (is.null(params[['uncertainty_fieldname']])) {
    params[['uncertainty_fieldname']] = 'exceedance_uncertainty'
    write("set uncertainty_fieldname to default", stderr())
    write(params[["uncertainty_fieldname"]], stderr())
  }
  
  point_data = st_read(as.json(params[['point_data']]), quiet = T)
  params[['point_data']] = point_data
  
  # Check
  tryCatch({
    uncertainty_fieldname = params[['uncertainty_fieldname']]
    rows_we_can_sample = sum(!is.na(as.data.frame(point_data)[, uncertainty_fieldname]))
  }, error = function(e) {
    stop(paste0('Error finding `', uncertainty_fieldname, '` on records in `point_data`. ', 
        'Check the value of `uncertainty_fieldname` parameter, it should be a property on at least some of the `point_data`'))
  })
  if (params[['batch_size']] > rows_we_can_sample) {
    stop(
      'Batch size is larger than the number of points for which uncertainty is available (not NA)'
    )
  }
  
  
  # NOTE: Not all DiSARM functions use a `main.R` file that mutates the params. This one does.
  return(params)
}