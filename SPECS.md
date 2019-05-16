# fn-adaptive-sampling

Give us a bunch of GeoJSON points with observations, as well as a GeoJSON of prediction points with uncertainty values, and we'll recommend the next n sites to survey in order to minimize uncertainty.

Designed to be used with `fn-prevalence-predictor`.

## Parameters

A nested JSON object containing:
- `point_data` - {GeoJSON FeatureCollection} Required. With following property fields for each location:
  - `uncertainty` - uncertainty value
- `batch_size` - {integer} Representing the number of locations to adaptively sample. Defaults to 1.

## Constraints

- maximum number of points/features
- maximum number of layers is XX
- can only include points within a single country

## Response

GeoJSON FeatureCollection with number of features equal to batch_size representing the recommended survey locations.
