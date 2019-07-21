cimport cython

cdef inline int compute_single(float xVal, float yVal, int maxVal) nogil:
    cdef float zRe = xVal
    cdef float zIm = yVal
    cdef float zRe2 = xVal*xVal
    cdef float zIm2 = yVal*yVal
    cdef float zReIm = 0.  # Don't need it right now
    cdef int val = 0

    while val < maxVal and zIm2 + zRe2 < 4:
        zReIm = zRe * zIm
        (zRe, zIm) = (zRe2 - zIm2 + xVal, zReIm + zReIm + yVal)
        zRe2 = zRe * zRe
        zIm2 = zIm * zIm
        val += 1

    return val

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
def compute_mandelbrot(int[:, :] output not None, int maxVal, (float, float) centerXY, (int, int) rangeXY):
    cdef Py_ssize_t X = output.shape[1]
    cdef Py_ssize_t Y = output.shape[0]
    cdef float xMin = centerXY[0] - rangeXY[0] / 2
    cdef float xMax = centerXY[0] + rangeXY[0] / 2
    cdef float yMin = centerXY[1] - rangeXY[1] / 2
    cdef float yMax = centerXY[1] + rangeXY[1] / 2

    cdef float xStep = (xMax - xMin) / (X - 1)
    cdef float yStep = (yMax - yMin) / (Y - 1)

    cdef Py_ssize_t x, y
    for y in range(Y):
        yVal = y * yStep + yMin
        xVal = xMin
        for x in range(X):
            output[y][x] = compute_single(xVal, yVal, maxVal)
            xVal += xStep
