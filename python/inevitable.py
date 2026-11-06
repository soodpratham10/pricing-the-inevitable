"""A Python port of the core of the `inevitable` R package.

Written independently with numpy (no other packages) to cross-check the R engine.
Every function follows the R function of the same name.
"""
from math import exp, log
from statistics import NormalDist

import numpy as np

# ---------- Chapter 1: mortality ----------

def mortality_law(A=0.0002, B=0.000008, c=1.112):
    """Gompertz-Makeham law with the project's illustrative parameters."""
    return {"A": A, "B": B, "c": c}


def mu_x(m, x):
    return m["A"] + m["B"] * m["c"] ** np.asarray(x, float)


def tpx(m, x, t):
    t = np.asarray(t, float)
    return np.exp(-m["A"] * t - m["B"] * m["c"] ** x * (m["c"] ** t - 1) / log(m["c"]))


def q_path(m, x, select=None, extra=None, max_age=120):
    """One-year death probabilities from age x to the limiting age (last q = 1)."""
    xa = x + (extra["years"] if extra and extra["type"] == "age" else 0)
    K = max_age - x
    k = np.arange(K)
    q = np.clip(1 - tpx(m, xa + k, 1), 0, 1)
    if select is not None:
        f = np.asarray(select, float)
        s = min(len(f), K)
        q[:s] = q[:s] * f[:s]
    if extra is not None:
        if extra["type"] == "add_mu":
            q = 1 - (1 - q) * exp(-extra["delta"])
        elif extra["type"] == "mult_q":
            q = np.minimum(1, extra["k"] * q)
    q[-1] = 1.0
    return q


def kpx_from_q(q):
    return np.concatenate([[1.0], np.cumprod(1 - q)])


def curtate_pmf(q):
    return kpx_from_q(q)[:-1] * q


def curtate_ex(q):
    return kpx_from_q(q)[1:].sum()


# ---------- Chapters 2 and 3: products ----------

def annuity_certain(n, i, due=True):
    v = 1 / (1 + i)
    n = np.asarray(n, float)
    return (1 - v ** n) / (1 - v) if due else (1 - v ** n) / i


def pv_by_k(product, K, i, n=10, h=5):
    """Present value of the benefit for each curtate lifetime k = 0..K-1."""
    k = np.arange(K, dtype=float)
    v = 1 / (1 + i)
    ad = lambda m: annuity_certain(m, i, True)
    table = {
        "whole_life": lambda: v ** (k + 1),
        "term": lambda: np.where(k < n, v ** (k + 1), 0.0),
        "pure_endowment": lambda: np.where(k >= n, v ** n, 0.0),
        "endowment": lambda: v ** np.minimum(k + 1, n),
        "increasing_term": lambda: np.where(k < n, (k + 1) * v ** (k + 1), 0.0),
        "whole_due": lambda: ad(k + 1),
        "term_due": lambda: ad(np.minimum(k + 1, n)),
        "deferred_whole_due": lambda: v ** h * ad(np.maximum(k + 1 - h, 0)),
    }
    return table[product]()


def product_moments(product, q, i, n=10, h=5):
    pmf = curtate_pmf(q)
    pv = pv_by_k(product, len(q), i, n, h)
    e = float(np.sum(pv * pmf))
    e2 = float(np.sum(pv ** 2 * pmf))
    return {"epv": e, "second": e2, "var": e2 - e * e}


def epv(product, q, i, n=10, h=5):
    return product_moments(product, q, i, n, h)["epv"]


def nEx(q, i, n):
    kp = kpx_from_q(q)
    return (1 + i) ** (-n) * (kp[n] if n < len(kp) else 0.0)


def annuity_due(q, i, n=None):
    N = len(q) if n is None else min(n, len(q))
    return float(np.sum((1 + i) ** (-np.arange(N)) * kpx_from_q(q)[:N]))


def annuity_due_mthly_udd(q, i, m, n=None):
    """UDD m-thly annuity-due: alpha(m) a - beta(m) (1 - nEx)."""
    K = len(q)
    N = K if n is None else min(n, K)
    d = i / (1 + i)
    im = m * ((1 + i) ** (1 / m) - 1)
    dm = m * (1 - (1 - d) ** (1 / m))
    alpha = i * d / (im * dm)
    beta = (i - im) / (im * dm)
    En = nEx(q, i, N) if N < K else 0.0
    return alpha * annuity_due(q, i, N) - beta * (1 - En)


# ---------- Chapter 4: premiums ----------

def net_premium(product, q, i, S=1, n=10, h=5, t=None):
    return S * epv(product, q, i, n, h) / annuity_due(q, i, t)


def loss_by_k(product, q, i, S, P, n=10, h=5, t=None):
    K = len(q)
    k = np.arange(K)
    tt = K if t is None else t
    Z = pv_by_k(product, K, i, n, h)
    Y = annuity_certain(np.minimum(k + 1, tt), i, True)
    return S * Z - P * Y, Z, Y


def prob_loss(product, q, i, S, P, n=10, h=5, t=None):
    L, _, _ = loss_by_k(product, q, i, S, P, n, h, t)
    return float(np.sum(curtate_pmf(q)[L > 1e-9]))


def percentile_premium(product, q, i, S, alpha=0.05, n=10, h=5, t=None):
    _, Z, Y = loss_by_k(product, q, i, S, 0.0, n, h, t)
    thr = S * Z / Y
    order = np.argsort(-thr, kind="stable")
    cum = np.cumsum(curtate_pmf(q)[order])
    return float(thr[order][np.argmax(cum > alpha + 1e-12)])


def portfolio_premium(product, q, i, S, N, alpha=0.05, n=10, h=5, t=None):
    """Normal approximation: N E[L] + z sqrt(N Var[L]) = 0, solved by bisection."""
    z = NormalDist().inv_cdf(1 - alpha)
    pmf = curtate_pmf(q)

    def f(P):
        L, _, _ = loss_by_k(product, q, i, S, P, n, h, t)
        e = np.sum(L * pmf)
        return N * e + z * np.sqrt(N * (np.sum(L * L * pmf) - e * e))

    P0 = net_premium(product, q, i, S, n, h, t)
    lo, hi = 0.5 * P0, 20 * P0
    for _ in range(200):
        mid = (lo + hi) / 2
        if f(mid) > 0:
            lo = mid
        else:
            hi = mid
    return (lo + hi) / 2


def refund_premium(q, i, S, n, product="term"):
    IA = epv("increasing_term", q, i, n)
    return S * epv(product, q, i, n) / (annuity_due(q, i, n) - IA)


# ---------- The natural hedge ----------

def shock_q(q, s):
    out = np.minimum(1, q * (1 + s))
    out[-1] = 1.0
    return out


def natural_hedge(m, x_ins=40, x_ann=65, S=250000, B=20000, i=0.045, shock=0.10):
    qi, qa = q_path(m, x_ins), q_path(m, x_ann)
    dA = (epv("whole_life", shock_q(qi, shock), i) - epv("whole_life", shock_q(qi, -shock), i)) / (2 * shock)
    da = (epv("whole_due", shock_q(qa, shock), i) - epv("whole_due", shock_q(qa, -shock), i)) / (2 * shock)
    return -(S * dA) / (B * da)


# ---------- The rate book ----------

CLASS_EXTRA = {"Preferred": {"type": "mult_q", "k": 0.75}, "Standard": None,
               "Smoker": {"type": "mult_q", "k": 1.8}, "Rated": {"type": "add_mu", "delta": 0.005}}


def class_q_path(m, x, cls="Standard"):
    return q_path(m, x, select=[0.7, 0.85], extra=CLASS_EXTRA[cls])


def plan_premium(m, x, plan, cls="Standard", frequency="Annual", i=0.045, S=1000):
    q = class_q_path(m, x, cls)
    spec = {"WL": ("whole_life", 10, 5, None), "WL20": ("whole_life", 10, 5, 20),
            "T10": ("term", 10, 5, 10), "T20": ("term", 20, 5, 20), "E20": ("endowment", 20, 5, 20),
            "DA65": ("deferred_whole_due", 10, 65 - x, 65 - x)}[plan]
    product, n, h, t = spec
    benefit = S * epv(product, q, i, n, h)
    ann = annuity_due(q, i, t) if frequency == "Annual" else annuity_due_mthly_udd(q, i, 12, t)
    return benefit / ann
