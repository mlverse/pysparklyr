# Print method works

    Code
      print(invoke(sc, "sql", "select * from mtcars limit 5"))
    Message <cliMessage>
      - PySpark object
        pyspark.sql.connect.dataframe.DataFrame
        DataFrame[mpg: double, cyl: double, disp: double, hp: double, drat: double,
        wt: double, qsec: double, vs: double, am: double, gear: double, carb: double]

