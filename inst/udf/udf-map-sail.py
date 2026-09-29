import rpy2.robjects as robjects
from rpy2.robjects import pandas2ri
from rpy2.robjects.conversion import localconverter

# Sail runs the UDF on its own threads, and `rpy2` keeps its conversion rules
# per thread, so every `rpy2` call is inside `localconverter()`
def r_apply(iterator):
    converter = robjects.default_converter + pandas2ri.converter
    with localconverter(converter):
        r_func = robjects.r('''function(...) 1''')
    for pdf in iterator:
        with localconverter(converter):
            ret = r_func(pdf)
            yield robjects.conversion.rpy2py(ret)
