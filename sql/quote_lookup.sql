-- The desk at work: quote a 40-year-old smoker $250,000 of 20-year term, paid monthly,
-- log the quote, and show the latest quotes.
INSERT INTO quote (quoted_at, plan, issue_age, class, frequency, sum_assured, annual_premium, instalment)
SELECT datetime('now'), plan, issue_age, class, frequency, 250000,
       ROUND(premium_per_1000 * 250, 2), ROUND(instalment_per_1000 * 250, 2)
FROM rate
WHERE plan = 'T20' AND issue_age = 40 AND class = 'Smoker' AND frequency = 'Monthly';

SELECT quote_id, plan, issue_age, class, frequency, sum_assured, annual_premium, instalment
FROM quote
ORDER BY quote_id DESC
LIMIT 5;
