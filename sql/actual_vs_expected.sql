-- 50,000 simulated policies sold at the net premium: how often did a policy lose money,
-- against the model's probability of loss? Each policy charges exactly its expected cost,
-- so the total PV loss should be close to zero relative to the premiums.
SELECT
  plan,
  policies,
  ROUND(actual_share_losing, 4)   AS actual_share_losing,
  ROUND(expected_share_losing, 4) AS expected_share_losing,
  ROUND(total_pv_loss / 1e6, 2)   AS total_pv_loss_m
FROM v_actual_vs_expected
ORDER BY plan;
