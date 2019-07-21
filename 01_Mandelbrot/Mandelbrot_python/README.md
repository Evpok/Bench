## How to run

1. (optional) create and activate a virtualenv `python3.7 -m venv .virtenv && source .virtenv/bin/activate`
2. install the requirements and build the extensions `pip install -e .`
3. run the benchmark `python Mandelbrot.py`

## Results

On my laptop

```
Vanilla python: 346.992529624913ms
Numba JIT: 0.7551998749022459ms
Cython (naive): 15.273452499968698ms, ndiff=6, max=10
Cython (optimized): 0.7935131250178529ms, ndiff=8, max=17
Cython (parallel): 0.37001012515247567ms, ndiff=8, max=17
```