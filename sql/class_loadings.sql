-- How much each underwriting class pays relative to Standard, averaged over issue ages.
-- Smokers pay more for insurance but less for the deferred annuity: they are expected
-- to collect it for fewer years.
SELECT
  plan,
  class,
  ROUND(AVG(relative_to_standard), 3) AS avg_relative,
  ROUND(MIN(relative_to_standard), 3) AS lowest,
  ROUND(MAX(relative_to_standard), 3) AS highest
FROM v_class_loading
WHERE class <> 'Standard'
GROUP BY plan, class
ORDER BY plan, avg_relative;
