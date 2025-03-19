import pandas as pd
import rpy2.robjects as robjects
from rpy2.robjects import pandas2ri
def r_apply(context) :
  def r_run(pdf: pd.DataFrame) -> pd.DataFrame:
    pandas2ri.activate()
    r_func =robjects.r('''function(...) 1''')
    ret = r_func(pdf)
    return pandas2ri.rpy2py_dataframe(ret)
  return r_run
