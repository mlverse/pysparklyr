import rpy2.robjects as robjects
from rpy2.robjects import pandas2ri
from rpy2.robjects.conversion import localconverter

def r_apply(iterator):
    r_func = robjects.r('''function(...) 1''')
    converter = robjects.default_converter + pandas2ri.converter
    for pdf in iterator:
        with localconverter(converter):
            ret = r_func(pdf)
            yield robjects.conversion.rpy2py(ret)
