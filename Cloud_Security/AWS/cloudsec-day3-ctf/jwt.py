"""Minimal stub for the ``jwt`` module.

The real webhook uses ``pyjwt``.  Installing the full package in the
exercise environment would be overkill, so we provide a very lightweight
fallback that mimics the interface used by the application.

Functions
---------
* ``decode`` – returns an empty dict.
* ``get_unverified_header`` – returns a dict with ``alg`` set to
  ``HS256``.

If the actual ``pyjwt`` package is present on ``sys.path`` it will win
over this file.
"""

from __future__ import annotations

__all__ = ["decode", "get_unverified_header"]


def decode(token, *args, **kwargs):  # pragma: no cover
    return {}


def get_unverified_header(token, *args, **kwargs):  # pragma: no cover
    return {"alg": "HS256"}
