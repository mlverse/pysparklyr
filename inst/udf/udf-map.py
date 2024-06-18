import rpy2.robjects as robjects
from rpy2.robjects import pandas2ri
def r_apply(iterator):
  for pdf in iterator:
    pandas2ri.activate()
    r_func = robjects.r('''function(...) 1''')
    ret = r_func(pdf)
    yield pandas2ri.rpy2py_dataframe(ret)
