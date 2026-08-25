import pandas as pd
import rpy2.robjects as robjects
from rpy2.robjects import pandas2ri
from rpy2.robjects.conversion import localconverter

def r_apply(pdf: pd.DataFrame) -> pd.DataFrame:
  # `pandas2ri.activate()` raises a DeprecationWarning as of rpy2 3.6.0.
  # Checked here, not at import, so it sees the worker's rpy2 version.
  import re
  from importlib.metadata import version
  rpy2_version = re.findall(r"\d+", version("rpy2"))[:2]
  if len(rpy2_version) == 2 and tuple(int(x) for x in rpy2_version) < (3, 6):
      pandas2ri.activate()
  r_func =robjects.r('''function(...) 1''')
  with localconverter(robjects.default_converter + pandas2ri.converter):
          ret = r_func(pdf)
          return robjects.conversion.rpy2py(ret)
