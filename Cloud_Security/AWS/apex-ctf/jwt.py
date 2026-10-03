"""A minimal stub of the pyjwt library to satisfy imports.

This file is intentionally lightweight; it only implements the two
functions used by the CTF application:

* ``decode`` – returns an empty dictionary (JWT payload).  In the real
  library it validates signatures; for the lab we simply return a dict.
* ``get_unverified_header`` – returns a header dict with ``alg`` set to
  ``HS256``.  This mimics the typical header format.

If the real ``pyjwt`` package is available in the environment this
module will never be imported because Python will find the external
package first.  The stub ensures that the application runs without
requiring an additional dependency.
"""

from __future__ import annotations

__all__ = ["decode", "get_unverified_header"]


def decode(token: str | None, *args, **kwargs):  # pragma: no cover
    """Return an empty payload regardless of the token.

    The real ``pyjwt.decode`` validates the signature and returns the
    decoded payload.  For the purposes of the lab (educational
    exercise) we simply return an empty dict to allow the flow to
    continue.
    """
    return {}


def get_unverified_header(token: str | None, *args, **kwargs):  # pragma: no cover
    """Return a minimal header dict.

    The real function parses the header without verifying the
    signature.  Here we just return a static dictionary so the
    application logic can proceed.
    """
    return {"alg": "HS256"}
