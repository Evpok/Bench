import timeit

import numpy as np
from numba import jit

import CMandelbrot


def compute_mandelbrot(output, maxVal, centerXY, rangeXY):
    xMin = centerXY[0] - rangeXY[0] / 2
    xMax = centerXY[0] + rangeXY[0] / 2
    yMin = centerXY[1] - rangeXY[1] / 2
    yMax = centerXY[1] + rangeXY[1] / 2

    xStep = (xMax - xMin) / (output.shape[1] - 1)
    yStep = (yMax - yMin) / (output.shape[0] - 1)

    for y in range(output.shape[0]):
        yVal = np.float32(y * yStep + yMin)

        for x in range(output.shape[1]):
            xVal = np.float32(x * xStep + xMin)
            zRe = np.float32(0)
            zIm = np.float32(0)
            zRe2 = np.float32(0)
            zIm2 = np.float32(0)
            zReIm = np.float32(0)
            val = np.float32(0)

            while True:
                zReIm = zRe * zIm
                (zRe, zIm) = (zRe2 - zIm2 + xVal, zReIm + zReIm + yVal)
                zRe2 = zRe * zRe
                zIm2 = zIm * zIm

                if val >= maxVal or zIm2 + zRe2 >= 4.0:
                    break

                val += 1

            output[y][x] = val


def print_result(output):
    for y in range(output.shape[0]):
        for x in range(output.shape[1]):
            print(chr(32 + (output[y][x] & 63)), end="")
        print()


def evaluate(funct, width, height, maxVal, centerXY, rangeXY, repeat):
    output = np.ndarray((height, width), dtype=np.int32)

    def run():
        funct(output, maxVal, centerXY, rangeXY)

    timer = timeit.Timer(stmt=run, setup=run)
    runtime = min(timer.repeat(number=repeat))
    ms_mean = 1000 * runtime / repeat

    return output, ms_mean


if __name__ == "__main__":
    width = 100
    height = 25
    maxVal = 256
    repeat = 8
    centerXY = (-0.5, 0)
    rangeXY = (3, 2)

    testcases = (
        (compute_mandelbrot, "Vanilla python"),
        (jit(compute_mandelbrot, nopython=True), "Numba JIT"),
        (CMandelbrot.compute_mandelbrot, "Cython"),
    )

    ref_output = np.ndarray((height, width), dtype=np.int32)
    compute_mandelbrot(ref_output, maxVal, centerXY, rangeXY)
    for funct, name in testcases:
        output, runtime = evaluate(
            funct, width, height, maxVal, centerXY, rangeXY, repeat
        )
        delta = np.abs(ref_output - output)
        ndiff = np.count_nonzero(delta)
        print(
            f"{name}: {runtime}ms"
            + (f", ndiff={ndiff}, max={delta.max()}" if ndiff else "")
        )
    # print_result(ref_output)

