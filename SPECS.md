# fn-adaptive-sampling

Take a GeoJSON FeatureCollection of points with observations and prediction points, with uncertainty values from model predictions, and we'll recommend the next n sites to survey in order to minimize uncertainty when updating the same model.

Designed to be used with `fn-prevalence-predictor`.

## Parameters

A nested JSON object containing:
- `point_data` - {GeoJSON FeatureCollection} Required.
- `uncertainty_fieldname` - name of properties field which contains uncertainty value
- `batch_size` - {integer} Representing the number of locations to adaptively sample. Defaults to 1.

The value of the `uncertainty_fieldname` can be zero or NA, but those points will be excluded from the sample. The batch size cannot be larger than the number of points with an uncertainty value greater than zero.

## Constraints

- maximum number of points/features
- maximum number of layers is XX
- can only include points within a single country

## Response

GeoJSON FeatureCollection with number of features equal to batch_size representing the recommended survey locations.
