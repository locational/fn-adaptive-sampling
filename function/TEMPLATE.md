# Locational OpenFaas function

## Cloning specific template version

If you've just cloned this repo, you'll need to get the matching template in order to successfully build the container. 

1. Check the `TEMPLATE_VERSION` file.
1. To download the correct template, run `faas template pull https://github.com/locational/faas-templates.git#<TEMPLATE_VERSION>`

## Debugging a function

Make sure you've cloned the right template version (see above).

If you need to debug/test something that relies on e.g. `index.py` or `preprocess_helpers.py`, easiest seems to be to run `faas build`, and then check the repo's folder - there should be a new ` build` folder. Inside there is a copy of the code in a more complete form, ready to run. Don't make changes inside the `build` folder though, they will be lost: just edit the normal source and rerun `faas build`. (If the Docker build step is taking any time, you should able to kill the command, and still find the `build` folder updated).


## Updating the templates

Either `rm -rf template`, or `faas template pull https://github.com/locational/faas-templates.git --overwrite`.

Beware that newer versions of the templates won't necessarily build the same function - e.g. they might have different input-handling code, or structure the output differently.