-- The extra cost of paying monthly instead of once a year (Standard class).
-- Paying in instalments means the insurer waits for its money and stops collecting at death.
SELECT
  plan,
  ROUND(100 * MIN(extra_cost), 2) AS lowest_extra_pct,
  ROUND(100 * AVG(extra_cost), 2) AS average_extra_pct,
  ROUND(100 * MAX(extra_cost), 2) AS highest_extra_pct
FROM v_monthly_cost
WHERE class = 'Standard'
GROUP BY plan
ORDER BY average_extra_pct DESC;
