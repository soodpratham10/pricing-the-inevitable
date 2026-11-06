-- Pricing the Inevitable: the back end of a small quoting system
-- Rebuilt from scratch by sql/build_database.R

DROP VIEW IF EXISTS v_rate_card;
DROP VIEW IF EXISTS v_class_loading;
DROP VIEW IF EXISTS v_monthly_cost;
DROP VIEW IF EXISTS v_actual_vs_expected;
DROP TABLE IF EXISTS quote;
DROP TABLE IF EXISTS policy;
DROP TABLE IF EXISTS model_risk;
DROP TABLE IF EXISTS rate;
DROP TABLE IF EXISTS risk_class;
DROP TABLE IF EXISTS plan;
DROP TABLE IF EXISTS assumption;

-- The pricing basis
CREATE TABLE assumption (
  name  TEXT PRIMARY KEY,
  value REAL NOT NULL,
  note  TEXT
);

-- What an agent can sell
CREATE TABLE plan (
  plan    TEXT PRIMARY KEY,
  label   TEXT NOT NULL,
  product TEXT NOT NULL
);

-- How underwriting adjusts mortality
CREATE TABLE risk_class (
  class  TEXT PRIMARY KEY,
  method TEXT NOT NULL,
  value  REAL
);

-- The rate book: premium per 1,000 of benefit
CREATE TABLE rate (
  plan                TEXT    NOT NULL REFERENCES plan (plan),
  issue_age           INTEGER NOT NULL,
  class               TEXT    NOT NULL REFERENCES risk_class (class),
  frequency           TEXT    NOT NULL CHECK (frequency IN ('Annual', 'Monthly')),
  premium_per_1000    REAL    NOT NULL,   -- total premium for a year
  instalment_per_1000 REAL    NOT NULL,   -- each payment
  PRIMARY KEY (plan, issue_age, class, frequency)
);

-- The model's probability that one policy makes a loss at the annual net premium
CREATE TABLE model_risk (
  plan      TEXT    NOT NULL,
  issue_age INTEGER NOT NULL,
  class     TEXT    NOT NULL,
  prob_loss REAL    NOT NULL,
  PRIMARY KEY (plan, issue_age, class)
);

-- 50,000 simulated policies, each followed to the end of its life
CREATE TABLE policy (
  policy_id        INTEGER PRIMARY KEY,
  plan             TEXT    NOT NULL REFERENCES plan (plan),
  issue_age        INTEGER NOT NULL,
  class            TEXT    NOT NULL,
  sum_assured      REAL    NOT NULL,   -- yearly income for the deferred annuity
  annual_premium   REAL    NOT NULL,
  curtate_lifetime INTEGER NOT NULL,   -- complete years lived after issue
  pv_benefit       REAL    NOT NULL,
  pv_premium       REAL    NOT NULL,
  loss             REAL    NOT NULL    -- pv_benefit - pv_premium
);

-- Every quote the desk has given
CREATE TABLE quote (
  quote_id       INTEGER PRIMARY KEY AUTOINCREMENT,
  quoted_at      TEXT    NOT NULL,
  plan           TEXT    NOT NULL,
  issue_age      INTEGER NOT NULL,
  class          TEXT    NOT NULL,
  frequency      TEXT    NOT NULL,
  sum_assured    REAL    NOT NULL,
  annual_premium REAL    NOT NULL,
  instalment     REAL    NOT NULL
);

-- Views: the rate book as an agent would read it

-- Standard annual rates per 1,000, one column per plan
CREATE VIEW v_rate_card AS
SELECT
  issue_age,
  ROUND(MAX(CASE WHEN plan = 'WL'   THEN premium_per_1000 END), 2) AS WL,
  ROUND(MAX(CASE WHEN plan = 'WL20' THEN premium_per_1000 END), 2) AS WL20,
  ROUND(MAX(CASE WHEN plan = 'T10'  THEN premium_per_1000 END), 2) AS T10,
  ROUND(MAX(CASE WHEN plan = 'T20'  THEN premium_per_1000 END), 2) AS T20,
  ROUND(MAX(CASE WHEN plan = 'E20'  THEN premium_per_1000 END), 2) AS E20,
  ROUND(MAX(CASE WHEN plan = 'DA65' THEN premium_per_1000 END), 2) AS DA65
FROM rate
WHERE class = 'Standard' AND frequency = 'Annual'
GROUP BY issue_age;

-- Each class's annual premium relative to Standard
CREATE VIEW v_class_loading AS
SELECT
  r.plan,
  r.issue_age,
  r.class,
  r.premium_per_1000 / s.premium_per_1000 AS relative_to_standard
FROM rate AS r
JOIN rate AS s
  ON s.plan = r.plan AND s.issue_age = r.issue_age
 AND s.class = 'Standard' AND s.frequency = r.frequency
WHERE r.frequency = 'Annual';

-- How much more a year costs when it is paid monthly
CREATE VIEW v_monthly_cost AS
SELECT
  a.plan,
  a.issue_age,
  a.class,
  a.premium_per_1000                            AS annual_premium,
  m.instalment_per_1000                         AS monthly_instalment,
  m.premium_per_1000 / a.premium_per_1000 - 1   AS extra_cost
FROM rate AS a
JOIN rate AS m
  ON m.plan = a.plan AND m.issue_age = a.issue_age AND m.class = a.class
 AND m.frequency = 'Monthly'
WHERE a.frequency = 'Annual';

-- Did the simulated policies lose money as often as the model said they would?
CREATE VIEW v_actual_vs_expected AS
SELECT
  p.plan,
  COUNT(*)                                            AS policies,
  AVG(CASE WHEN p.loss > 0 THEN 1.0 ELSE 0.0 END)     AS actual_share_losing,
  AVG(r.prob_loss)                                    AS expected_share_losing,
  SUM(p.loss)                                         AS total_pv_loss
FROM policy AS p
JOIN model_risk AS r
  ON r.plan = p.plan AND r.issue_age = p.issue_age AND r.class = p.class
GROUP BY p.plan;
