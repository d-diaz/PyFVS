
python -c "import numpy;print('Numpy version:',numpy.version.version)"
pushd ${TRAVIS_BUILD_DIR}/bin/build/Open-FVS/python
python -m nose2

popd