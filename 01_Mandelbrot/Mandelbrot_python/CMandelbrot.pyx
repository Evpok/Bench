import numpy as np
from cython.parallel import prange

cimport cython

cdef inline int compute_single(float xVal, float yVal, int maxVal) nogil:
    cdef float zRe = xVal
    cdef float zIm = yVal
    cdef float zRe2 = xVal*xVal
    cdef float zIm2 = yVal*yVal
    cdef float zReIm = 0.0  # Don't need it right now
    cdef int val = 0

    while val < maxVal and zIm2 + zRe2 < 4.0:
        zReIm = zRe * zIm
        (zRe, zIm) = (zRe2 - zIm2 + xVal, zReIm + zReIm + yVal)
        zRe2 = zRe * zRe
        zIm2 = zIm * zIm
        val += 1

    return val

def compute_mandelbrot_naive(output, maxVal, centerXY, rangeXY):
    xMin = centerXY[0] - rangeXY[0] / 2
    xMax = centerXY[0] + rangeXY[0] / 2
    yMin = centerXY[1] - rangeXY[1] / 2
    yMax = centerXY[1] + rangeXY[1] / 2

    xStep = (xMax - xMin) / (output.shape[1] - 1)
    yStep = (yMax - yMin) / (output.shape[0] - 1)

    for y in range(output.shape[0]):
        yVal = y * yStep + yMin

        for x in range(output.shape[1]):
            xVal = x * xStep + xMin
            zRe = 0.0
            zIm = 0.0
            zRe2 = 0.0
            zIm2 = 0.0
            zReIm = 0.0
            val = 0

            while True:
                zReIm = zRe * zIm
                (zRe, zIm) = (zRe2 - zIm2 + xVal, zReIm + zReIm + yVal)
                zRe2 = zRe * zRe
                zIm2 = zIm * zIm

                if val >= maxVal or zIm2 + zRe2 >= 4.0:
                    break

                val += 1

            output[y][x] = val


@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
def compute_mandelbrot_optimized(int[:, :] output not None, int maxVal, (float, float) centerXY, (int, int) rangeXY):
    cdef Py_ssize_t X = output.shape[1]
    cdef Py_ssize_t Y = output.shape[0]
    cdef float xMin = centerXY[0] - rangeXY[0] / 2
    cdef float xMax = centerXY[0] + rangeXY[0] / 2
    cdef float yMin = centerXY[1] - rangeXY[1] / 2
    cdef float yMax = centerXY[1] + rangeXY[1] / 2
    cdef float xVal = xMin
    cdef float yVal = yMin

    cdef float xStep = (xMax - xMin) / (X - 1)
    cdef float yStep = (yMax - yMin) / (Y - 1)

    cdef Py_ssize_t x, y
    for y in range(Y):
        yVal = y * yStep + yMin
        for x in range(X):
            xVal = x*xStep + xMin
            output[y][x] = compute_single(xVal, yVal, maxVal)


@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
def compute_mandelbrot_parallel(int[:, :] output not None, int maxVal, (float, float) centerXY, (int, int) rangeXY):
    cdef Py_ssize_t X = output.shape[1]
    cdef Py_ssize_t Y = output.shape[0]
    cdef float xMin = centerXY[0] - rangeXY[0] / 2
    cdef float xMax = centerXY[0] + rangeXY[0] / 2
    cdef float yMin = centerXY[1] - rangeXY[1] / 2
    cdef float yMax = centerXY[1] + rangeXY[1] / 2
    cdef float xVal = xMin
    cdef float yVal = yMin

    cdef float xStep = (xMax - xMin) / (X - 1)
    cdef float yStep = (yMax - yMin) / (Y - 1)

    cdef Py_ssize_t x, y
    for y in prange(Y, nogil=True):
        yVal = y * yStep + yMin
        for x in range(X):
            xVal = x*xStep + xMin
            output[y][x] = compute_single(xVal, yVal, maxVal)
