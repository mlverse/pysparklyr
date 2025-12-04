import pandas as pd
import rpy2.robjects as robjects
from rpy2.robjects import pandas2ri
from rpy2.robjects.conversion import localconverter

def r_apply(pdf: pd.DataFrame) -> pd.DataFrame:
  pandas2ri.activate()
  r_func =robjects.r('''function(...) 1''')
  with localconverter(robjects.default_converter + pandas2ri.converter):
          ret = r_func(pdf)
          return robjects.conversion.rpy2py(ret)
