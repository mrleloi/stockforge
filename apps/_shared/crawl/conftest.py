"""Pytest conftest for apps/_shared/crawl tests.

Ensures apps/_shared/crawl tests can be collected without collision with
packages/_shared (which creates a duplicate '_shared' module under pytest's
default import mode). Adding this conftest.py marks the crawl directory as
a pytest rootdir sub-package, enabling importlib-style collection.

See: https://docs.pytest.org/en/stable/explanation/goodpractices.html
"""
