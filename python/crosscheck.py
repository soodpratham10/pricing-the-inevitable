"""Recompute the R engine's key results in Python and compare them.

Run from the project root, after source("python/export_r_values.R") in R:
    python3 python/crosscheck.py
"""
import csv
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import inevitable as iv  # noqa: E402

m = iv.mortality_law()
q = iv.q_path(m, 40)
i = 0.045
S = 250000
P = iv.net_premium("whole_life", q, i, S)

python_values = {
    "q40": q[0],
    "e40": iv.curtate_ex(q),
    "e65": iv.curtate_ex(iv.q_path(m, 65)),
    "A40": iv.epv("whole_life", q, i),
    "a40": iv.epv("whole_due", q, i),
    "var_A40": iv.product_moments("whole_life", q, i)["var"],
    "endowment_40_20": iv.epv("endowment", q, i, n=20),
    "deferred_annuity_40": iv.epv("deferred_whole_due", q, i, h=25),
    "a12_udd_40": iv.annuity_due_mthly_udd(q, i, 12),
    "premium_whole_life": P,
    "premium_wl_20_pay": iv.net_premium("whole_life", q, i, S, t=20),
    "premium_term_20": iv.net_premium("term", q, i, S, n=20, t=20),
    "prob_loss_whole_life": iv.prob_loss("whole_life", q, i, S, P),
    "percentile_premium": iv.percentile_premium("whole_life", q, i, S, alpha=0.05),
    "portfolio_premium": iv.portfolio_premium("whole_life", q, i, S, N=1000, alpha=0.05),
    "refund_premium_20": iv.refund_premium(q, i, S, 20),
    "hedge_ratio": iv.natural_hedge(m),
    "rate_WL_40_standard": iv.plan_premium(m, 40, "WL"),
    "rate_T20_40_smoker": iv.plan_premium(m, 40, "T20", "Smoker", "Monthly"),
    "rate_DA65_40": iv.plan_premium(m, 40, "DA65"),
}

path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "r_values.csv")
if not os.path.exists(path):
    sys.exit("python/r_values.csv not found: run source('python/export_r_values.R') in R first.")

with open(path, newline="") as f:
    r_values = {row["name"]: float(row["r_value"]) for row in csv.DictReader(f)}

passed = 0
print(f"{'Quantity':24s} {'R':>22s} {'Python':>22s} {'Rel. diff':>11s}  Result")
for name, r in r_values.items():
    p = float(python_values[name])
    rel = abs(p - r) / max(abs(r), 1e-12)
    ok = rel < 1e-9
    passed += ok
    print(f"{name:24s} {r:22.12f} {p:22.12f} {rel:11.2e}  {'PASS' if ok else 'CHECK'}")
print(f"\n{'ALL PASS' if passed == len(r_values) else 'SOME CHECKS FAILED'}: {passed} of {len(r_values)}")
