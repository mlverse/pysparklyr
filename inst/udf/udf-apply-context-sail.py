import pandas as pd
import rpy2.robjects as robjects
from rpy2.robjects import pandas2ri
from rpy2.robjects.conversion import localconverter

# Sail runs the UDF on its own threads, and `rpy2` keeps its conversion rules
# per thread, so every `rpy2` call is inside `localconverter()`
def r_apply(context):
  def r_run(pdf: pd.DataFrame) -> pd.DataFrame:
          converter = robjects.default_converter + pandas2ri.converter
          with localconverter(converter):
              r_func = robjects.r('''function(...) 1''')
              ret = r_func(pdf, context)
              return robjects.conversion.rpy2py(ret)
  return r_run
